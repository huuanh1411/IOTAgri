using System;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Dtos.Admin;
using IOTAgriBackend.Dtos.Auth;
using IOTAgriBackend.Dtos.Devices;
using IOTAgriBackend.Dtos.Tickets;
using IOTAgriBackend.Endpoints;
using Microsoft.AspNetCore.Http;
using Xunit;

namespace IOTAgriBackend.Tests;

public class EndpointGuardTests
{
    private static readonly ClaimsPrincipal Anonymous = new(new ClaimsIdentity());
    private static ClaimsPrincipal Actor() => new(new ClaimsIdentity(new[] { new Claim(ClaimTypes.NameIdentifier, "qa-user") }, "test"));

    [Theory]
    [InlineData("CreateAsync")]
    [InlineData("ListAsync")]
    [InlineData("GetAsync")]
    [InlineData("UpdateAsync")]
    [InlineData("DeleteAsync")]
    [InlineData("SendPumpCommandAsync")]
    [InlineData("GetPumpCommandsAsync")]
    [InlineData("ListPumpSchedulesAsync")]
    [InlineData("CreatePumpScheduleAsync")]
    [InlineData("UpdatePumpScheduleAsync")]
    [InlineData("DeletePumpScheduleAsync")]
    [InlineData("GetAlertSettingsAsync")]
    [InlineData("UpdateAlertSettingsAsync")]
    [InlineData("GetAlertsAsync")]
    public async Task Device_handlers_reject_missing_user_id_before_accessing_dependencies(string method)
    {
        object?[] args = method switch
        {
            "CreateAsync" => new object?[] { new CreateDeviceRequest("QA"), Anonymous, null },
            "ListAsync" => new object?[] { Anonymous, null },
            "UpdateAsync" or "UpdateAlertSettingsAsync" => new object?[] { Guid.Empty, null, Anonymous, null },
            "SendPumpCommandAsync" => new object?[] { Guid.Empty, null, Anonymous, null, null, null, CancellationToken.None },
            "GetPumpCommandsAsync" or "GetAlertsAsync" => new object?[] { Guid.Empty, Anonymous, null, null },
            "CreatePumpScheduleAsync" => new object?[] { Guid.Empty, null, Anonymous, null, null },
            "UpdatePumpScheduleAsync" => new object?[] { Guid.Empty, Guid.Empty, null, Anonymous, null, null },
            "DeletePumpScheduleAsync" => new object?[] { Guid.Empty, Guid.Empty, Anonymous, null },
            _ => new object?[] { Guid.Empty, Anonymous, null },
        };
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceEndpoints), method, args);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Theory]
    [InlineData("GetReadingsAsync")]
    [InlineData("GetAggregatedReadingsAsync")]
    [InlineData("GetHourlyMediansAsync")]
    [InlineData("GetDailyMediansAsync")]
    public async Task Sensor_handlers_reject_missing_identity_without_querying_database(string method)
    {
        object?[] args = method switch
        {
            "GetReadingsAsync" => new object?[] { Guid.Empty, Anonymous, null, 50 },
            "GetAggregatedReadingsAsync" => new object?[] { Guid.Empty, Anonymous, null, "hour", null, null },
            _ => new object?[] { Guid.Empty, new DateOnly(2026, 1, 5), Anonymous, null },
        };
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), method, args);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Fact]
    public async Task Dashboard_rejects_missing_identity_without_querying_database()
    {
        var result = await BackendTestDoubles.InvokeHandler(typeof(DashboardEndpoints), "GetOverviewAsync", Anonymous, null);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Theory]
    [InlineData("UpdateRoleAsync")]
    [InlineData("UpdateLockAsync")]
    [InlineData("UpdateDeviceOwnerAsync")]
    [InlineData("UpdateAlertDefaultsAsync")]
    public async Task Admin_mutations_reject_missing_actor_before_using_dependencies(string method)
    {
        object?[] args = method switch
        {
            "UpdateRoleAsync" or "UpdateLockAsync" => new object?[] { "target", null, Anonymous, null, null },
            "UpdateDeviceOwnerAsync" => new object?[] { Guid.Empty, null, Anonymous, null, null },
            _ => new object?[] { null, Anonymous, null },
        };
        var result = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), method, args);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Theory]
    [InlineData("CreateAsync")]
    [InlineData("UpdateStatusAsync")]
    [InlineData("UpdatePriorityAsync")]
    [InlineData("ReplyAsync")]
    public async Task Ticket_mutations_reject_missing_actor_before_using_dependencies(string method)
    {
        object?[] args = method switch
        {
            "CreateAsync" => new object?[] { null, Anonymous, null, null },
            "ReplyAsync" => new object?[] { Guid.Empty, null, Anonymous, null, null },
            _ => new object?[] { Guid.Empty, null, Anonymous, null },
        };
        var result = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), method, args);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Theory]
    [InlineData(0, 50)]
    [InlineData(1, 0)]
    [InlineData(1, 101)]
    public async Task Admin_lists_reject_invalid_pagination_before_accessing_database(int page, int size)
    {
        var userResult = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "ListUsersAsync", null, null, null, null, page, size);
        var deviceResult = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "ListDevicesAsync", null, null, null, page, size);
        var auditResult = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "ListAuditLogsAsync", null, null, null, null, page, size);
        foreach (var result in new[] { userResult, deviceResult, auditResult })
        {
            Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
            Assert.NotNull(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        }
    }

    [Theory]
    [InlineData(null, "message")]
    [InlineData("subject", null)]
    [InlineData("  ", "message")]
    [InlineData("subject", " ")]
    public async Task Ticket_creation_rejects_missing_text_before_user_lookup(string? subject, string? message)
    {
        var result = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "CreateAsync",
            new CreateSupportTicketRequest(subject, message), Actor(), null, null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Theory]
    [InlineData(201, 1)]
    [InlineData(1, 4001)]
    public async Task Ticket_creation_rejects_text_over_limits(int subjectLength, int messageLength)
    {
        var result = await BackendTestDoubles.InvokeHandler(typeof(TicketEndpoints), "CreateAsync",
            new CreateSupportTicketRequest(new string('s', subjectLength), new string('m', messageLength)), Actor(), null, null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Fact]
    public async Task Registration_missing_email_returns_validation_problem_without_user_store()
    {
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "RegisterAsync", new RegisterRequest("", "QaPassword1!", "QA"), null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        var problem = Assert.IsType<HttpValidationProblemDetails>(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        Assert.Contains("request", problem.Errors.Keys);
    }

    [Fact]
    public async Task Invalid_aggregation_interval_returns_bad_request_before_database_access()
    {
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), "GetAggregatedReadingsAsync", Guid.Empty, Actor(), null, "DROP TABLE", null, null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Contains("Invalid interval", Assert.IsType<string>(Assert.IsAssignableFrom<IValueHttpResult>(result).Value));
    }

    [Fact]
    public async Task Daily_medians_reject_non_monday_week_start()
    {
        var result = await BackendTestDoubles.InvokeHandler(typeof(SensorEndpoints), "GetDailyMediansAsync", Guid.Empty, new DateOnly(2026, 1, 6), Actor(), null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Theory]
    [InlineData(null, "hardware")]
    [InlineData("code", null)]
    [InlineData(" ", "hardware")]
    public async Task Provisioning_rejects_missing_code_or_hardware_without_database(string? code, string? hardware)
    {
        var result = await BackendTestDoubles.InvokeHandler(typeof(DeviceProvisioningEndpoints), "ClaimAsync", new ClaimDeviceRequest(code!, hardware!), null, null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Fact]
    public async Task Invalid_system_thresholds_return_bad_request_before_database_access()
    {
        var result = await BackendTestDoubles.InvokeHandler(typeof(AdminEndpoints), "UpdateAlertDefaultsAsync", new UpdateSystemAlertDefaultsRequest(35, 101), Actor(), null);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }
}
