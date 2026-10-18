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
        var request = JsonSerializer.Deserialize<LightCommandRequest>("""{"isOn":true}""", JsonOptions);

        Assert.NotNull(request);
        Assert.True(request.IsOn);
    }

    [Fact]
    public void Message_serializes_is_on_camel_case()
    {
        var json = JsonSerializer.Serialize(new LightCommandMessage(false), JsonOptions);

        Assert.Equal("""{"isOn":false}""", json);
    }
}
