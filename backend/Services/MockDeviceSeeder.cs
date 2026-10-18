using IOTAgriBackend.Data;
using IOTAgriBackend.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Services;

public static class MockDeviceSeeder
{
    public static async Task SeedAsync(IServiceProvider services, IConfiguration configuration)
    {
        if (!configuration.GetValue<bool>("MockDevice:Enabled"))
        {
            return;
        }

        var ownerEmail = configuration["MockDevice:OwnerEmail"]?.Trim();
        var deviceKey = configuration["MockDevice:DeviceKey"]?.Trim();
        var deviceName = configuration["MockDevice:Name"]?.Trim() ?? "Aerogreen Docker Mock";
        if (string.IsNullOrWhiteSpace(ownerEmail) || string.IsNullOrWhiteSpace(deviceKey))
        {
            throw new InvalidOperationException("MockDevice owner email and device key are required when the simulator is enabled.");
        }

        await using var scope = services.CreateAsyncScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("MockDeviceSeeder");
        var owner = await users.FindByEmailAsync(ownerEmail);
        if (owner is null)
        {
            throw new InvalidOperationException($"Mock device owner '{ownerEmail}' does not exist.");
        }

        var device = await db.Devices.SingleOrDefaultAsync(candidate => candidate.DeviceKey == deviceKey);
        if (device is null)
        {
            device = new Device
            {
                Name = deviceName,
                DeviceKey = deviceKey,
                OwnerId = owner.Id,
                ProvisionedHardwareId = "DOCKER-MOCK-001",
                ProvisionedAt = DateTime.UtcNow,
            };
            db.Devices.Add(device);
        }
        else
        {
            device.Name = deviceName;
            device.OwnerId = owner.Id;
            device.ProvisionedHardwareId ??= "DOCKER-MOCK-001";
            device.ProvisionedAt ??= DateTime.UtcNow;
        }

        await db.SaveChangesAsync();
        logger.LogInformation("Mock device {DeviceId} is assigned to {OwnerEmail}.", device.Id, ownerEmail);
    }
}
