using System.Security.Cryptography;
using System.Text.Json;

namespace IOTAgriBackend.Services;

public sealed class MqttBrokerAdminOptions
{
    public string DeviceRole { get; init; } = "device";
}

public sealed class MqttBrokerAdminService(IMqttDynsecTransport transport, MqttBrokerAdminOptions options) : IMqttBrokerAdminService
{
    public async Task<ProvisionedMqttDevice> ReplaceDeviceAsync(
        string deviceKey,
        string hardwareId,
        CancellationToken cancellationToken)
    {
        Validate(deviceKey, hardwareId);
        var clientId = $"iotagr-{hardwareId}";

        await SendCommandAsync(new
        {
            command = "deleteClient",
            username = deviceKey,
            correlationData = Guid.NewGuid().ToString("N")
        }, ignoreMissingClient: true, cancellationToken);

        var password = CreatePassword();
        await SendCommandAsync(new
        {
            command = "createClient",
            username = deviceKey,
            password,
            clientid = clientId,
            roles = new[] { new { rolename = options.DeviceRole, priority = 10 } },
            correlationData = Guid.NewGuid().ToString("N")
        }, ignoreMissingClient: false, cancellationToken);

        return new ProvisionedMqttDevice(deviceKey, password, clientId);
    }

    public Task RemoveDeviceAsync(string deviceKey, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(deviceKey))
        {
            throw new ArgumentException("Device key is required.", nameof(deviceKey));
        }

        return SendCommandAsync(new
        {
            command = "deleteClient",
            username = deviceKey,
            correlationData = Guid.NewGuid().ToString("N")
        }, ignoreMissingClient: true, cancellationToken);
    }

    private async Task SendCommandAsync(object command, bool ignoreMissingClient, CancellationToken cancellationToken)
    {
        var request = JsonSerializer.Serialize(new { commands = new[] { command } });
        var response = await transport.SendAsync(request, cancellationToken);
        using var document = JsonDocument.Parse(response);
        var item = document.RootElement.GetProperty("responses")[0];
        if (!item.TryGetProperty("error", out var error)) return;

        var message = error.GetString() ?? "Broker rejected Dynamic Security command.";
        if (ignoreMissingClient && message == "Client not found") return;
        throw new MqttBrokerAdminException("Broker rejected Dynamic Security command.");
    }

    private static void Validate(string deviceKey, string hardwareId)
    {
        if (string.IsNullOrWhiteSpace(deviceKey))
        {
            throw new ArgumentException("Device key is required.", nameof(deviceKey));
        }

        if (hardwareId.Length != 16 || !hardwareId.All(Uri.IsHexDigit))
        {
            throw new ArgumentException("Hardware ID must be 16 hexadecimal characters.", nameof(hardwareId));
        }
    }

    private static string CreatePassword() => Convert.ToBase64String(RandomNumberGenerator.GetBytes(32))
        .TrimEnd('=')
        .Replace('+', '-')
        .Replace('/', '_');
}
