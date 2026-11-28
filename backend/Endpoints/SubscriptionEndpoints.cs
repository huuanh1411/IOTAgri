using System.Security.Claims;
using System.Text.Json;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Subscriptions;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace IOTAgriBackend.Endpoints;

public static class SubscriptionEndpoints
{
    public static IEndpointRouteBuilder MapSubscriptionEndpoints(this IEndpointRouteBuilder app)
    {
        var subscriptions = app.MapGroup("/api/subscriptions").WithTags("Subscriptions").RequireAuthorization();
        subscriptions.MapGet("/", ListAsync);
        subscriptions.MapPost("/devices/{deviceId:guid}", CreateAsync);
        app.MapPost("/api/payments/sepay/webhook", ReceiveSePayWebhookAsync).WithTags("Payments").AllowAnonymous();
        return app;
    }

    private static async Task<IResult> ListAsync(ClaimsPrincipal principal, ApplicationDbContext db, CancellationToken cancellationToken)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null) return Results.Unauthorized();

        var now = DateTime.UtcNow;
        await NormalizeExpiredPendingSubscriptionsAsync(db, now, cancellationToken);

        var subscriptions = await db.CropSubscriptions
            .Where(item => item.Device!.OwnerId == userId)
            .OrderByDescending(item => item.CreatedAt)
            .Select(item => ToResponse(item))
            .ToListAsync(cancellationToken);
        return Results.Ok(subscriptions);
    }

    private static async Task<IResult> CreateAsync(Guid deviceId, CreateCropSubscriptionRequest request,
        ClaimsPrincipal principal, ApplicationDbContext db, IOptions<SubscriptionOptions> options, CancellationToken cancellationToken)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId is null) return Results.Unauthorized();
        var cropName = request.CropName?.Trim();
        if (string.IsNullOrWhiteSpace(cropName) || cropName.Length > 100) return Results.BadRequest(new { error = "cropName must be 1 to 100 characters." });

        var settings = options.Value;
        if (settings.MonthlyPriceVnd <= 0 || string.IsNullOrWhiteSpace(settings.BankCode)
            || string.IsNullOrWhiteSpace(settings.AccountNumber) || string.IsNullOrWhiteSpace(settings.AccountName))
        {
            return Results.Problem("Subscription payment settings are not configured.", statusCode: StatusCodes.Status503ServiceUnavailable);
        }

        if (!await db.Devices.AnyAsync(device => device.Id == deviceId && device.OwnerId == userId, cancellationToken)) return Results.NotFound();

        var now = DateTime.UtcNow;
        await NormalizeExpiredPendingSubscriptionsAsync(db, now, cancellationToken);

        var openSubscription = await db.CropSubscriptions
            .Where(item => item.DeviceId == deviceId
                && ((item.Status == "Pending" && item.PaymentExpiresAt > now) || (item.Status == "Active" && item.ExpiresAt > now)))
            .OrderByDescending(item => item.CreatedAt)
            .FirstOrDefaultAsync(cancellationToken);
        if (openSubscription is not null)
        {
            // A pending payment has not been settled yet.  When the published
            // price changes, refresh its amount only as the owner explicitly
            // resumes checkout; active and paid subscriptions stay immutable.
            if (openSubscription.Status == "Pending" && openSubscription.AmountVnd != settings.MonthlyPriceVnd)
            {
                openSubscription.AmountVnd = settings.MonthlyPriceVnd;
                await db.SaveChangesAsync(cancellationToken);
            }

            // The request is idempotent for an open subscription.  Returning
            // its payment details lets the client resume the existing QR flow
            // instead of showing a generic conflict error.
            return Results.Conflict(new CropSubscriptionPaymentResponse(
                ToResponse(openSubscription), settings.BankCode, settings.AccountNumber, settings.AccountName));
        }

        var subscription = new CropSubscription
        {
            DeviceId = deviceId,
            CropName = cropName,
            AmountVnd = settings.MonthlyPriceVnd,
            PaymentCode = $"AG{Guid.NewGuid():N}".ToUpperInvariant(),
            PaymentExpiresAt = now.AddMinutes(30),
        };
        db.CropSubscriptions.Add(subscription);
        await db.SaveChangesAsync(cancellationToken);
        return Results.Created($"/api/subscriptions/{subscription.Id}", new CropSubscriptionPaymentResponse(
            ToResponse(subscription), settings.BankCode, settings.AccountNumber, settings.AccountName));
    }

    private static async Task<IResult> ReceiveSePayWebhookAsync(HttpRequest request, ApplicationDbContext db,
        IOptions<SePayOptions> sePayOptions, IOptions<SubscriptionOptions> subscriptionOptions, CancellationToken cancellationToken)
    {
        using var reader = new StreamReader(request.Body);
        var rawBody = await reader.ReadToEndAsync(cancellationToken);
        if (!SePayWebhookVerifier.Verify(sePayOptions.Value.WebhookSecret, request.Headers["X-SePay-Timestamp"],
                request.Headers["X-SePay-Signature"], rawBody, DateTimeOffset.UtcNow))
        {
            return Results.Unauthorized();
        }

        SePayPayment? payment;
        try
        {
            payment = JsonSerializer.Deserialize<SePayPayment>(rawBody, new JsonSerializerOptions(JsonSerializerDefaults.Web));
        }
        catch (JsonException)
        {
            return Results.Ok(new { success = false });
        }

        var settings = subscriptionOptions.Value;
        if (payment is null || payment.Id <= 0)
        {
            return Results.Ok(new { success = false });
        }

        await using var transaction = await db.Database.BeginTransactionAsync(cancellationToken);
        var webhookEvent = new SePayWebhookEvent { TransactionId = payment.Id };
        db.SePayWebhookEvents.Add(webhookEvent);
        try
        {
            await db.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            await transaction.RollbackAsync(cancellationToken);
            db.ChangeTracker.Clear();
            var priorEvent = await db.SePayWebhookEvents
                .AsNoTracking()
                .SingleOrDefaultAsync(item => item.TransactionId == payment.Id, cancellationToken);
            return priorEvent is null
                ? Results.StatusCode(StatusCodes.Status500InternalServerError)
                : Results.Ok(new { success = priorEvent.Success });
        }

        var paidAt = DateTime.UtcNow;
        var activated = payment.TransferType == "in"
            && !string.IsNullOrWhiteSpace(payment.Code)
            && payment.AccountNumber == settings.AccountNumber
            && await db.CropSubscriptions
                .Where(item => item.PaymentCode == payment.Code
                    && item.Status == "Pending"
                    && item.PaymentExpiresAt > paidAt
                    && item.AmountVnd == payment.TransferAmount)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(item => item.Status, "Active")
                    .SetProperty(item => item.PaidAt, (DateTime?)paidAt)
                    .SetProperty(item => item.ExpiresAt, (DateTime?)paidAt.AddMonths(1))
                    .SetProperty(item => item.SePayTransactionId, (long?)payment.Id), cancellationToken) == 1;

        webhookEvent.Success = activated;
        webhookEvent.Status = activated ? "Processed" : "Unmatched";
        webhookEvent.ProcessedAt = paidAt;
        await db.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);
        return Results.Ok(new { success = activated });
    }

    private static async Task NormalizeExpiredPendingSubscriptionsAsync(
        ApplicationDbContext db, DateTime utcNow, CancellationToken cancellationToken)
    {
        var overdue = await db.CropSubscriptions
            .Where(item => item.Status == "Pending" && item.PaymentExpiresAt <= utcNow)
            .ToListAsync(cancellationToken);

        foreach (var item in overdue)
        {
            item.Status = "Expired";
        }

        if (overdue.Count > 0)
        {
            await db.SaveChangesAsync(cancellationToken);
        }
    }

    private static CropSubscriptionResponse ToResponse(CropSubscription item) => new(
        item.Id, item.DeviceId, item.CropName, item.AmountVnd, item.PaymentCode, item.Status,
        item.CreatedAt, item.PaymentExpiresAt, item.PaidAt, item.ExpiresAt);

    private sealed record SePayPayment(long Id, string? AccountNumber, string? Code, string? TransferType, int TransferAmount);
}
