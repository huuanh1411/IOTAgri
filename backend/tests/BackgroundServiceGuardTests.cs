using System;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Xunit;

namespace IOTAgriBackend.Tests;

public class BackgroundServiceGuardTests
{
    private static MqttIngestionService Mqtt(IServiceScopeFactory scopes) => new(scopes, new ConfigurationBuilder().Build(), NullLogger<MqttIngestionService>.Instance);

    [Fact]
    public async Task Disconnected_publish_throws_without_scope_or_broker_connection()
    {
        var scopes = new Mock<IServiceScopeFactory>(MockBehavior.Strict);
        using var mqtt = Mqtt(scopes.Object);
        Assert.False(mqtt.IsConnected);
        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => mqtt.PublishPumpCommandAsync("qa-key", new PumpCommand(), CancellationToken.None));
        Assert.Equal("MQTT client is not connected.", error.Message);
        scopes.Verify(s => s.CreateScope(), Times.Never);
    }

    [Theory]
    [InlineData("ProcessReadingAsync")]
    [InlineData("ProcessPumpStatusAsync")]
    public async Task Null_json_payload_is_ignored_before_database_scope(string method)
    {
        var scopes = new Mock<IServiceScopeFactory>(MockBehavior.Strict);
        using var mqtt = Mqtt(scopes.Object);
        var args = method == "ProcessReadingAsync"
            ? new object[] { "qa-key", Encoding.UTF8.GetBytes("null") }
            : new object[] { "qa-key", Encoding.UTF8.GetBytes("null"), "devices/qa-key/pump-status" };
        await (Task)typeof(MqttIngestionService).GetMethod(method, BindingFlags.Instance | BindingFlags.NonPublic)!.Invoke(mqtt, args)!;
        scopes.Verify(s => s.CreateScope(), Times.Never);
        Assert.False(mqtt.IsConnected);
    }

    [Fact]
    public async Task Oversized_pump_status_is_ignored_before_parsing_or_database_scope()
    {
        var scopes = new Mock<IServiceScopeFactory>(MockBehavior.Strict);
        using var mqtt = Mqtt(scopes.Object);
        await (Task)typeof(MqttIngestionService).GetMethod("ProcessPumpStatusAsync", BindingFlags.Instance | BindingFlags.NonPublic)!
            .Invoke(mqtt, new object[] { "qa-key", new byte[1025], "devices/qa-key/pump-status" })!;
        scopes.Verify(s => s.CreateScope(), Times.Never);
    }

    [Fact]
    public async Task Disabled_scheduler_completes_without_database_or_mqtt_access()
    {
        var scopes = new Mock<IServiceScopeFactory>(MockBehavior.Strict);
        using var mqtt = Mqtt(scopes.Object);
        using var scheduler = new PumpScheduleDispatchService(scopes.Object, new ConfigurationBuilder().Build(), mqtt, NullLogger<PumpScheduleDispatchService>.Instance);
        await scheduler.StartAsync(CancellationToken.None);
        Assert.NotNull(scheduler.ExecuteTask);
        await scheduler.ExecuteTask;
        await scheduler.StopAsync(CancellationToken.None);
        scopes.Verify(s => s.CreateScope(), Times.Never);
        Assert.False(mqtt.IsConnected);
    }
}
