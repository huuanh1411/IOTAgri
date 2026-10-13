using IOTAgriBackend.Dtos.Admin;
using Xunit;

namespace IOTAgriBackend.Tests;

public class UpdateSystemAlertDefaultsRequestTests
{
    [Theory]
    [InlineData(35.0, 20.0, true)]   // valid normal values
    [InlineData(0.0, 0.0, true)]     // both at minimum boundaries
    [InlineData(100.0, 100.0, true)] // water level at maximum
    [InlineData(-10.0, 20.0, true)]  // negative temperature is allowed
    public void Accepts_valid_finite_thresholds(double highTemp, double lowWater, bool expected)
    {
        var request = new UpdateSystemAlertDefaultsRequest(highTemp, lowWater);

        Assert.Equal(expected, request.IsValid);
    }

    [Theory]
    [InlineData(double.NaN, 20.0)]           // NaN temperature
    [InlineData(double.PositiveInfinity, 20.0)] // Infinity temperature
    [InlineData(double.NegativeInfinity, 20.0)] // -Infinity temperature
    [InlineData(35.0, double.NaN)]           // NaN water level
    [InlineData(35.0, -0.001)]               // water level just below 0
    [InlineData(35.0, 100.001)]              // water level just above 100
    public void Rejects_non_finite_or_out_of_range_thresholds(double highTemp, double lowWater)
    {
        var request = new UpdateSystemAlertDefaultsRequest(highTemp, lowWater);

        Assert.False(request.IsValid);
    }

    [Fact]
    public void Boundary_water_level_at_zero_is_valid()
    {
        Assert.True(new UpdateSystemAlertDefaultsRequest(35.0, 0.0).IsValid);
    }

    [Fact]
    public void Boundary_water_level_at_hundred_is_valid()
    {
        Assert.True(new UpdateSystemAlertDefaultsRequest(35.0, 100.0).IsValid);
    }
}
