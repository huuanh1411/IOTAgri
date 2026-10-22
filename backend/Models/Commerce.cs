namespace IOTAgriBackend.Models;

public class StoreProduct
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Sku { get; set; } = "";
    public string Name { get; set; } = "";
    public string Kind { get; set; } = "hardware";
    public int CycleCount { get; set; }
    public string Contents { get; set; } = "";
    public long PriceVnd { get; set; }
    public bool IsActive { get; set; }
}

public class StoreOrder
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string UserId { get; set; } = "";
    public ApplicationUser? User { get; set; }
    public Guid CheckoutKey { get; set; }
    public string CustomerName { get; set; } = "";
    public string Phone { get; set; } = "";
    public string Address { get; set; } = "";
    public long TotalVnd { get; set; }
    public long ShippingFeeVnd { get; set; }
    public string PaymentStatus { get; set; } = "pending";
    public string FulfillmentStatus { get; set; } = "unfulfilled";
    public string? TrackingNumber { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? PaidAt { get; set; }
    public List<StoreOrderItem> Items { get; set; } = [];
}

public class StoreOrderItem
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrderId { get; set; }
    public StoreOrder? Order { get; set; }
    public Guid ProductId { get; set; }
    public string Sku { get; set; } = "";
    public string Name { get; set; } = "";
    public string Kind { get; set; } = "";
    public int CycleCount { get; set; }
    public string Contents { get; set; } = "";
    public long UnitPriceVnd { get; set; }
    public int Quantity { get; set; }
}

public class StorePayment
{
    // One MoMo transaction per order. Retries reuse these IDs, preventing double charging.
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid OrderId { get; set; }
    public StoreOrder? Order { get; set; }
    public string RequestId { get; set; } = Guid.NewGuid().ToString("N");
    public string GatewayOrderId { get; set; } = Guid.NewGuid().ToString("N");
    public string Status { get; set; } = "pending";
    public string? PayUrl { get; set; }
    public long? TransactionId { get; set; }
    public int? ResultCode { get; set; }
}
