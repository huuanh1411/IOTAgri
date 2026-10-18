using System.Reflection;
using System.Text;
using IOTAgriBackend.Dtos.Lights;
using IOTAgriBackend.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace IOTAgriBackend.Tests;

public class LightMqttMessageTests
{
    [Fact]
    public void Light_status_updates_runtime_state_for_the_matching_device_key()
    {
        using var services = new ServiceCollection().BuildServiceProvider();
        using var mqtt = new MqttIngestionService(
            services.GetRequiredService<IServiceScopeFactory>(),
            new ConfigurationBuilder().Build(),
            NullLogger<MqttIngestionService>.Instance);
        var process = typeof(MqttIngestionService).GetMethod(
            "ProcessLightStatus",
            BindingFlags.Instance | BindingFlags.NonPublic)!;

        process.Invoke(mqtt, new object[]
        {
            "mock-device",
            Encoding.UTF8.GetBytes("{\"commandId\":null,\"isOn\":true,\"success\":true}"),
            "devices/mock-device/light-status",
        });

        var status = mqtt.GetLightStatus("mock-device");
        Assert.True(status.IsAvailable);
        Assert.True(status.IsOn);
        Assert.NotNull(status.UpdatedAt);
    }

    [Fact]
    public void Failed_light_status_does_not_replace_the_last_acknowledged_state()
    {
        using var services = new ServiceCollection().BuildServiceProvider();
        using var mqtt = new MqttIngestionService(
            services.GetRequiredService<IServiceScopeFactory>(),
            new ConfigurationBuilder().Build(),
            NullLogger<MqttIngestionService>.Instance);
        var process = typeof(MqttIngestionService).GetMethod(
            "ProcessLightStatus",
            BindingFlags.Instance | BindingFlags.NonPublic)!;

        process.Invoke(mqtt, new object[]
        {
            "mock-device",
            Encoding.UTF8.GetBytes("{\"isOn\":true,\"success\":false,\"reason\":\"REJECTED\"}"),
            "devices/mock-device/light-status",
        });

        Assert.False(mqtt.GetLightStatus("mock-device").IsAvailable);
    }
}
