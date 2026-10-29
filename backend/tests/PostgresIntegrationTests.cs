using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Alerts;
using IOTAgriBackend.Dtos.Auth;
using IOTAgriBackend.Dtos.Admin;
using IOTAgriBackend.Dtos.Dashboard;
using IOTAgriBackend.Dtos.Devices;
using IOTAgriBackend.Dtos.Lights;
using IOTAgriBackend.Dtos.Pumps;
using IOTAgriBackend.Dtos.Sensors;
using IOTAgriBackend.Dtos.Tickets;
using IOTAgriBackend.Endpoints;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Npgsql;
using Xunit;

namespace IOTAgriBackend.Tests;

[Trait("Category", "Integration")]
public class PostgresIntegrationTests : IClassFixture<PostgresTestFixture>
{
    private readonly PostgresTestFixture _fixture;
    public PostgresIntegrationTests(PostgresTestFixture fixture) => _fixture = fixture;
    private static ClaimsPrincipal Principal(string id = "qa-owner") => new(new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, id) }, "qa"));
    private static int? Status(IResult result) => Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode;
    private static object? Value(IResult result) => Assert.IsAssignableFrom<IValueHttpResult>(result).Value;
    private static async Task<Device> SeedDevice(ApplicationDbContext db)
    {
        var user = new ApplicationUser { Id = "qa-owner", UserName = "qa@example.test", Email = "qa@example.test", FullName = "QA Owner" };
        var device = new Device { Name = "QA Device", DeviceKey = "qa-device-key", Owner = user };
        db.Devices.Add(device);
        await db.SaveChangesAsync();
        return device;
    }

    [Fact]
    public async Task Fresh_database_applies_all_migrations_and_has_no_pending_model_changes()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var applied = (await db.Database.GetAppliedMigrationsAsync()).ToList();
        Assert.Equal(20, applied.Count);
        Assert.Contains("20261009120000_AddSolutionTemperatureToSensorReadings", applied);
        Assert.Contains("20261027101944_AddEmailVerificationCodes", applied);
        Assert.Contains("20261014072501_AddPumpScheduleActiveDateRange", applied);
        Assert.Contains("20261019101304_AddProvisioningClaimLeaseModel", applied);
        Assert.Empty(await db.Database.GetPendingMigrationsAsync());
        Assert.False(db.Database.HasPendingModelChanges());
    }

    [Fact]
    public async Task Device_crud_persists_updates_and_hides_device_from_other_owner()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        db.Users.Add(new ApplicationUser { Id = "qa-owner", UserName = "qa" });
        await db.SaveChangesAsync();
        var create = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "CreateAsync", new CreateDeviceRequest("Original"), Principal(), db);
        Assert.Equal(201, Status(create));
        var device = await db.Devices.SingleAsync();
        Assert.Matches("^[A-Za-z0-9_-]{43}$", device.DeviceKey);
        var denied = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "GetAsync", device.Id, Principal("other-owner"), db);
        Assert.Equal(404, Status(denied));
        var update = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "UpdateAsync", device.Id, new UpdateDeviceRequest("Updated"), Principal(), db);
        Assert.Equal("Updated", Assert.IsType<DeviceResponse>(Value(update)).Name);
        db.ChangeTracker.Clear();
        Assert.Equal("Updated", (await db.Devices.SingleAsync()).Name);
        var delete = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "DeleteAsync", device.Id, Principal(), db);
        Assert.Equal(204, Status(delete));
        Assert.Empty(await db.Devices.ToListAsync());
    }

    [Fact]
    public async Task Sensor_aggregate_sql_computes_real_postgresql_min_average_max_and_count()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        db.SensorReadings.AddRange(new SensorReading { DeviceId = device.Id, RecordedAt = start.AddMinutes(10), Temperature = 20, WaterLevel = 40 },
            new SensorReading { DeviceId = device.Id, RecordedAt = start.AddMinutes(20), Temperature = 30, WaterLevel = 60 });
        await db.SaveChangesAsync();
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), "GetAggregatedReadingsAsync", device.Id, Principal(), db, "hour", start, start.AddHours(1));
        var bucket = Assert.Single(Assert.IsType<List<AggregatedReadingBucket>>(Value(result)));
        Assert.Equal(start, bucket.BucketStart);
        Assert.Equal(25, bucket.AvgTemperature);
        Assert.Equal(20, bucket.MinTemperature);
        Assert.Equal(30, bucket.MaxTemperature);
        Assert.Equal(50, bucket.AvgWaterLevel);
        Assert.Equal(2, bucket.SampleCount);
    }

    [Fact]
    public async Task Hourly_median_sql_uses_percentile_cont_and_preserves_empty_hours()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        foreach (var (minute, value) in new[] { (10, 10d), (20, 30d), (30, 50d), (40, 90d) })
            db.SensorReadings.Add(new SensorReading { DeviceId = device.Id, RecordedAt = start.AddMinutes(minute), Temperature = value, SolutionTemperature = value });
        await db.SaveChangesAsync();
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), "GetHourlyMediansAsync", device.Id, new DateOnly(2026, 10, 1), Principal(), db);
        var buckets = Assert.IsAssignableFrom<IReadOnlyList<SensorMedianBucket>>(Value(result));
        Assert.Equal(24, buckets.Count);
        Assert.Equal(40, buckets[0].MedianTemperature);
        Assert.Equal(40, buckets[0].MedianSolutionTemperature);
        Assert.Equal(4, buckets[0].SampleCount);
        Assert.Null(buckets[1].MedianTemperature);
        Assert.Equal(0, buckets[1].SampleCount);
    }

    [Fact]
    public async Task Provisioning_code_claim_is_one_use_and_clears_secret_hash()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var issued = await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "CreateCodeAsync", device.Id, Principal(), db);
        var code = Assert.IsType<CreateProvisioningCodeResponse>(Value(issued));
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["DeviceProvisioning:MqttHost"] = "qa-broker", ["Mqtt:Port"] = "1883" }).Build();
        var request = new ClaimDeviceRequest(" " + code.Code.ToLowerInvariant() + " ", " qa-hardware ");
        var broker = new TestMqttBrokerAdminService();
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", request, db, config, broker, CancellationToken.None);
        Assert.Equal(200, Status(result));
        Assert.Equal(device.DeviceKey, Assert.IsType<ClaimDeviceResponse>(Value(result)).DeviceKey);
        db.ChangeTracker.Clear();
        var saved = await db.Devices.SingleAsync();
        Assert.Null(saved.ProvisioningCodeHash);
        Assert.Null(saved.ProvisioningCodeExpiresAt);
        Assert.Equal("QA-HARDWARE", saved.ProvisionedHardwareId);
        Assert.NotNull(saved.ProvisionedAt);
        Assert.Equal(400, Status(await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", request, db, config, broker, CancellationToken.None)));
    }

    [Fact]
    public async Task Refresh_rotation_revokes_original_token_and_rejects_reuse()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var user = await db.Users.SingleAsync();
        var old = new RefreshToken { UserId = user.Id, Token = "old-qa-token", ExpiresAt = DateTime.UtcNow.AddDays(1) };
        db.RefreshTokens.Add(old);
        await db.SaveChangesAsync();
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.GetRolesAsync(It.IsAny<ApplicationUser>())).ReturnsAsync(new List<string> { "User" });
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.CreateAccessToken(It.IsAny<ApplicationUser>(), It.IsAny<IList<string>>())).Returns("qa-access");
        tokens.Setup(t => t.GenerateRefreshTokenValue()).Returns("new-qa-token");
        var config = new ConfigurationBuilder().Build();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "RefreshAsync", new RefreshRequest(old.Token), users.Object, db, tokens.Object, config);
        Assert.Equal("new-qa-token", Assert.IsType<AuthResponse>(Value(result)).RefreshToken);
        db.ChangeTracker.Clear();
        var original = await db.RefreshTokens.SingleAsync(t => t.Token == "old-qa-token");
        Assert.NotNull(original.RevokedAt);
        Assert.Equal("new-qa-token", original.ReplacedByToken);
        Assert.Equal(401, Status(await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "RefreshAsync", new RefreshRequest(old.Token), users.Object, db, tokens.Object, config)));
        Assert.Equal(2, await db.RefreshTokens.CountAsync());
    }

    [Fact]
    public async Task Logout_revokes_only_callers_refresh_token_and_is_idempotent()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await SeedDevice(db);
        db.RefreshTokens.Add(new RefreshToken { UserId = "qa-owner", Token = "qa-logout-token", ExpiresAt = DateTime.UtcNow.AddDays(1) });
        await db.SaveChangesAsync();
        var request = new RefreshRequest("qa-logout-token");
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LogoutAsync", request, Principal("other"), db)));
        Assert.Null((await db.RefreshTokens.SingleAsync()).RevokedAt);
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LogoutAsync", request, Principal(), db)));
        db.ChangeTracker.Clear();
        Assert.NotNull((await db.RefreshTokens.SingleAsync()).RevokedAt);
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LogoutAsync", request, Principal(), db)));
    }

    [Fact]
    public async Task Database_enforces_unique_device_key_and_filtered_active_alert_index()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        db.Devices.Add(new Device { DeviceKey = device.DeviceKey, Name = "Duplicate" });
        var duplicate = await Assert.ThrowsAsync<DbUpdateException>(() => db.SaveChangesAsync());
        Assert.Equal(PostgresErrorCodes.UniqueViolation, Assert.IsType<PostgresException>(duplicate.InnerException).SqlState);
        db.ChangeTracker.Clear();
        db.DeviceAlerts.Add(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature });
        await db.SaveChangesAsync();
        db.DeviceAlerts.Add(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature });
        var activeDuplicate = await Assert.ThrowsAsync<DbUpdateException>(() => db.SaveChangesAsync());
        Assert.Equal(PostgresErrorCodes.UniqueViolation, Assert.IsType<PostgresException>(activeDuplicate.InnerException).SqlState);
        db.ChangeTracker.Clear();
        db.DeviceAlerts.Add(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature, ResolvedAt = DateTime.UtcNow });
        await db.SaveChangesAsync();
        Assert.Equal(2, await db.DeviceAlerts.CountAsync());
    }

    [Fact]
    public async Task Alert_settings_round_trip_and_history_filter_exclude_resolved_records()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var settings = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "UpdateAlertSettingsAsync", device.Id, new DeviceAlertSettingsRequest(42, 15), Principal(), db);
        Assert.Equal(42, Assert.IsType<DeviceAlertSettingsResponse>(Value(settings)).HighTemperatureC);
        db.DeviceAlerts.AddRange(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature },
            new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.LowWaterLevel, ResolvedAt = DateTime.UtcNow });
        await db.SaveChangesAsync();
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "GetAlertsAsync", device.Id, Principal(), db, new DeviceAlertHistoryQuery("active"));
        var page = Assert.IsType<DeviceAlertPage>(Value(result));
        Assert.Equal(1, page.TotalCount);
        Assert.Equal("HIGH_TEMPERATURE", Assert.Single(page.Items).Type);
        Assert.Equal(404, Status(await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "GetAlertsAsync", device.Id, Principal("other"), db, new DeviceAlertHistoryQuery())));
    }

    [Fact]
    public async Task Pump_history_filters_date_range_and_projects_failures_in_descending_order()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        db.PumpCommands.AddRange(new PumpCommand { DeviceId = device.Id, IssuedAt = start, Status = PumpCommandStatus.Failed, FailureReason = "QA_FAILURE" },
            new PumpCommand { DeviceId = device.Id, IssuedAt = start.AddHours(1), Status = PumpCommandStatus.Acknowledged },
            new PumpCommand { DeviceId = device.Id, IssuedAt = start.AddDays(-1) });
        await db.SaveChangesAsync();
        var query = new PumpCommandHistoryQuery(new DateTimeOffset(start), new DateTimeOffset(start.AddDays(1)));
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "GetPumpCommandsAsync", device.Id, Principal(), db, query);
        var page = Assert.IsType<PumpCommandHistoryPage>(Value(result));
        Assert.Equal(2, page.TotalCount);
        Assert.Equal(start.AddHours(1), page.Items[0].IssuedAt);
        Assert.Equal("QA_FAILURE", page.Items[1].FailureReason);
    }

    [Fact]
    public async Task Ticket_create_reply_transition_and_search_persist_messages_and_audit()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await SeedDevice(db);
        var owner = await db.Users.SingleAsync();
        var admin = new ApplicationUser { Id = "qa-admin", FullName = "QA Admin" };
        db.Users.Add(admin);
        await db.SaveChangesAsync();
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByIdAsync(owner.Id)).ReturnsAsync(owner);
        users.Setup(u => u.FindByIdAsync(admin.Id)).ReturnsAsync(admin);
        var created = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "CreateAsync", new CreateSupportTicketRequest("  Pump help  ", "  Initial message  "), Principal(), db, users.Object);
        Assert.Equal(201, Status(created));
        var ticket = Assert.IsType<SupportTicketDetailResponse>(Value(created));
        Assert.Equal("Pump help", ticket.Ticket.Subject);
        Assert.Equal("Initial message", Assert.Single(ticket.Messages).Message);
        Assert.False(ticket.Messages[0].IsAdmin);
        var reply = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "ReplyAsync", ticket.Ticket.Id, new AddSupportTicketMessageRequest("  QA reply  "), Principal(admin.Id), db, users.Object);
        var detail = Assert.IsType<SupportTicketDetailResponse>(Value(reply));
        Assert.Equal(2, detail.Messages.Count);
        Assert.True(detail.Messages.Last().IsAdmin);
        Assert.Equal("QA reply", detail.Messages.Last().Message);
        var status = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "UpdateStatusAsync", ticket.Ticket.Id, new UpdateSupportTicketStatusRequest(" IN_PROGRESS "), Principal(admin.Id), db);
        Assert.Equal("in_progress", Assert.IsType<SupportTicketDetailResponse>(Value(status)).Ticket.Status);
        var priority = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "UpdatePriorityAsync", ticket.Ticket.Id, new UpdateSupportTicketPriorityRequest(" HIGH "), Principal(admin.Id), db);
        Assert.Equal("high", Assert.IsType<SupportTicketDetailResponse>(Value(priority)).Ticket.Priority);
        var listed = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "ListAsync", db, "in_progress", "PUMP", 1, 50);
        Assert.Equal(1, Assert.IsType<SupportTicketPage>(Value(listed)).TotalCount);
        Assert.Equal(3, await db.AdminAuditLogs.CountAsync());
    }

    [Fact]
    public async Task Dashboard_includes_only_owners_devices_latest_readings_and_active_alerts()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var first = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        db.SensorReadings.AddRange(new SensorReading { DeviceId = device.Id, RecordedAt = first, Temperature = 10 }, new SensorReading { DeviceId = device.Id, RecordedAt = first.AddHours(1), Temperature = 30 });
        db.DeviceAlerts.Add(new DeviceAlert { DeviceId = device.Id, Type = DeviceAlertType.HighTemperature });
        db.Devices.Add(new Device { Name = "Unowned", DeviceKey = "qa-other" });
        await db.SaveChangesAsync();
        var result = await BackendTestDoubles.InvokeHandler(typeof(DashboardEndpoints), "GetOverviewAsync", Principal(), db);
        var overview = Assert.Single(Assert.IsAssignableFrom<IEnumerable<DeviceOverviewResponse>>(Value(result)));
        Assert.Equal(device.Id, overview.DeviceId);
        Assert.Equal(30, overview.LatestReading!.Temperature);
        Assert.Single(overview.ActiveAlerts);
    }

    [Fact]
    public async Task Admin_report_csv_and_alert_default_update_reflect_real_persisted_state()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        device.IsOnline = true;
        await db.SaveChangesAsync();
        var update = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "UpdateAlertDefaultsAsync", new UpdateSystemAlertDefaultsRequest(41, 17), Principal(), db);
        Assert.Equal(41, Assert.IsType<SystemAlertDefaultsResponse>(Value(update)).HighTemperatureC);
        Assert.Equal(1, await db.SystemAlertDefaults.CountAsync());
        Assert.Equal("settings.alert-defaults.updated", (await db.AdminAuditLogs.SingleAsync()).Action);
        var overview = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "GetOverviewAsync", db);
        var data = Assert.IsType<AdminOverviewResponse>(Value(overview));
        Assert.Equal(1, data.Users);
        Assert.Equal(1, data.Devices);
        Assert.Equal(1, data.OnlineDevices);
        var csv = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "DownloadReportCsvAsync", db);
        var file = Assert.IsType<Microsoft.AspNetCore.Http.HttpResults.FileContentHttpResult>(csv);
        Assert.Equal("admin-report.csv", file.FileDownloadName);
        Assert.Contains("devices.online,1\r\n", Encoding.UTF8.GetString(file.FileContents.Span));
    }

    [Fact]
    public async Task Sequential_schedule_crud_rejects_overlap_and_preserves_owned_transaction()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var config = new ConfigurationBuilder().Build();
        var request = new PumpScheduleRequest(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok");
        var create = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "CreatePumpScheduleAsync", device.Id, request, Principal(), db, config);
        Assert.Equal(201, Status(create));
        var saved = Assert.IsType<PumpScheduleResponse>(Value(create));
        var overlap = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "CreatePumpScheduleAsync", device.Id, request, Principal(), db, config);
        Assert.Equal(400, Status(overlap));
        var update = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "UpdatePumpScheduleAsync", device.Id, saved.Id, request with { StartTime = new TimeOnly(7, 0) }, Principal(), db, config);
        Assert.Equal(new TimeOnly(7, 0), Assert.IsType<PumpScheduleResponse>(Value(update)).StartTime);
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "DeletePumpScheduleAsync", device.Id, saved.Id, Principal(), db)));
        Assert.Empty(await db.PumpSchedules.ToListAsync());
    }

    [Fact]
    public async Task Light_schedule_crud_persists_an_owned_recurrence()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var config = new ConfigurationBuilder().Build();
        var request = new LightScheduleRequest(true, 1, new TimeOnly(18, 0), 3_600, "Asia/Bangkok");

        var create = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "CreateLightScheduleAsync", device.Id, request, Principal(), db, config);

        Assert.Equal(201, Status(create));
        var saved = Assert.IsType<LightScheduleResponse>(Value(create));
        Assert.Equal(new TimeOnly(18, 0), saved.StartTime);
        Assert.Equal(3_600, saved.DurationSeconds);
        Assert.Equal(1, await db.LightSchedules.CountAsync());
        Assert.Equal(204, Status(await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), "DeleteLightScheduleAsync", device.Id, saved.Id, Principal(), db)));
    }

    [Fact]
    public async Task Mqtt_reading_adapter_persists_presence_triggers_alerts_and_resolves_safe_reading()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await SeedDevice(db);
        using var services = new ServiceCollection().AddDbContext<ApplicationDbContext>(o => o.UseNpgsql(db.Database.GetConnectionString())).BuildServiceProvider();
        using var mqtt = new MqttIngestionService(services.GetRequiredService<IServiceScopeFactory>(), new ConfigurationBuilder().Build(), NullLogger<MqttIngestionService>.Instance);
        var process = typeof(MqttIngestionService).GetMethod("ProcessReadingAsync", BindingFlags.Instance | BindingFlags.NonPublic)!;
        await (Task)process.Invoke(mqtt, new object[] { "qa-device-key", Encoding.UTF8.GetBytes("{\"temperature\":40,\"waterLevel\":10}") })!;
        db.ChangeTracker.Clear();
        Assert.Equal(2, await db.DeviceAlerts.CountAsync(a => a.ResolvedAt == null));
        Assert.True((await db.Devices.SingleAsync()).IsOnline);
        await (Task)process.Invoke(mqtt, new object[] { "qa-device-key", Encoding.UTF8.GetBytes("{\"temperature\":20,\"waterLevel\":80}") })!;
        db.ChangeTracker.Clear();
        Assert.Equal(2, await db.SensorReadings.CountAsync());
        Assert.Equal(2, await db.DeviceAlerts.CountAsync(a => a.ResolvedAt != null));
        Assert.False(mqtt.IsConnected); // adapter integration, not broker transport
    }

    [Fact]
    public async Task Mqtt_pump_acknowledgement_persists_failed_status_and_reason()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var command = new PumpCommand { DeviceId = device.Id, IsOn = true };
        db.PumpCommands.Add(command);
        await db.SaveChangesAsync();
        using var services = new ServiceCollection().AddDbContext<ApplicationDbContext>(o => o.UseNpgsql(db.Database.GetConnectionString())).BuildServiceProvider();
        using var mqtt = new MqttIngestionService(services.GetRequiredService<IServiceScopeFactory>(), new ConfigurationBuilder().Build(), NullLogger<MqttIngestionService>.Instance);
        var payload = Encoding.UTF8.GetBytes("{\"commandId\":\"" + command.Id + "\",\"isOn\":false,\"success\":false,\"reason\":\" LOW_WATER \"}");
        await (Task)typeof(MqttIngestionService).GetMethod("ProcessPumpStatusAsync", BindingFlags.Instance | BindingFlags.NonPublic)!.Invoke(mqtt, new object[] { "qa-device-key", payload, "devices/qa-device-key/pump-status" })!;
        db.ChangeTracker.Clear();
        var saved = await db.PumpCommands.SingleAsync();
        Assert.Equal(PumpCommandStatus.Failed, saved.Status);
        Assert.Equal("LOW_WATER", saved.FailureReason);
        Assert.NotNull(saved.AcknowledgedAt);
        Assert.False(saved.AcknowledgedIsOn);
    }

    [Fact]
    public async Task Provisioning_concurrent_claims_allow_exactly_one_success()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var issued = await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "CreateCodeAsync", device.Id, Principal(), db);
        var code = Assert.IsType<CreateProvisioningCodeResponse>(Value(issued)).Code;
        var options = new DbContextOptionsBuilder<ApplicationDbContext>().UseNpgsql(db.Database.GetConnectionString()).Options;
        await using var first = new ApplicationDbContext(options);
        await using var second = new ApplicationDbContext(options);
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["DeviceProvisioning:MqttHost"] = "qa-broker" }).Build();
        var broker = new TestMqttBrokerAdminService();
        var results = await Task.WhenAll(BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", new ClaimDeviceRequest(code, "FIRST"), first, config, broker, CancellationToken.None),
            BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", new ClaimDeviceRequest(code, "SECOND"), second, config, broker, CancellationToken.None));
        Assert.Single(results, r => Status(r) == 200);
        Assert.Single(results, r => Status(r) is 400 or 409);
        db.ChangeTracker.Clear();
        Assert.Contains((await db.Devices.SingleAsync()).ProvisionedHardwareId, new[] { "FIRST", "SECOND" });
    }

    [Fact]
    public async Task All_migrations_can_roll_back_on_empty_disposable_database()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await db.Database.MigrateAsync("0");
        Assert.Empty(await db.Database.GetAppliedMigrationsAsync());
    }

    [Fact]
    public async Task Scheduler_claim_is_idempotent_and_disconnected_publish_stays_pending_for_retry()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        var device = await SeedDevice(db);
        var schedule = new PumpSchedule { DeviceId = device.Id, WeekdayMask = 127, StartTime = new TimeOnly(6, 0), DurationSeconds = 60, TimeZone = "Asia/Bangkok" };
        db.PumpSchedules.Add(schedule);
        await db.SaveChangesAsync();
        using var services = new ServiceCollection().AddDbContext<ApplicationDbContext>(o => o.UseNpgsql(db.Database.GetConnectionString())).BuildServiceProvider();
        var scopes = services.GetRequiredService<IServiceScopeFactory>();
        using var mqtt = new MqttIngestionService(scopes, new ConfigurationBuilder().Build(), NullLogger<MqttIngestionService>.Instance);
        using var scheduler = new PumpScheduleDispatchService(scopes, new ConfigurationBuilder().Build(), mqtt, NullLogger<PumpScheduleDispatchService>.Instance);
        var claim = typeof(PumpScheduleDispatchService).GetMethod("ClaimAndPublishAsync", BindingFlags.Instance | BindingFlags.NonPublic)!;
        var occurrence = DateTime.UtcNow.AddSeconds(-5);
        await (Task)claim.Invoke(scheduler, new object[] { schedule.Id, occurrence, System.Threading.CancellationToken.None })!;
        await (Task)claim.Invoke(scheduler, new object[] { schedule.Id, occurrence, System.Threading.CancellationToken.None })!;
        db.ChangeTracker.Clear();
        var pending = await db.PumpScheduleOccurrences.SingleAsync();
        Assert.Null(pending.DispatchedAt);
        Assert.Equal(occurrence.Ticks / 10, pending.OccurrenceUtc.Ticks / 10);
        var command = await db.PumpCommands.SingleAsync();
        Assert.Equal(pending.CommandId, command.Id);
        Assert.Equal(PumpCommandSource.Scheduled, command.Source);
        Assert.Equal(occurrence.Ticks / 10, command.IssuedAt.Ticks / 10); // PostgreSQL microseconds
        Assert.Equal(PumpCommandStatus.Pending, command.Status);
        Assert.False(mqtt.IsConnected);

        command.IssuedAt = DateTime.UtcNow.AddMinutes(-10);
        await db.SaveChangesAsync();
        await (Task)typeof(PumpScheduleDispatchService).GetMethod("PublishAsync", BindingFlags.Instance | BindingFlags.NonPublic)!
            .Invoke(scheduler, new object[] { pending.Id, System.Threading.CancellationToken.None })!;
        db.ChangeTracker.Clear();
        Assert.Equal("SCHEDULE_EXPIRED", (await db.PumpCommands.SingleAsync()).FailureReason);
        Assert.NotNull((await db.PumpScheduleOccurrences.SingleAsync()).DispatchedAt);
    }

    [Fact]
    public async Task Ticket_status_and_priority_updates_persist_audit_without_reply_dependency()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await SeedDevice(db);
        var user = await db.Users.SingleAsync();
        var ticket = new SupportTicket { UserId = user.Id, Subject = "QA Status" };
        db.SupportTickets.Add(ticket);
        await db.SaveChangesAsync();
        var status = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "UpdateStatusAsync", ticket.Id, new UpdateSupportTicketStatusRequest(" IN_PROGRESS "), Principal(), db);
        Assert.Equal("in_progress", Assert.IsType<SupportTicketDetailResponse>(Value(status)).Ticket.Status);
        var priority = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "UpdatePriorityAsync", ticket.Id, new UpdateSupportTicketPriorityRequest(" HIGH "), Principal(), db);
        Assert.Equal("high", Assert.IsType<SupportTicketDetailResponse>(Value(priority)).Ticket.Priority);
        Assert.Equal(2, await db.AdminAuditLogs.CountAsync());
        var listed = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "ListAsync", db, "in_progress", "STATUS", 1, 50);
        Assert.Equal(1, Assert.IsType<SupportTicketPage>(Value(listed)).TotalCount);
    }
}
