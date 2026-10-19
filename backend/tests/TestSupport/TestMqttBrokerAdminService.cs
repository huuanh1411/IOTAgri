using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Services;

namespace IOTAgriBackend.Tests;

internal sealed class TestMqttBrokerAdminService : IMqttBrokerAdminService
{
    public List<string> ReplacedDeviceKeys { get; } = [];
    public List<string> RemovedDeviceKeys { get; } = [];

    public Task<ProvisionedMqttDevice> ReplaceDeviceAsync(string deviceKey, string hardwareId, CancellationToken cancellationToken)
    {
        ReplacedDeviceKeys.Add(deviceKey);
        return Task.FromResult(new ProvisionedMqttDevice(deviceKey, "test-device-password", $"iotagr-{hardwareId}"));
    }

    public Task RemoveDeviceAsync(string deviceKey, CancellationToken cancellationToken)
    {
        RemovedDeviceKeys.Add(deviceKey);
        return Task.CompletedTask;
    }
}
