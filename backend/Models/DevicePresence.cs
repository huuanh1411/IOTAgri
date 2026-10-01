namespace IOTAgriBackend.Models;

public static class DevicePresence
{
    public static readonly TimeSpan OfflineAfter = TimeSpan.FromSeconds(30);

    public static bool IsOffline(DateTime? lastSeenAt, DateTime utcNow) =>
        lastSeenAt is null || lastSeenAt <= utcNow - OfflineAfter;
}
