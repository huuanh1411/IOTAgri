using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Subscriptions;
using IOTAgriBackend.Endpoints;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Xunit;

namespace IOTAgriBackend.Tests;

public class SubscriptionEndpointTests
{
    [Fact]
    public async Task Listing_subscriptions_marks_overdue_pending_payment_expired()
    {
        await using var fixture = await SubscriptionFixture.CreateAsync();
        var subscription = fixture.CreateSubscription(paymentExpiresAt: DateTime.UtcNow.AddMinutes(-1));
        fixture.Db.CropSubscriptions.Add(subscription);
        await fixture.Db.SaveChangesAsync();

        var result = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "ListAsync",
            fixture.Principal, fixture.Db, CancellationToken.None);

        var response = Assert.IsAssignableFrom<IValueHttpResult<List<CropSubscriptionResponse>>>(result).Value;
        Assert.NotNull(response);
        Assert.Equal("Expired", Assert.Single(response!).Status);
        fixture.Db.ChangeTracker.Clear();
        Assert.Equal("Expired", (await fixture.Db.CropSubscriptions.SingleAsync()).Status);
    }

    [Fact]
    public async Task Expired_pending_payment_allows_a_replacement_checkout()
    {
        await using var fixture = await SubscriptionFixture.CreateAsync();
        var expired = fixture.CreateSubscription(paymentExpiresAt: DateTime.UtcNow.AddMinutes(-1));
        fixture.Db.CropSubscriptions.Add(expired);
        await fixture.Db.SaveChangesAsync();

        var result = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "CreateAsync",
            fixture.Device.Id, new CreateCropSubscriptionRequest("Lettuce"), fixture.Principal, fixture.Db,
            fixture.SubscriptionOptions, CancellationToken.None);

        Assert.Equal(StatusCodes.Status201Created, ((IStatusCodeHttpResult)result).StatusCode);
        var replacement = Assert.IsAssignableFrom<IValueHttpResult<CropSubscriptionPaymentResponse>>(result).Value;
        Assert.NotNull(replacement);
        Assert.NotEqual(expired.PaymentCode, replacement!.Subscription.PaymentCode);
        fixture.Db.ChangeTracker.Clear();
        Assert.Equal(new[] { "Expired", "Pending" }, await fixture.Db.CropSubscriptions
            .OrderBy(item => item.Status).Select(item => item.Status).ToArrayAsync());
    }

    [Fact]
    public async Task Expired_pending_payment_rejects_validly_signed_webhook()
    {
        await using var fixture = await SubscriptionFixture.CreateAsync();
        var subscription = fixture.CreateSubscription(paymentExpiresAt: DateTime.UtcNow.AddMinutes(-1));
        fixture.Db.CropSubscriptions.Add(subscription);
        await fixture.Db.SaveChangesAsync();
        var request = CreateWebhookRequest(subscription.PaymentCode, subscription.AmountVnd);

        var result = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "ReceiveSePayWebhookAsync",
            request, fixture.Db, Options.Create(new SePayOptions { WebhookSecret = "secret" }),
            fixture.SubscriptionOptions, CancellationToken.None);

        Assert.Equal(StatusCodes.Status200OK, ((IStatusCodeHttpResult)result).StatusCode);
        fixture.Db.ChangeTracker.Clear();
        Assert.Equal("Pending", (await fixture.Db.CropSubscriptions.SingleAsync()).Status);
        var webhookEvent = await fixture.Db.SePayWebhookEvents.SingleAsync();
        Assert.False(webhookEvent.Success);
        Assert.Equal("Unmatched", webhookEvent.Status);

        fixture.Db.ChangeTracker.Clear();
        var replay = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "ReceiveSePayWebhookAsync",
            CreateWebhookRequest(subscription.PaymentCode, subscription.AmountVnd), fixture.Db,
            Options.Create(new SePayOptions { WebhookSecret = "secret" }), fixture.SubscriptionOptions, CancellationToken.None);
        Assert.Equal(StatusCodes.Status200OK, ((IStatusCodeHttpResult)replay).StatusCode);
        Assert.Equal(1, await fixture.Db.SePayWebhookEvents.CountAsync());
    }

    [Fact]
    public async Task Valid_sepay_payment_activates_pending_crop_subscription()
    {
        await using var connection = new SqliteConnection("DataSource=:memory:");
        await connection.OpenAsync();
        await using var db = new ApplicationDbContext(new DbContextOptionsBuilder<ApplicationDbContext>().UseSqlite(connection).Options);
        await db.Database.EnsureCreatedAsync();
        var user = new ApplicationUser { Id = "subscriber", UserName = "subscriber@example.test", Email = "subscriber@example.test" };
        var device = new Device { Name = "Grow rack", DeviceKey = "device-key", OwnerId = user.Id };
        db.AddRange(user, device);
        await db.SaveChangesAsync();
        var principal = new ClaimsPrincipal(new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, user.Id)]));
        var subscriptionOptions = Options.Create(new SubscriptionOptions
        {
            MonthlyPriceVnd = 50_000, BankCode = "MB", AccountNumber = "1234567890", AccountName = "AEROGREEN"
        });

        var created = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "CreateAsync",
            device.Id, new CreateCropSubscriptionRequest("Lettuce"), principal, db, subscriptionOptions, CancellationToken.None);
        Assert.Equal(StatusCodes.Status201Created, ((IStatusCodeHttpResult)created).StatusCode);
        var subscription = await db.CropSubscriptions.SingleAsync();
        var resumed = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "CreateAsync",
            device.Id, new CreateCropSubscriptionRequest("Lettuce"), principal, db, subscriptionOptions, CancellationToken.None);
        Assert.Equal(StatusCodes.Status409Conflict, ((IStatusCodeHttpResult)resumed).StatusCode);
        var resumedPayment = Assert.IsAssignableFrom<IValueHttpResult<CropSubscriptionPaymentResponse>>(resumed).Value;
        Assert.NotNull(resumedPayment);
        Assert.Equal(subscription.PaymentCode, resumedPayment!.Subscription.PaymentCode);

        var repricedOptions = Options.Create(new SubscriptionOptions
        {
            MonthlyPriceVnd = 239_000, BankCode = "MB", AccountNumber = "1234567890", AccountName = "AEROGREEN"
        });
        var repriced = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "CreateAsync",
            device.Id, new CreateCropSubscriptionRequest("Lettuce"), principal, db, repricedOptions, CancellationToken.None);
        Assert.Equal(StatusCodes.Status409Conflict, ((IStatusCodeHttpResult)repriced).StatusCode);
        Assert.Equal(239_000, subscription.AmountVnd);
        var repricedPayment = Assert.IsAssignableFrom<IValueHttpResult<CropSubscriptionPaymentResponse>>(repriced).Value;
        Assert.Equal(239_000, repricedPayment!.Subscription.AmountVnd);
        var rawBody = $"{{\"id\":92704,\"accountNumber\":\"1234567890\",\"code\":\"{subscription.PaymentCode}\",\"transferType\":\"in\",\"transferAmount\":{subscription.AmountVnd}}}";
        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var context = new DefaultHttpContext();
        context.Request.Body = new MemoryStream(Encoding.UTF8.GetBytes(rawBody));
        context.Request.Headers["X-SePay-Timestamp"] = timestamp.ToString();
        context.Request.Headers["X-SePay-Signature"] = SePayWebhookVerifier.Sign("secret", timestamp, rawBody);

        var paid = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "ReceiveSePayWebhookAsync",
            context.Request, db, Options.Create(new SePayOptions { WebhookSecret = "secret" }), subscriptionOptions, CancellationToken.None);

        Assert.Equal(StatusCodes.Status200OK, ((IStatusCodeHttpResult)paid).StatusCode);
        db.ChangeTracker.Clear();
        var activated = await db.CropSubscriptions.SingleAsync();
        Assert.Equal("Active", activated.Status);
        Assert.Equal(92704, activated.SePayTransactionId);
        Assert.NotNull(activated.PaidAt);
        Assert.NotNull(activated.ExpiresAt);
        Assert.Null(typeof(CropSubscription).GetProperty("SePayRawPayload"));

        var secondPayment = CreateWebhookRequest(subscription.PaymentCode, subscription.AmountVnd, transactionId: 92705);
        var rejected = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "ReceiveSePayWebhookAsync",
            secondPayment, db, Options.Create(new SePayOptions { WebhookSecret = "secret" }), subscriptionOptions, CancellationToken.None);

        Assert.Equal(StatusCodes.Status200OK, ((IStatusCodeHttpResult)rejected).StatusCode);
        db.ChangeTracker.Clear();
        Assert.Equal(92704, (await db.CropSubscriptions.SingleAsync()).SePayTransactionId);
        Assert.Equal(new[] { true, false }, await db.SePayWebhookEvents
            .OrderBy(item => item.TransactionId).Select(item => item.Success).ToArrayAsync());
    }

    private static HttpRequest CreateWebhookRequest(string paymentCode, int amountVnd, long transactionId = 92704)
    {
        var rawBody = $"{{\"id\":{transactionId},\"accountNumber\":\"1234567890\",\"code\":\"{paymentCode}\",\"transferType\":\"in\",\"transferAmount\":{amountVnd}}}";
        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var context = new DefaultHttpContext();
        context.Request.Body = new MemoryStream(Encoding.UTF8.GetBytes(rawBody));
        context.Request.Headers["X-SePay-Timestamp"] = timestamp.ToString();
        context.Request.Headers["X-SePay-Signature"] = SePayWebhookVerifier.Sign("secret", timestamp, rawBody);
        return context.Request;
    }

    private sealed class SubscriptionFixture : IAsyncDisposable
    {
        private readonly SqliteConnection _connection;

        private SubscriptionFixture(SqliteConnection connection, ApplicationDbContext db, ApplicationUser user, Device device,
            ClaimsPrincipal principal, IOptions<SubscriptionOptions> subscriptionOptions)
        {
            _connection = connection;
            Db = db;
            User = user;
            Device = device;
            Principal = principal;
            SubscriptionOptions = subscriptionOptions;
        }

        public ApplicationDbContext Db { get; }
        public ApplicationUser User { get; }
        public Device Device { get; }
        public ClaimsPrincipal Principal { get; }
        public IOptions<SubscriptionOptions> SubscriptionOptions { get; }

        public static async Task<SubscriptionFixture> CreateAsync()
        {
            var connection = new SqliteConnection("DataSource=:memory:");
            await connection.OpenAsync();
            var db = new ApplicationDbContext(new DbContextOptionsBuilder<ApplicationDbContext>().UseSqlite(connection).Options);
            await db.Database.EnsureCreatedAsync();
            var user = new ApplicationUser { Id = "subscriber", UserName = "subscriber@example.test", Email = "subscriber@example.test" };
            var device = new Device { Name = "Grow rack", DeviceKey = "device-key", OwnerId = user.Id };
            db.AddRange(user, device);
            await db.SaveChangesAsync();
            var principal = new ClaimsPrincipal(new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, user.Id)]));
            var subscriptionOptions = Options.Create(new SubscriptionOptions
            {
                MonthlyPriceVnd = 50_000, BankCode = "MB", AccountNumber = "1234567890", AccountName = "AEROGREEN"
            });
            return new SubscriptionFixture(connection, db, user, device, principal, subscriptionOptions);
        }

        public CropSubscription CreateSubscription(DateTime paymentExpiresAt) => new()
        {
            DeviceId = Device.Id,
            CropName = "Lettuce",
            AmountVnd = 50_000,
            PaymentCode = $"AG{Guid.NewGuid():N}".ToUpperInvariant(),
            PaymentExpiresAt = paymentExpiresAt
        };

        public async ValueTask DisposeAsync()
        {
            await Db.DisposeAsync();
            await _connection.DisposeAsync();
        }
    }
}
