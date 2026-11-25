using System;
using System.IO;
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
        var rawBody = $"{{\"id\":92704,\"accountNumber\":\"1234567890\",\"code\":\"{subscription.PaymentCode}\",\"transferType\":\"in\",\"transferAmount\":50000}}";
        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var context = new DefaultHttpContext();
        context.Request.Body = new MemoryStream(Encoding.UTF8.GetBytes(rawBody));
        context.Request.Headers["X-SePay-Timestamp"] = timestamp.ToString();
        context.Request.Headers["X-SePay-Signature"] = SePayWebhookVerifier.Sign("secret", timestamp, rawBody);

        var paid = await BackendTestDoubles.InvokeHandler(typeof(SubscriptionEndpoints), "ReceiveSePayWebhookAsync",
            context.Request, db, Options.Create(new SePayOptions { WebhookSecret = "secret" }), subscriptionOptions, CancellationToken.None);

        Assert.Equal(StatusCodes.Status200OK, ((IStatusCodeHttpResult)paid).StatusCode);
        Assert.Equal("Active", subscription.Status);
        Assert.Equal(92704, subscription.SePayTransactionId);
        Assert.NotNull(subscription.ExpiresAt);
    }
}
