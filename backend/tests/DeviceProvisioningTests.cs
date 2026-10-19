using System;
using System.Linq;
using System.Net;
using System.Net.Http.Json;
using System.Threading.Tasks;
using IOTAgriBackend.Dtos.Devices;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace IOTAgriBackend.Tests;

[Trait("Category", "Integration")]
public class DeviceProvisioningTests : IClassFixture<PostgresTestFixture>
{
    private readonly PostgresTestFixture _fixture;

    public DeviceProvisioningTests(PostgresTestFixture fixture) => _fixture = fixture;

    [Fact]
    public async Task Successful_claim_returns_one_time_credentials_and_consumes_code()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedProvisionableDeviceAsync(db);
        var code = await IssueCodeAsync(db, device);
        var broker = new TestMqttBrokerAdminService();
        await using var app = await BackendHttpTestHost.CreateAsync(db, brokerAdmin: broker);
        using var client = app.GetTestClient();

        using var response = await client.PostAsJsonAsync("/api/device-provisioning/claims",
            new ClaimDeviceRequest(code, "ABCDEF0123456789"));

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var claim = (await response.Content.ReadFromJsonAsync<ClaimDeviceResponse>())!;
        Assert.Equal(device.DeviceKey, claim.MqttUsername);
        Assert.Equal("test-device-password", claim.MqttPassword);
        Assert.Equal("iotagr-ABCDEF0123456789", claim.MqttClientId);
        Assert.True(claim.UseTls);
        Assert.Equal([device.DeviceKey], broker.ReplacedDeviceKeys);
        db.ChangeTracker.Clear();
        var saved = await db.Devices.SingleAsync();
        Assert.Null(saved.ProvisioningCodeHash);
        Assert.Null(saved.ProvisioningCodeExpiresAt);
        Assert.Equal("ABCDEF0123456789", saved.ProvisionedHardwareId);
    }

    private static async Task<Device> SeedProvisionableDeviceAsync(Data.ApplicationDbContext db)
    {
        var user = new ApplicationUser { Id = "provisioning-user", UserName = "provisioning@example.test", Email = "provisioning@example.test" };
        var device = new Device { Name = "Provisioning device", DeviceKey = "provisioning-device-key", OwnerId = user.Id };
        db.Users.Add(user);
        db.Devices.Add(device);
        await db.SaveChangesAsync();
        return device;
    }

    private static async Task<string> IssueCodeAsync(Data.ApplicationDbContext db, Device device)
    {
        var code = ProvisioningCode.Create();
        device.ProvisioningCodeHash = ProvisioningCode.Hash(code);
        device.ProvisioningCodeExpiresAt = DateTime.UtcNow.AddMinutes(15);
        await db.SaveChangesAsync();
        return code;
    }
}