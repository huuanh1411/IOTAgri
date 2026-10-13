using IOTAgriBackend.Dtos.Sensors;
using System;
using System.Collections.Generic;
using Xunit;

namespace IOTAgriBackend.Tests;

public class SensorMedianBucketExtendedTests
{
    [Fact]
    public void Empty_source_produces_all_null_medians()
    {
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        var empty = new Dictionary<DateTime, SensorMedianBucket>();

        var buckets = SensorMedianBuckets.Complete(start, 3, TimeSpan.FromHours(1), empty);

        Assert.Equal(3, buckets.Count);
        Assert.All(buckets, bucket =>
        {
            Assert.Null(bucket.MedianTemperature);
            Assert.Null(bucket.MedianHumidity);
            Assert.Null(bucket.MedianPh);
            Assert.Null(bucket.MedianTds);
            Assert.Null(bucket.MedianWaterLevel);
            Assert.Equal(0, bucket.SampleCount);
        });
    }

    [Fact]
    public void Count_of_zero_returns_empty_list()
    {
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);

        var buckets = SensorMedianBuckets.Complete(start, 0, TimeSpan.FromHours(1),
            new Dictionary<DateTime, SensorMedianBucket>());

        Assert.Empty(buckets);
    }

    [Fact]
    public void Bucket_start_timestamps_are_evenly_spaced_by_interval()
    {
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        var interval = TimeSpan.FromMinutes(30);

        var buckets = SensorMedianBuckets.Complete(start, 4, interval,
            new Dictionary<DateTime, SensorMedianBucket>());

        Assert.Equal(start, buckets[0].BucketStart);
        Assert.Equal(start.AddMinutes(30), buckets[1].BucketStart);
        Assert.Equal(start.AddMinutes(60), buckets[2].BucketStart);
        Assert.Equal(start.AddMinutes(90), buckets[3].BucketStart);
    }

    [Fact]
    public void Source_bucket_at_matching_timestamp_preserves_all_fields()
    {
        var start = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc);
        var bucket = new SensorMedianBucket(
            BucketStart: start,
            MedianTemperature: 28.5,
            MedianSolutionTemperature: 26.0,
            MedianHumidity: 72.0,
            MedianPh: 6.5,
            MedianTds: 450,
            MedianWaterLevel: 65.0,
            MedianLux: 300,
            SampleCount: 12);

        var source = new Dictionary<DateTime, SensorMedianBucket> { [start] = bucket };
        var result = SensorMedianBuckets.Complete(start, 1, TimeSpan.FromHours(1), source);

        Assert.Single(result);
        Assert.Equal(28.5, result[0].MedianTemperature);
        Assert.Equal(26.0, result[0].MedianSolutionTemperature);
        Assert.Equal(72.0, result[0].MedianHumidity);
        Assert.Equal(6.5, result[0].MedianPh);
        Assert.Equal(450, result[0].MedianTds);
        Assert.Equal(65.0, result[0].MedianWaterLevel);
        Assert.Equal(300, result[0].MedianLux);
        Assert.Equal(12, result[0].SampleCount);
    }
}
