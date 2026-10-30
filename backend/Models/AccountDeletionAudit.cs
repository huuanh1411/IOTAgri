namespace IOTAgriBackend.Models;

public class AccountDeletionAudit
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime DeletedAt { get; set; } = DateTime.UtcNow;
}
