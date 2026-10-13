using System;
using System.Text.Json;
using IOTAgriBackend.Dtos.Pumps;
using Xunit;

namespace IOTAgriBackend.Tests;

public class PumpMqttMessageExtendedTests
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    // PumpStatusMessage.NormalizedReason
    [Fact]
    public void Null_reason_normalizes_to_null()
    {
        var status = new PumpStatusMessage(null, true, null, null);

        Assert.Null(status.NormalizedReason);
    }

    [Fact]
    public void Empty_reason_normalizes_to_null()
    {
        var status = new PumpStatusMessage(null, true, null, "");

        Assert.Null(status.NormalizedReason);
    }

    [Fact]
    public void Whitespace_only_reason_normalizes_to_null()
    {
        var status = new PumpStatusMessage(null, true, null, "   ");

        Assert.Null(status.NormalizedReason);
    }

    [Fact]
    public void Reason_exceeding_512_chars_is_truncated_to_512()
    {
        var longReason = new string('X', 600);
        var status = new PumpStatusMessage(null, false, false, longReason);

        Assert.Equal(512, status.NormalizedReason!.Length);
    }

    [Fact]
    public void Reason_of_exactly_512_chars_is_not_truncated()
    {
        var exactReason = new string('X', 512);
        var status = new PumpStatusMessage(null, false, false, exactReason);

        Assert.Equal(512, status.NormalizedReason!.Length);
        Assert.Equal(exactReason, status.NormalizedReason);
    }

    // PumpStatusMessage.WasSuccessful
    [Fact]
    public void Explicit_success_false_marks_message_as_failed()
    {
        var status = new PumpStatusMessage(null, false, false, "TIMEOUT");

        Assert.False(status.WasSuccessful);
    }

    [Fact]
    public void Explicit_success_true_marks_message_as_successful()
    {
        var status = new PumpStatusMessage(null, true, true, null);

        Assert.True(status.WasSuccessful);
    }

    // PumpCommandMessage — serialization roundtrip
    [Fact]
    public void PumpCommandMessage_serializes_and_deserializes_correctly()
    {
        var commandId = Guid.NewGuid();
        var original = new PumpCommandMessage(commandId, true, 300);

        var json = JsonSerializer.Serialize(original, JsonOptions);
        var deserialized = JsonSerializer.Deserialize<PumpCommandMessage>(json, JsonOptions);

        Assert.NotNull(deserialized);
        Assert.Equal(commandId, deserialized.CommandId);
        Assert.True(deserialized.IsOn);
        Assert.Equal(300, deserialized.DurationSeconds);
    }

    [Fact]
    public void PumpCommandMessage_with_null_duration_serializes_correctly()
    {
        var original = new PumpCommandMessage(Guid.NewGuid(), false, null);

        var json = JsonSerializer.Serialize(original, JsonOptions);
        var deserialized = JsonSerializer.Deserialize<PumpCommandMessage>(json, JsonOptions);

        Assert.NotNull(deserialized);
        Assert.False(deserialized.IsOn);
        Assert.Null(deserialized.DurationSeconds);
    }
}
