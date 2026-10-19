namespace IOTAgriBackend.Services;

public interface IMqttBrokerAdminService
{
    Task<ProvisionedMqttDevice> ReplaceDeviceAsync(string deviceKey, string hardwareId, CancellationToken cancellationToken);
    Task RemoveDeviceAsync(string deviceKey, CancellationToken cancellationToken);
}

public sealed record ProvisionedMqttDevice(string Username, string Password, string ClientId);

public sealed class MqttBrokerAdminException(string message) : Exception(message);
