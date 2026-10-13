using System;
using IOTAgriBackend.Models;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DevicePresenceExtendedTests
{
    private static readonly TimeSpan OfflineAfter = DevicePresence.OfflineAfter;

    [Fact]
    public void Device_with_null_lastSeenAt_is_always_offline()
    {
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);

        Assert.True(DevicePresence.IsOffline(null, now));
    }

    [Fact]
    public void Device_seen_exactly_at_offline_threshold_is_offline()
    {
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);
        var lastSeen = now - OfflineAfter; // exactly at boundary

        Assert.True(DevicePresence.IsOffline(lastSeen, now));
    }

    [Fact]
    public void Device_seen_one_millisecond_before_threshold_is_online()
    {
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);
        var lastSeen = now - OfflineAfter + TimeSpan.FromMilliseconds(1);

        Assert.False(DevicePresence.IsOffline(lastSeen, now));
    }

    [Fact]
    public void Device_just_seen_is_online()
    {
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);

        Assert.False(DevicePresence.IsOffline(now, now));
    }

    [Fact]
    public void Device_seen_in_the_future_relative_to_now_is_online()
    {
        // Handles clock skew gracefully
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);
        var lastSeen = now.AddSeconds(5);

        Assert.False(DevicePresence.IsOffline(lastSeen, now));
    }

    [Fact]
    public void OfflineAfter_constant_is_thirty_seconds()
    {
        Assert.Equal(TimeSpan.FromSeconds(30), DevicePresence.OfflineAfter);
    }
}
