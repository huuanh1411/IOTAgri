using System;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class PumpScheduleRulesExtendedTests
{
    // ─── Validate ───────────────────────────────────────────────────────────────

    [Fact]
    public void Validates_minimum_valid_weekday_mask_value_of_one()
    {
        // mask=1 = Sunday only
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 3600));
    }

    [Fact]
    public void Rejects_weekday_mask_with_bits_beyond_sunday_to_saturday()
    {
        // 0b10000000 = bit 7, which is out of range
        Assert.NotNull(PumpScheduleRules.Validate(true, 0b10000000, new TimeOnly(6, 0), 60, "Asia/Bangkok", 3600));
    }

    [Fact]
    public void Accepts_maximum_duration_equal_to_limit()
    {
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 600, "Asia/Bangkok", 600));
    }

    [Fact]
    public void Rejects_duration_of_zero()
    {
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 0, "Asia/Bangkok", 600));
    }

    [Fact]
    public void Rejects_negative_duration()
    {
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), -1, "Asia/Bangkok", 600));
    }

    [Fact]
    public void Rejects_endTime_without_intervalMinutes()
    {
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 600,
            endTime: new TimeOnly(8, 0), intervalMinutes: null));
    }

    [Fact]
    public void Rejects_intervalMinutes_without_endTime()
    {
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 600,
            endTime: null, intervalMinutes: 30));
    }

    [Fact]
    public void Rejects_endTime_equal_to_startTime()
    {
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "Asia/Bangkok", 600,
            endTime: new TimeOnly(6, 0), intervalMinutes: 30));
    }

    [Fact]
    public void Rejects_intervalMinutes_of_zero()
    {
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 10, "Asia/Bangkok", 600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 0));
    }

    [Fact]
    public void Rejects_intervalMinutes_greater_than_sixty()
    {
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 10, "Asia/Bangkok", 600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 61));
    }

    [Fact]
    public void Accepts_intervalMinutes_of_sixty()
    {
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 30, "Asia/Bangkok", 3600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 60));
    }

    [Fact]
    public void Rejects_duration_equal_to_interval_in_seconds()
    {
        // durationSeconds=1800 >= intervalMinutes(30)*60=1800
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 1800, "Asia/Bangkok", 3600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 30));
    }

    [Fact]
    public void Accepts_duration_one_second_less_than_interval()
    {
        // durationSeconds=1799 < intervalMinutes(30)*60=1800
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 1799, "Asia/Bangkok", 3600,
            endTime: new TimeOnly(8, 0), intervalMinutes: 30));
    }

    [Fact]
    public void Rejects_windows_time_zone_id()
    {
        // Windows time zone IDs are not valid IANA IDs
        Assert.NotNull(PumpScheduleRules.Validate(true, 1, new TimeOnly(6, 0), 60, "SE Asia Standard Time", 600));
    }

    [Fact]
    public void Accepts_overnight_window_where_endTime_is_before_startTime()
    {
        // endTime=01:00 < startTime=23:30 -> overnight window
        Assert.Null(PumpScheduleRules.Validate(true, 1, new TimeOnly(23, 30), 60, "Asia/Bangkok", 3600,
            endTime: new TimeOnly(1, 0), intervalMinutes: 30));
    }

    // ─── Overlaps ────────────────────────────────────────────────────────────────

    [Fact]
    public void Disabled_candidate_never_overlaps()
    {
        var disabled = new PumpSchedule
        {
            IsEnabled = false,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };
        var existing = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };

        Assert.False(PumpScheduleRules.Overlaps(disabled, [existing]));
    }

    [Fact]
    public void Schedule_does_not_overlap_with_itself_by_id()
    {
        var id = Guid.NewGuid();
        var schedule = new PumpSchedule
        {
            Id = id,
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };

        Assert.False(PumpScheduleRules.Overlaps(schedule, [schedule]));
    }

    [Fact]
    public void Non_overlapping_schedules_on_same_day_do_not_conflict()
    {
        var morning = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600, // ends 6:10
        };
        var afternoon = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(14, 0),
            DurationSeconds = 600, // starts 14:00
        };

        Assert.False(PumpScheduleRules.Overlaps(morning, [afternoon]));
    }

    [Fact]
    public void Overlapping_schedules_on_same_day_are_detected()
    {
        var first = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 3600, // ends 7:00
        };
        var second = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1,
            StartTime = new TimeOnly(6, 30), // starts 6:30 inside first
            DurationSeconds = 600,
        };

        Assert.True(PumpScheduleRules.Overlaps(second, [first]));
    }

    [Fact]
    public void Schedules_on_different_days_with_no_time_overlap_do_not_conflict()
    {
        var monday = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 2, // Monday
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };
        var wednesday = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 8, // Wednesday
            StartTime = new TimeOnly(6, 0),
            DurationSeconds = 600,
        };

        Assert.False(PumpScheduleRules.Overlaps(monday, [wednesday]));
    }

    // ─── GetDueOccurrencesUtc ────────────────────────────────────────────────────

    [Fact]
    public void Returns_empty_list_when_schedule_is_disabled()
    {
        var schedule = new PumpSchedule
        {
            IsEnabled = false,
            WeekdayMask = 127,
            StartTime = new TimeOnly(6, 0),
            TimeZone = "Asia/Bangkok",
        };
        var now = new DateTime(2026, 1, 4, 23, 0, 0, DateTimeKind.Utc); // Bangkok 06:00

        var result = PumpScheduleRules.GetDueOccurrencesUtc(schedule, now, TimeSpan.FromSeconds(90));

        Assert.Empty(result);
    }

    [Fact]
    public void Returns_empty_list_when_due_window_is_zero()
    {
        var schedule = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 127,
            StartTime = new TimeOnly(6, 0),
            TimeZone = "Asia/Bangkok",
        };
        var now = new DateTime(2026, 1, 4, 23, 0, 0, DateTimeKind.Utc);

        var result = PumpScheduleRules.GetDueOccurrencesUtc(schedule, now, TimeSpan.Zero);

        Assert.Empty(result);
    }

    [Fact]
    public void Returns_empty_list_for_invalid_time_zone()
    {
        var schedule = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 127,
            StartTime = new TimeOnly(6, 0),
            TimeZone = "Invalid/Zone",
        };
        var now = new DateTime(2026, 1, 4, 23, 0, 0, DateTimeKind.Utc);

        var result = PumpScheduleRules.GetDueOccurrencesUtc(schedule, now, TimeSpan.FromSeconds(90));

        Assert.Empty(result);
    }

    [Fact]
    public void Occurrence_is_returned_in_ascending_order()
    {
        var schedule = new PumpSchedule
        {
            IsEnabled = true,
            WeekdayMask = 1, // Sunday
            StartTime = new TimeOnly(6, 0),
            EndTime = new TimeOnly(7, 0),
            IntervalMinutes = 30,
            DurationSeconds = 60,
            TimeZone = "Asia/Bangkok",
        };
        // Bangkok Sunday 6:00 = UTC Saturday 23:00
        // Bangkok Sunday 6:30 = UTC Saturday 23:30
        var utcNow = new DateTime(2026, 1, 3, 23, 30, 0, DateTimeKind.Utc);

        var occurrences = PumpScheduleRules.GetDueOccurrencesUtc(schedule, utcNow, TimeSpan.FromMinutes(35));

        Assert.Equal(new[] { utcNow.AddMinutes(-30), utcNow }, occurrences);
    }
}
