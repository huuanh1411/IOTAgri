using System.Security.Claims;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Devices;
using IOTAgriBackend.Services;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Endpoints;

public static class DeviceProvisioningEndpoints
{
    private static readonly TimeSpan CodeLifetime = TimeSpan.FromMinutes(15);
    private static readonly TimeSpan ClaimLeaseLifetime = TimeSpan.FromMinutes(1);

    public static IEndpointRouteBuilder MapDeviceProvisioningEndpoints(this IEndpointRouteBuilder app)
    {
        app.MapPost("/api/devices/{deviceId:guid}/provisioning-code", CreateCodeAsync)
            .WithTags("Devices")
            .RequireAuthorization();
        app.MapPost("/api/device-provisioning/claims", ClaimAsync)
            .WithTags("Device provisioning")
            .RequireRateLimiting("deviceClaims");

        return app;
    }

    private static async Task<IResult> CreateCodeAsync(
        Guid deviceId,
        ClaimsPrincipal principal,
        ApplicationDbContext db)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        var device = await db.Devices.FirstOrDefaultAsync(d => d.Id == deviceId && d.OwnerId == userId);
        if (device is null) return Results.NotFound();

        var code = ProvisioningCode.Create();
        var expiresAt = DateTime.UtcNow.Add(CodeLifetime);
        device.ProvisioningCodeHash = ProvisioningCode.Hash(code);
        device.ProvisioningCodeExpiresAt = expiresAt;
        device.ProvisionedAt = null;
        device.ProvisionedHardwareId = null;
        await db.SaveChangesAsync();

        return Results.Ok(new CreateProvisioningCodeResponse(code, expiresAt));
    }

    private static async Task<IResult> ClaimAsync(
        ClaimDeviceRequest request,
        ApplicationDbContext db,
        IConfiguration configuration,
        IMqttBrokerAdminService brokerAdmin,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Code) || request.Code.Length > 64 ||
            string.IsNullOrWhiteSpace(request.HardwareId) || request.HardwareId.Length > 128)
            return Results.BadRequest(new { error = "Code and hardwareId are required." });

        var mqttHost = configuration["DeviceProvisioning:MqttHost"];
        if (string.IsNullOrWhiteSpace(mqttHost))
            return Results.Problem("DeviceProvisioning:MqttHost is not configured.", statusCode: StatusCodes.Status503ServiceUnavailable);

        var now = DateTime.UtcNow;
        var hash = ProvisioningCode.Hash(request.Code.Trim().ToUpperInvariant());
        var hardwareId = request.HardwareId.Trim().ToUpperInvariant();
        var leaseId = Guid.NewGuid();
        var reserved = await db.Devices
            .Where(d => d.ProvisioningCodeHash == hash
                && d.ProvisioningCodeExpiresAt > now
                && d.ProvisionedAt == null
                && (d.ProvisioningClaimLeaseExpiresAt == null || d.ProvisioningClaimLeaseExpiresAt <= now))
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(d => d.ProvisioningClaimLeaseId, leaseId)
                .SetProperty(d => d.ProvisioningClaimLeaseExpiresAt, now.Add(ClaimLeaseLifetime)), cancellationToken);
        if (reserved != 1) return Results.BadRequest(new { error = "Provisioning code is invalid, expired, or already being claimed." });

        var device = await db.Devices.SingleAsync(d => d.ProvisioningClaimLeaseId == leaseId, cancellationToken);

        ProvisionedMqttDevice credentials;
        try
        {
            credentials = await brokerAdmin.ReplaceDeviceAsync(device.DeviceKey, hardwareId, cancellationToken);
        }
        catch (MqttBrokerAdminException)
        {
            await ClearLeaseAsync(db, leaseId, cancellationToken);
            return Results.Problem("Device broker provisioning is unavailable.", statusCode: StatusCodes.Status503ServiceUnavailable);
        }

        var claimed = await db.Devices
            .Where(d => d.Id == device.Id && d.ProvisioningClaimLeaseId == leaseId && d.ProvisionedAt == null)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(d => d.ProvisionedAt, now)
                .SetProperty(d => d.ProvisionedHardwareId, hardwareId)
                .SetProperty(d => d.ProvisioningCodeHash, (string?)null)
                .SetProperty(d => d.ProvisioningCodeExpiresAt, (DateTime?)null)
                .SetProperty(d => d.ProvisioningClaimLeaseId, (Guid?)null)
                .SetProperty(d => d.ProvisioningClaimLeaseExpiresAt, (DateTime?)null), cancellationToken);
        if (claimed != 1)
        {
            try { await brokerAdmin.RemoveDeviceAsync(device.DeviceKey, CancellationToken.None); }
            finally { await ClearLeaseAsync(db, leaseId, CancellationToken.None); }
            return Results.Conflict(new { error = "Provisioning code was already claimed." });
        }

        return Results.Ok(new ClaimDeviceResponse(
            device.DeviceKey,
            mqttHost,
            configuration.GetValue<int?>("Mqtt:Port") ?? 1883,
            configuration.GetValue<bool>("Mqtt:UseTls"),
            credentials.Username,
            credentials.Password,
            credentials.ClientId));
    }

    private static Task ClearLeaseAsync(ApplicationDbContext db, Guid leaseId, CancellationToken cancellationToken) =>
        db.Devices.Where(d => d.ProvisioningClaimLeaseId == leaseId)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(d => d.ProvisioningClaimLeaseId, (Guid?)null)
                .SetProperty(d => d.ProvisioningClaimLeaseExpiresAt, (DateTime?)null), cancellationToken);
}
