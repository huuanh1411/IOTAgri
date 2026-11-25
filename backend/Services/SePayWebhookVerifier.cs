using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace IOTAgriBackend.Services;

public static class SePayWebhookVerifier
{
    private static readonly TimeSpan MaximumClockSkew = TimeSpan.FromMinutes(5);

    public static string Sign(string secret, long timestamp, string rawBody)
    {
        var bytes = HMACSHA256.HashData(Encoding.UTF8.GetBytes(secret), Encoding.UTF8.GetBytes($"{timestamp}.{rawBody}"));
        return $"sha256={Convert.ToHexString(bytes).ToLowerInvariant()}";
    }

    public static bool Verify(string secret, string? timestamp, string? signature, string rawBody, DateTimeOffset now)
    {
        if (string.IsNullOrWhiteSpace(secret)
            || !long.TryParse(timestamp, NumberStyles.None, CultureInfo.InvariantCulture, out var unixTimestamp)
            || unixTimestamp is < -62_135_596_800 or > 253_402_300_799)
        {
            return false;
        }

        if (Math.Abs((now - DateTimeOffset.FromUnixTimeSeconds(unixTimestamp)).TotalMinutes) > MaximumClockSkew.TotalMinutes) return false;

        var expected = Encoding.UTF8.GetBytes(Sign(secret, unixTimestamp, rawBody));
        var actual = Encoding.UTF8.GetBytes(signature ?? string.Empty);
        return CryptographicOperations.FixedTimeEquals(expected, actual);
    }
}
