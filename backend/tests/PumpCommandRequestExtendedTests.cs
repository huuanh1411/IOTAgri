using IOTAgriBackend.Dtos.Pumps;
using System;
using Xunit;

namespace IOTAgriBackend.Tests;

public class PumpCommandRequestExtendedTests
{
    // Boundary: duration at exact maximum
    [Fact]
    public void On_command_with_duration_at_exact_maximum_is_valid()
    {
        Assert.True(new PumpCommandRequest(Guid.NewGuid(), true, 600).IsValid(600));
    }

    // Duration of 1 (minimum positive)
    [Fact]
    public void On_command_with_duration_of_one_second_is_valid()
    {
        Assert.True(new PumpCommandRequest(Guid.NewGuid(), true, 1).IsValid(600));
    }

    // Duration of 0 is invalid
    [Fact]
    public void On_command_with_duration_of_zero_is_invalid()
    {
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), true, 0).IsValid(600));
    }

    // Negative duration is invalid
    [Fact]
    public void On_command_with_negative_duration_is_invalid()
    {
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), true, -1).IsValid(600));
    }

    // Empty GUID command ID is invalid
    [Fact]
    public void Empty_guid_command_id_makes_request_invalid()
    {
        Assert.False(new PumpCommandRequest(Guid.Empty, false, null).IsValid(600));
        Assert.False(new PumpCommandRequest(Guid.Empty, true, 300).IsValid(600));
    }

    // Off command with positive maximum duration is still invalid
    [Fact]
    public void Off_command_with_max_duration_is_always_invalid()
    {
        Assert.False(new PumpCommandRequest(Guid.NewGuid(), false, 600).IsValid(600));
    }
}
