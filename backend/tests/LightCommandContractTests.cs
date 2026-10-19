using System;
using System.Text.Json;
using IOTAgriBackend.Dtos.Lights;
using Xunit;

namespace IOTAgriBackend.Tests;

public class LightCommandContractTests
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    [Fact]
    public void Request_binds_is_on_camel_case()
    {
        var request = JsonSerializer.Deserialize<LightCommandRequest>("""{"commandId":"c10eb93e-a070-4e1d-9b52-49c32c8ee8d3","isOn":true}""", JsonOptions);

        Assert.NotNull(request);
        Assert.Equal(Guid.Parse("c10eb93e-a070-4e1d-9b52-49c32c8ee8d3"), request.CommandId);
        Assert.True(request.IsOn);
    }

    [Fact]
    public void Message_serializes_is_on_camel_case()
    {
        var json = JsonSerializer.Serialize(new LightCommandMessage(Guid.Parse("c10eb93e-a070-4e1d-9b52-49c32c8ee8d3"), false), JsonOptions);

        Assert.Equal("""{"commandId":"c10eb93e-a070-4e1d-9b52-49c32c8ee8d3","isOn":false}""", json);
    }
}
