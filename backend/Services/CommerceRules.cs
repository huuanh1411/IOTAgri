using IOTAgriBackend.Models;

namespace IOTAgriBackend.Services;

public static class CommerceRules
{
    public static bool ValidProduct(StoreProduct p) => !string.IsNullOrWhiteSpace(p.Sku) && p.Sku.Length <= 80
        && !string.IsNullOrWhiteSpace(p.Name) && p.Name.Length <= 200
        && !string.IsNullOrWhiteSpace(p.Contents) && p.Contents.Length <= 4000
        && p.PriceVnd is >= 0 and <= 50000000 && (!p.IsActive || p.PriceVnd >= 1000)
        && ((p.Kind == "hardware" && p.CycleCount == 0) || (p.Kind == "refill" && p.CycleCount is >= 1 and <= 100));

    public static StoreOrderItem Snapshot(StoreProduct p, int quantity)
    {
        if (!p.IsActive || p.PriceVnd < 1000 || quantity is < 1 or > 20) throw new ArgumentException("Sản phẩm hoặc số lượng không hợp lệ.");
        return new StoreOrderItem
        {
            ProductId = p.Id, Sku = p.Sku, Name = p.Name, Kind = p.Kind,
            CycleCount = p.CycleCount, Contents = p.Contents, UnitPriceVnd = p.PriceVnd, Quantity = quantity
        };
    }

    public static long Total(IEnumerable<StoreOrderItem> items, long shippingFee = 0)
    {
        if (shippingFee is < 0 or > 1000000) throw new ArgumentException("Phí giao hàng không hợp lệ.");
        var total = items.Aggregate(shippingFee, (sum, item) => checked(sum + checked(item.UnitPriceVnd * item.Quantity)));
        if (total is < 1000 or > 50000000) throw new ArgumentException("Tổng đơn phải từ 1.000 đến 50.000.000 đồng.");
        return total;
    }

    public static bool CanFulfill(StoreOrder order, string next) => order.PaymentStatus == "paid" &&
        ((order.FulfillmentStatus == "unfulfilled" && next == "shipping")
        || (order.FulfillmentStatus == "shipping" && next == "delivered"));

    public static void ApplyNotification(StoreOrder order, StorePayment payment, MomoNotification n)
    {
        if (n.Amount != order.TotalVnd || n.OrderId != payment.GatewayOrderId || n.RequestId != payment.RequestId
            || n.OrderInfo != $"Aerogreen {order.Id:N}") throw new ArgumentException("Thông tin giao dịch không khớp.");
        if (payment.Status == "paid")
        {
            if (n.ResultCode == 0 && payment.TransactionId != n.TransId) throw new ArgumentException("Giao dịch không khớp.");
            return; // Never downgrade a paid order on a duplicate or delayed callback.
        }
        if (n.ResultCode == 0 && n.TransId <= 0) throw new ArgumentException("Mã giao dịch không hợp lệ.");
        payment.ResultCode = n.ResultCode;
        if (n.ResultCode == 0)
        {
            payment.Status = "paid";
            payment.TransactionId = n.TransId;
            order.PaymentStatus = "paid";
            order.PaidAt = DateTime.UtcNow;
        }
        else if (n.ResultCode == 9000) { payment.Status = "pending"; }
        else { payment.Status = "failed"; order.PaymentStatus = "failed"; }
    }
}
