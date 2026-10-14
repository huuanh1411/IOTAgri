using System;
using IOTAgriBackend.Models;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DevicePresenceTests
{
    [Fact]
    public void Marks_devices_offline_after_thirty_seconds_without_a_reading()
    {
        var now = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc);

        Assert.False(DevicePresence.IsOffline(now.AddSeconds(-29), now));
        Assert.True(DevicePresence.IsOffline(now.AddSeconds(-30), now));
        Assert.True(DevicePresence.IsOffline(null, now));
    }
}
