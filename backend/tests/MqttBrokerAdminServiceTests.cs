using System.Text.Json;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class MqttBrokerAdminServiceTests
{
    [Fact]
    public async Task Replace_device_creates_exact_client_after_ignoring_missing_old_client()
    {
        var transport = new FakeDynsecTransport(
            """{"responses":[{"command":"deleteClient","error":"Client not found"}]}""",
            """{"responses":[{"command":"createClient"}]}""");
        var service = new MqttBrokerAdminService(transport, new MqttBrokerAdminOptions { DeviceRole = "device" });

        var provisioned = await service.ReplaceDeviceAsync("device-key", "ABCDEF0123456789", CancellationToken.None);

        Assert.Equal("device-key", provisioned.Username);
        Assert.Equal("iotagr-ABCDEF0123456789", provisioned.ClientId);
        Assert.NotEmpty(provisioned.Password);
        var create = JsonDocument.Parse(transport.Requests[1]).RootElement.GetProperty("commands")[0];
        Assert.Equal("createClient", create.GetProperty("command").GetString());
        Assert.Equal("device-key", create.GetProperty("username").GetString());
        Assert.Equal("iotagr-ABCDEF0123456789", create.GetProperty("clientid").GetString());
        Assert.Equal("device", create.GetProperty("roles")[0].GetProperty("rolename").GetString());
    }

    [Fact]
    public async Task Create_failure_does_not_include_generated_password_in_exception()
    {
        var transport = new FakeDynsecTransport(
            """{"responses":[{"command":"deleteClient","error":"Client not found"}]}""",
            """{"responses":[{"command":"createClient","error":"Denied"}]}""");
        var service = new MqttBrokerAdminService(transport, new MqttBrokerAdminOptions());

        var error = await Assert.ThrowsAsync<MqttBrokerAdminException>(() =>
            service.ReplaceDeviceAsync("device-key", "ABCDEF0123456789", CancellationToken.None));

        Assert.DoesNotContain("password", error.Message, System.StringComparison.OrdinalIgnoreCase);
    }

    private sealed class FakeDynsecTransport(params string[] responses) : IMqttDynsecTransport
    {
        private int _next;
        public List<string> Requests { get; } = [];

        public Task<string> SendAsync(string requestJson, CancellationToken cancellationToken)
        {
            Requests.Add(requestJson);
            return Task.FromResult(responses[_next++]);
        }
    }
}
