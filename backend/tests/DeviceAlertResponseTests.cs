using IOTAgriBackend.Dtos.Alerts;
using IOTAgriBackend.Models;
using System;
using Xunit;

namespace IOTAgriBackend.Tests;

public class DeviceAlertResponseTests
{
    [Fact]
    public void From_maps_HighTemperature_alert_to_HIGH_TEMPERATURE_string()
    {
        var alert = new DeviceAlert
        {
            Id = Guid.NewGuid(),
            Type = DeviceAlertType.HighTemperature,
            MeasuredValue = 37.5,
            Threshold = 35.0,
            TriggeredAt = new DateTime(2026, 10, 1, 12, 0, 0, DateTimeKind.Utc),
            ResolvedAt = null,
        };

        var response = DeviceAlertResponse.From(alert);

        Assert.Equal("HIGH_TEMPERATURE", response.Type);
        Assert.Equal(alert.Id, response.Id);
        Assert.Equal(37.5, response.MeasuredValue);
        Assert.Equal(35.0, response.Threshold);
        Assert.Null(response.ResolvedAt);
        Assert.Equal(alert.TriggeredAt, response.TriggeredAt);
    }

    [Fact]
    public void From_maps_LowWaterLevel_alert_to_LOW_WATER_LEVEL_string()
    {
        var resolvedAt = new DateTime(2026, 10, 1, 14, 0, 0, DateTimeKind.Utc);
        var alert = new DeviceAlert
        {
            Id = Guid.NewGuid(),
            Type = DeviceAlertType.LowWaterLevel,
            MeasuredValue = 15.0,
            Threshold = 20.0,
            TriggeredAt = new DateTime(2026, 10, 1, 10, 0, 0, DateTimeKind.Utc),
            ResolvedAt = resolvedAt,
        };

        var response = DeviceAlertResponse.From(alert);

        Assert.Equal("LOW_WATER_LEVEL", response.Type);
        Assert.Equal(15.0, response.MeasuredValue);
        Assert.Equal(20.0, response.Threshold);
        Assert.Equal(resolvedAt, response.ResolvedAt);
        Assert.Equal(alert.Id, response.Id);
        Assert.Equal(alert.TriggeredAt, response.TriggeredAt);
    }
}
