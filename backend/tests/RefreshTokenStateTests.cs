using System;
using IOTAgriBackend.Models;
using Xunit;

namespace IOTAgriBackend.Tests;

public class RefreshTokenStateTests
{
    [Theory]
    [InlineData(false, true, true)]
    [InlineData(false, false, false)]
    [InlineData(true, true, false)]
    [InlineData(true, false, false)]
    public void Token_is_active_only_when_unrevoked_and_not_expired(bool revoked, bool futureExpiry, bool expected)
    {
        // Extreme fixed dates avoid sleeps and races around the real clock boundary.
        var token = new RefreshToken
        {
            ExpiresAt = futureExpiry ? DateTime.MaxValue : DateTime.MinValue,
            RevokedAt = revoked ? new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) : null,
        };
        Assert.Equal(expected, token.IsActive);
    }
}
