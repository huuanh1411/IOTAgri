using System;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class CommerceRulesTests
{
    private static StoreProduct Refill() => new() { Sku = "REFILL-3", Name = "3 chu kỳ", Kind = "refill", CycleCount = 3, Contents = "Cây con và dinh dưỡng cho cả 3 chu kỳ", PriceVnd = 850000, IsActive = true };
    internal static MomoOptions Settings() => new() { Enabled = true, PartnerCode = "QA", AccessKey = "qa-access", SecretKey = "qa-secret", RedirectUrl = "https://store.example.test/", IpnUrl = "https://api.example.test/api/store/payments/momo/ipn" };
    internal static MomoNotification Notification(StoreOrder order, StorePayment payment, int result = 0) => new(
        "QA", payment.GatewayOrderId, payment.RequestId, order.TotalVnd, $"Aerogreen {order.Id:N}", "momo_wallet", 123456789, result,
        "Successful.", "qr", 1721720663942, "", "");

    [Fact]
    public void Snapshot_preserves_price_contents_and_cycle_count_after_catalog_changes()
    {
        var product = Refill();
        var snapshot = CommerceRules.Snapshot(product, 2);
        product.PriceVnd = 1; product.CycleCount = 99; product.Contents = "changed";
        Assert.Equal(850000, snapshot.UnitPriceVnd);
        Assert.Equal(3, snapshot.CycleCount);
        Assert.Contains("3 chu kỳ", snapshot.Contents);
        Assert.Equal(1720000, CommerceRules.Total(new[] { snapshot }, 20000));
    }

    [Theory]
    [InlineData(0)] [InlineData(-1)] [InlineData(21)]
    public void Rejects_invalid_quantities(int quantity) => Assert.Throws<ArgumentException>(() => CommerceRules.Snapshot(Refill(), quantity));

    [Fact]
    public void Rejects_disabled_products_bad_totals_and_invalid_refill()
    {
        var product = Refill(); product.IsActive = false;
        Assert.Throws<ArgumentException>(() => CommerceRules.Snapshot(product, 1));
        Assert.Throws<ArgumentException>(() => CommerceRules.Total(Array.Empty<StoreOrderItem>()));
        Assert.Throws<ArgumentException>(() => CommerceRules.Total(Array.Empty<StoreOrderItem>(), -1));
        product.IsActive = true; product.CycleCount = 0;
        Assert.False(CommerceRules.ValidProduct(product));
        product.CycleCount = 3; product.PriceVnd = 0;
        Assert.False(CommerceRules.ValidProduct(product));
    }

    [Fact]
    public void Hmac_matches_RFC4231_vector_and_notification_rejects_tampering()
    {
        Assert.Equal("5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843", MomoSignatures.Sign("what do ya want for nothing?", "Jefe"));
        var order = new StoreOrder { TotalVnd = 299000 }; var payment = new StorePayment(); var options = Settings();
        var n = Notification(order, payment);
        n = n with { Signature = MomoSignatures.Sign(MomoSignatures.NotificationRaw(n, options.AccessKey), options.SecretKey) };
        Assert.True(MomoSignatures.Verify(n, options));
        Assert.False(MomoSignatures.Verify(n with { Amount = 1000 }, options));
        Assert.False(MomoSignatures.Verify(n with { PartnerCode = "other" }, options));
        Assert.False(MomoSignatures.Verify(n with { Signature = "not-hex" }, options));
        options.Enabled = false; Assert.False(MomoSignatures.Verify(n, options));
    }

    [Fact]
    public void Notification_checks_order_amount_request_and_preserves_paid_on_duplicate_or_failure()
    {
        var order = new StoreOrder { TotalVnd = 299000 }; var payment = new StorePayment(); var n = Notification(order, payment);
        Assert.Throws<ArgumentException>(() => CommerceRules.ApplyNotification(order, payment, n with { Amount = 1000 }));
        Assert.Throws<ArgumentException>(() => CommerceRules.ApplyNotification(order, payment, n with { RequestId = "other" }));
        Assert.Throws<ArgumentException>(() => CommerceRules.ApplyNotification(order, payment, n with { OrderId = "other" }));
        CommerceRules.ApplyNotification(order, payment, n with { ResultCode = 9000 });
        Assert.Equal("pending", order.PaymentStatus);
        CommerceRules.ApplyNotification(order, payment, n);
        var paidAt = order.PaidAt;
        CommerceRules.ApplyNotification(order, payment, n);
        CommerceRules.ApplyNotification(order, payment, n with { ResultCode = 1006 });
        Assert.Equal("paid", order.PaymentStatus); Assert.Equal(paidAt, order.PaidAt);
        Assert.Throws<ArgumentException>(() => CommerceRules.ApplyNotification(order, payment, n with { TransId = 999 }));
    }

    [Fact]
    public void Shipment_requires_verified_payment_and_only_advances_forward()
    {
        var order = new StoreOrder();
        Assert.False(CommerceRules.CanFulfill(order, "shipping"));
        order.PaymentStatus = "paid";
        Assert.True(CommerceRules.CanFulfill(order, "shipping"));
        Assert.False(CommerceRules.CanFulfill(order, "delivered"));
        order.FulfillmentStatus = "shipping";
        Assert.True(CommerceRules.CanFulfill(order, "delivered"));
        Assert.False(CommerceRules.CanFulfill(order, "unfulfilled"));
    }
}
