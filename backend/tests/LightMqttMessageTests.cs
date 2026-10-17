using System;
using System.Text.Json;
using IOTAgriBackend.Dtos.Lights;
using Xunit;

namespace IOTAgriBackend.Tests;

public class LightMqttMessageTests
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    [Fact]
    public void Command_serializes_with_the_firmware_contract()
    {
        var id = Guid.Parse("ad2ff566-68e4-4e96-a799-9bb617c0e491");

        var json = JsonSerializer.Serialize(new LightCommandMessage(id, true), JsonOptions);

        Assert.Equal(
            "{\"commandId\":\"ad2ff566-68e4-4e96-a799-9bb617c0e491\",\"isOn\":true}",
            json);
    }

    [Fact]
    public void Command_requires_a_non_empty_id()
    {
        Assert.False(new LightCommandRequest(Guid.Empty, true).IsValid);
        Assert.True(new LightCommandRequest(Guid.NewGuid(), false).IsValid);
    }

    [Fact]
    public void Status_deserializes_from_the_firmware_contract()
    {
        var status = JsonSerializer.Deserialize<LightStatusMessage>(
            """{"commandId":"ad2ff566-68e4-4e96-a799-9bb617c0e491","isOn":true,"success":true}""",
            JsonOptions);

        Assert.NotNull(status);
        Assert.True(status.IsOn);
        Assert.True(status.Success);
    }
}
