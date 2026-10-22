using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Dtos.Auth;
using IOTAgriBackend.Endpoints;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace IOTAgriBackend.Tests;

[Trait("Category", "Integration")]
public class CommerceHttpTests(PostgresTestFixture fixture) : IClassFixture<PostgresTestFixture>
{
    private static readonly Guid RefillId = Guid.Parse("9a0449ed-6608-4486-b329-1292e9225002");
    private static void Configure(IServiceCollection services, Gateway handler)
    {
        services.Configure<MomoOptions>(o =>
        {
            var settings = CommerceRulesTests.Settings();
            o.Enabled = true; o.PartnerCode = settings.PartnerCode; o.AccessKey = settings.AccessKey;
            o.SecretKey = settings.SecretKey; o.RedirectUrl = settings.RedirectUrl; o.IpnUrl = settings.IpnUrl;
        });
        services.AddHttpClient<MomoPaymentService>().ConfigurePrimaryHttpMessageHandler(() => handler);
    }
    private static async Task Login(HttpClient client, string email)
    {
        await client.PostAsJsonAsync("/api/auth/register", new RegisterRequest(email, "QaPassword1!", "QA Buyer"));
        var response = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest(email, "QaPassword1!"));
        response.EnsureSuccessStatusCode();
        var tokens = (await response.Content.ReadFromJsonAsync<AuthResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
    }
    private static CheckoutRequest Request() => new(Guid.NewGuid(), "QA Buyer", "0901234567", "QA delivery address", [new(RefillId, 2)], 598000);
    private static async Task<HttpResponseMessage> Notify(HttpClient client, StoreOrder order, StorePayment payment, int code = 0, bool tamper = false)
    {
        var options = CommerceRulesTests.Settings();
        var n = CommerceRulesTests.Notification(order, payment, code);
        n = n with { Signature = MomoSignatures.Sign(MomoSignatures.NotificationRaw(n, options.AccessKey), options.SecretKey) };
        if (tamper) n = n with { Amount = 1000 };
        return await client.PostAsJsonAsync("/api/store/payments/momo/ipn", n);
    }

    [Fact]
    public async Task Checkout_uses_server_prices_is_idempotent_and_hides_orders_from_other_users()
    {
        await using var db = await fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db, configureServices: s => Configure(s, new Gateway()));
        using var client = app.GetTestClient();
        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/api/store/products")).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await client.PostAsJsonAsync("/api/store/orders", Request())).StatusCode);
        await Login(client, "buyer@example.test");
        var request = Request();
        Assert.Equal(HttpStatusCode.Conflict, (await client.PostAsJsonAsync("/api/store/orders", request with { ExpectedTotalVnd = 1 })).StatusCode);
        var responses = await Task.WhenAll(client.PostAsJsonAsync("/api/store/orders", request), client.PostAsJsonAsync("/api/store/orders", request));
        foreach (var response in responses) response.EnsureSuccessStatusCode();
        Assert.Equal(1, await db.StoreOrders.CountAsync());
        var order = await db.StoreOrders.AsNoTracking().Include(o => o.Items).SingleAsync();
        Assert.Equal(598000, order.TotalVnd); Assert.Equal(1, order.Items.Single().CycleCount);
        await db.StoreProducts.Where(p => p.Id == RefillId).ExecuteUpdateAsync(s => s.SetProperty(p => p.PriceVnd, 399000).SetProperty(p => p.Contents, "changed"));
        var own = await client.GetAsync($"/api/store/orders/{order.Id}");
        var json = await own.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(598000, json.GetProperty("totalVnd").GetInt64());
        Assert.Contains("Cây con", json.GetProperty("items")[0].GetProperty("contents").GetString());
        Assert.Equal(HttpStatusCode.Forbidden, (await client.GetAsync("/api/admin/store/orders")).StatusCode);
        await Login(client, "other@example.test");
        Assert.Equal(HttpStatusCode.NotFound, (await client.GetAsync($"/api/store/orders/{order.Id}")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await client.PostAsync($"/api/store/orders/{order.Id}/payment", null)).StatusCode);
    }

    [Fact]
    public async Task Payment_link_is_reused_and_only_signed_matching_IPN_confirms_payment()
    {
        await using var db = await fixture.CreateDatabaseAsync();
        var gateway = new Gateway();
        await using var app = await BackendHttpTestHost.CreateAsync(db, configureServices: s => Configure(s, gateway));
        using var client = app.GetTestClient();
        await Login(client, "buyer@example.test");
        (await client.PostAsJsonAsync("/api/store/orders", Request())).EnsureSuccessStatusCode();
        var order = await db.StoreOrders.AsNoTracking().SingleAsync();
        var payment = await db.StorePayments.AsNoTracking().SingleAsync();
        var results = await Task.WhenAll(client.PostAsync($"/api/store/orders/{order.Id}/payment", null), client.PostAsync($"/api/store/orders/{order.Id}/payment", null));
        foreach (var response in results) response.EnsureSuccessStatusCode();
        Assert.Equal(1, gateway.Calls);
        Assert.Equal("pending", (await db.StoreOrders.AsNoTracking().SingleAsync()).PaymentStatus);
        Assert.Equal(HttpStatusCode.BadRequest, (await Notify(client, order, payment, tamper: true)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Notify(client, order, payment, 9000)).StatusCode);
        Assert.Equal("pending", (await db.StoreOrders.AsNoTracking().SingleAsync()).PaymentStatus);
        Assert.Equal(HttpStatusCode.NoContent, (await Notify(client, order, payment)).StatusCode);
        var paidAt = (await db.StoreOrders.AsNoTracking().SingleAsync()).PaidAt;
        Assert.NotNull(paidAt);
        Assert.Equal(HttpStatusCode.NoContent, (await Notify(client, order, payment)).StatusCode);
        Assert.Equal(HttpStatusCode.NoContent, (await Notify(client, order, payment, 1006)).StatusCode);
        var paid = await db.StoreOrders.AsNoTracking().SingleAsync();
        Assert.Equal("paid", paid.PaymentStatus); Assert.Equal(paidAt, paid.PaidAt);
        Assert.Equal(HttpStatusCode.Conflict, (await client.PostAsync($"/api/store/orders/{order.Id}/payment", null)).StatusCode);
    }

    [Fact]
    public async Task Admin_can_configure_multi_cycle_package_and_ship_only_after_payment()
    {
        await using var db = await fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db, configureServices: s => Configure(s, new Gateway()));
        using var client = app.GetTestClient();
        await Login(client, "admin@example.test");
        using (var scope = app.Services.CreateScope())
        {
            var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
            await users.AddToRoleAsync((await users.FindByEmailAsync("admin@example.test"))!, "Admin");
        }
        await Login(client, "admin@example.test");
        var package = new ProductRequest("REFILL-3", "Gói rau ăn 3 chu kỳ", "refill", 3, "Toàn bộ cây con và dinh dưỡng cho 3 chu kỳ, giao một lần", 850000, true);
        Assert.Equal(HttpStatusCode.OK, (await client.PutAsJsonAsync($"/api/admin/store/products/{Guid.NewGuid()}", package)).StatusCode);
        (await client.PostAsJsonAsync("/api/store/orders", Request())).EnsureSuccessStatusCode();
        var order = await db.StoreOrders.AsNoTracking().SingleAsync(); var payment = await db.StorePayments.AsNoTracking().SingleAsync();
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/admin/store/orders/{order.Id}/fulfillment", new FulfillmentRequest("shipping", "QA-TRACK"))).StatusCode);
        await Notify(client, order, payment);
        Assert.Equal(HttpStatusCode.OK, (await client.PutAsJsonAsync($"/api/admin/store/orders/{order.Id}/fulfillment", new FulfillmentRequest("shipping", "QA-TRACK"))).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await client.PutAsJsonAsync($"/api/admin/store/orders/{order.Id}/fulfillment", new FulfillmentRequest("delivered", null))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.PutAsJsonAsync($"/api/admin/store/orders/{order.Id}/fulfillment", new FulfillmentRequest("shipping", null))).StatusCode);
    }

    private class Gateway : HttpMessageHandler
    {
        public int Calls;
        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            Interlocked.Increment(ref Calls);
            var data = (await request.Content!.ReadFromJsonAsync<JsonElement>(cancellationToken))!;
            Assert.Equal("captureWallet", data.GetProperty("requestType").GetString());
            Assert.Equal(598000, data.GetProperty("amount").GetInt64());
            return new HttpResponseMessage(HttpStatusCode.OK) { Content = JsonContent.Create(new { resultCode = 0,
                orderId = data.GetProperty("orderId").GetString(), requestId = data.GetProperty("requestId").GetString(), payUrl = "https://test-payment.momo.vn/v2/gateway/pay?qa=1" }) };
        }
    }
}
