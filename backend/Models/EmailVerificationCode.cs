using System.Security.Cryptography;
using System.Text;

namespace IOTAgriBackend.Models;

public class EmailVerificationCode
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string UserId { get; set; } = string.Empty;
    public ApplicationUser? User { get; set; }
    public string CodeHash { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public int AttemptCount { get; set; }
    public DateTime SentAt { get; set; }
    public DateTime? ConsumedAt { get; set; }
    public Guid Version { get; set; } = Guid.NewGuid();

    public static EmailVerificationCode Create(string userId, string code, string pepper, DateTime now)
    {
        return new EmailVerificationCode
        {
            UserId = userId,
            CodeHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{pepper}:{code}"))),
            SentAt = now,
            ExpiresAt = now.AddMinutes(15),
        };
    }
}
