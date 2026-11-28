namespace IOTAgriBackend.Models;

public class SePayWebhookEvent
{
    public long TransactionId { get; set; }
    public bool Success { get; set; }
    public string Status { get; set; } = "Received";
    public DateTime ProcessedAt { get; set; } = DateTime.UtcNow;
}
