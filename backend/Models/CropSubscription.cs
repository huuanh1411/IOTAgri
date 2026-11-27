namespace IOTAgriBackend.Models;

public class CropSubscription
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid DeviceId { get; set; }
    public Device? Device { get; set; }
    public string CropName { get; set; } = string.Empty;
    public int AmountVnd { get; set; }
    public string PaymentCode { get; set; } = string.Empty;
    public string Status { get; set; } = "Pending";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime PaymentExpiresAt { get; set; }
    public DateTime? PaidAt { get; set; }
    public DateTime? ExpiresAt { get; set; }
    public long? SePayTransactionId { get; set; }
}
