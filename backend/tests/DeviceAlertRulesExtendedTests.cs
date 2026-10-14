using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DeviceAlertRulesExtendedTests
{
    // EffectiveThresholds — all combinations
    [Fact]
    public void Both_device_thresholds_null_falls_back_to_system_defaults()
    {
        var result = DeviceAlertRules.EffectiveThresholds(null, null, 35, 20);

        Assert.Equal(35, result.HighTemperatureC);
        Assert.Equal(20, result.LowWaterLevelPercent);
    }

    [Fact]
    public void Both_device_thresholds_override_system_defaults()
    {
        var result = DeviceAlertRules.EffectiveThresholds(40, 15, 35, 20);

        Assert.Equal(40, result.HighTemperatureC);
        Assert.Equal(15, result.LowWaterLevelPercent);
    }

    [Fact]
    public void Only_water_level_device_threshold_overrides_while_temp_falls_back()
    {
        var result = DeviceAlertRules.EffectiveThresholds(null, 10, 35, 20);

        Assert.Equal(35, result.HighTemperatureC);
        Assert.Equal(10, result.LowWaterLevelPercent);
    }

    // IsUnsafe — exact boundary for HighTemperature
    [Theory]
    [InlineData(35.0, 35.0, true)]   // at threshold
    [InlineData(35.001, 35.0, true)] // just above
    [InlineData(34.999, 35.0, false)]// just below
    [InlineData(-40.0, 35.0, false)] // extreme low
    public void High_temperature_boundary_conditions(double temperature, double threshold, bool expected)
    {
        var result = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.HighTemperature,
            temperature,
            null,
            threshold,
            null);

        Assert.Equal(expected, result);
    }

    // IsUnsafe — exact boundary for LowWaterLevel
    [Theory]
    [InlineData(20.0, 20.0, true)]   // at threshold
    [InlineData(19.999, 20.0, true)] // just below
    [InlineData(20.001, 20.0, false)]// just above
    [InlineData(100.0, 20.0, false)] // extreme high
    public void Low_water_level_boundary_conditions(double waterLevel, double threshold, bool expected)
    {
        var result = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.LowWaterLevel,
            null,
            waterLevel,
            null,
            threshold);

        Assert.Equal(expected, result);
    }

    // IsUnsafe — null threshold cases
    [Fact]
    public void High_temperature_with_null_threshold_returns_null()
    {
        var result = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.HighTemperature,
            36.0,
            null,
            null, // null threshold
            null);

        Assert.Null(result);
    }

    [Fact]
    public void Low_water_level_with_null_measurement_returns_null()
    {
        var result = DeviceAlertRules.IsUnsafe(
            DeviceAlertType.LowWaterLevel,
            null,
            null, // null measurement
            null,
            20.0);

        Assert.Null(result);
    }
}
