using System;
using System.Linq;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Pumps;
using IOTAgriBackend.Endpoints;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace IOTAgriBackend.Tests;

[Trait("Category", "Integration")]
public class PumpSchedulePriorityTests : IClassFixture<PostgresTestFixture>
{
    private readonly PostgresTestFixture _fixture;
    public PumpSchedulePriorityTests(PostgresTestFixture fixture) => _fixture = fixture;

    [Theory]
    [InlineData(true, -1)]
    [InlineData(false, -1)]
    [InlineData(true, 0)]
    [InlineData(false, 0)]
    [InlineData(true, 1)]
    [InlineData(false, 1)]
    public async Task Manual_conflicts_from_start_before_dispatch_and_during_pending_or_active_run(bool isOn, int status)
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = OnlineDevice(isPumpOn: !isOn);
        db.Devices.Add(device);
        db.SensorReadings.Add(FreshSafeReading(device));
        var start = DateTime.UtcNow.AddSeconds(-10);
        var local = TimeZoneInfo.ConvertTimeFromUtc(start, TimeZoneInfo.FindSystemTimeZoneById("Asia/Ho_Chi_Minh"));
        db.PumpSchedules.Add(new PumpSchedule { Device = device, IsEnabled = status < 0, WeekdayMask = 127, StartTime = TimeOnly.FromDateTime(local), DurationSeconds = 600, TimeZone = "Asia/Ho_Chi_Minh" });
        if (status >= 0)
            db.PumpCommands.Add(new PumpCommand { Device = device, Source = PumpCommandSource.Scheduled, IsOn = true, DurationSeconds = 600, IssuedAt = start, Status = (PumpCommandStatus)status });
        await db.SaveChangesAsync();
        var result = await Send(db, device, isOn);
        Assert.Equal(409, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.False(await db.PumpCommands.AnyAsync(c => c.Source == PumpCommandSource.Manual));
    }

    [Fact]
    public async Task Future_schedule_does_not_block_manual_or_change_recurrence()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = OnlineDevice();
        db.Devices.Add(device);
        db.SensorReadings.Add(FreshSafeReading(device));
        var local = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow.AddHours(1), TimeZoneInfo.FindSystemTimeZoneById("Asia/Ho_Chi_Minh"));
        var schedule = new PumpSchedule { Device = device, IsEnabled = true, WeekdayMask = 127, StartTime = TimeOnly.FromDateTime(local), DurationSeconds = 60, TimeZone = "Asia/Ho_Chi_Minh" };
        db.PumpSchedules.Add(schedule);
        await db.SaveChangesAsync();
        var start = schedule.StartTime;
        var result = await Send(db, device, true);
        // Disconnected MQTT proves request passed admission and persisted, not transport success.
        Assert.Equal(503, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        var command = Assert.Single(await db.PumpCommands.ToListAsync());
        Assert.Equal(PumpCommandStatus.Failed, command.Status);
        Assert.Equal("MQTT_UNAVAILABLE", command.FailureReason);
        await db.Entry(schedule).ReloadAsync();
        Assert.Equal(start.Ticks / 10, schedule.StartTime.Ticks / 10);
        Assert.True(schedule.IsEnabled);
        Assert.Null(schedule.LastDispatchedOccurrenceUtc);
    }

    [Fact]
    public async Task Offline_or_stale_device_is_rejected_before_command_is_persisted()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = OnlineDevice();
        device.LastSeenAt = DateTime.UtcNow.AddMinutes(-2);
        db.Devices.Add(device);
        db.SensorReadings.Add(FreshSafeReading(device));
        await db.SaveChangesAsync();

        var result = await Send(db, device, true);

        Assert.Equal(409, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Empty(await db.PumpCommands.ToListAsync());
    }

    [Fact]
    public async Task Low_water_is_rejected_before_command_is_persisted()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = OnlineDevice();
        db.Devices.Add(device);
        db.SensorReadings.Add(new SensorReading
        {
            Device = device,
            RecordedAt = DateTime.UtcNow,
            WaterLevel = SystemAlertDefaults.DefaultLowWaterLevelPercent
        });
        await db.SaveChangesAsync();

        var result = await Send(db, device, true);

        Assert.Equal(409, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Empty(await db.PumpCommands.ToListAsync());
    }

    private static Device OnlineDevice(bool isPumpOn = false) => new()
    {
        Name = "Vietnam",
        DeviceKey = Guid.NewGuid().ToString(),
        Owner = new ApplicationUser { Id = "owner" },
        IsOnline = true,
        LastSeenAt = DateTime.UtcNow,
        IsPumpOn = isPumpOn
    };

    private static SensorReading FreshSafeReading(Device device) => new()
    {
        Device = device,
        RecordedAt = DateTime.UtcNow,
        WaterLevel = 80
    };

    private static async Task<IResult> Send(ApplicationDbContext db, Device device, bool isOn)
    {
        using var services = new ServiceCollection().BuildServiceProvider();
        var config = new ConfigurationBuilder().Build();
        using var mqtt = new MqttIngestionService(services.GetRequiredService<IServiceScopeFactory>(), config, NullLogger<MqttIngestionService>.Instance);
        var principal = new ClaimsPrincipal(new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, "owner") }, "test"));
        return await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "SendPumpCommandAsync", device.Id,
            new PumpCommandRequest(Guid.NewGuid(), isOn, isOn ? 60 : null), principal, db, config, mqtt, CancellationToken.None);
    }
}
