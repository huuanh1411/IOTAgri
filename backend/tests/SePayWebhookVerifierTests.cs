using System;
using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class SePayWebhookVerifierTests
{
    [Fact]
    public void Verify_accepts_current_valid_signature()
    {
        const string secret = "webhook-secret";
        const string body = "{\"id\":92704}";
        const long timestamp = 1_700_000_000;
        var signature = SePayWebhookVerifier.Sign(secret, timestamp, body);

        Assert.True(SePayWebhookVerifier.Verify(secret, timestamp.ToString(), signature, body,
            DateTimeOffset.FromUnixTimeSeconds(timestamp)));
    }

    [Fact]
    public void Verify_rejects_tampered_or_expired_request()
    {
        const string secret = "webhook-secret";
        const long timestamp = 1_700_000_000;
        var signature = SePayWebhookVerifier.Sign(secret, timestamp, "{\"id\":92704}");

        Assert.False(SePayWebhookVerifier.Verify(secret, timestamp.ToString(), signature, "{\"id\":92705}",
            DateTimeOffset.FromUnixTimeSeconds(timestamp)));
        Assert.False(SePayWebhookVerifier.Verify(secret, timestamp.ToString(), signature, "{\"id\":92704}",
            DateTimeOffset.FromUnixTimeSeconds(timestamp).AddMinutes(6)));
    }

    [Fact]
    public void Verify_rejects_invalid_unix_timestamp()
    {
        Assert.False(SePayWebhookVerifier.Verify("webhook-secret", long.MaxValue.ToString(), "sha256=test", "{}", DateTimeOffset.UtcNow));
    }
}
