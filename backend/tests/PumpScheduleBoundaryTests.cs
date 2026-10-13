using System;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class PumpScheduleBoundaryTests
{
    [Theory]
    [InlineData(0, true)]
    [InlineData(90, true)]
    [InlineData(91, false)]
    [InlineData(-1, false)]
    public void Due_window_is_inclusive_and_does_not_dispatch_future_occurrences(int secondsAfterStart, bool expected)
    {
        var due = new DateTime(2026, 1, 3, 23, 0, 0, DateTimeKind.Utc);
        var schedule = new PumpSchedule { IsEnabled = true, WeekdayMask = 1, StartTime = new TimeOnly(6, 0), TimeZone = "Asia/Bangkok" };
        var found = PumpScheduleRules.TryGetDueOccurrenceUtc(schedule, due.AddSeconds(secondsAfterStart), TimeSpan.FromSeconds(90), out var occurrence);
        Assert.Equal(expected, found);
        Assert.Equal(expected ? due : default, occurrence);
    }

    [Fact]
    public void Overnight_window_dispatches_previous_days_occurrence_but_excludes_end_time()
    {
        var schedule = new PumpSchedule { IsEnabled = true, WeekdayMask = 64, StartTime = new TimeOnly(23, 30), EndTime = new TimeOnly(1, 0), IntervalMinutes = 30, TimeZone = "Etc/UTC" };
        var midnight = new DateTime(2026, 1, 4, 0, 0, 0, DateTimeKind.Utc);
        Assert.Equal(new[] { midnight }, PumpScheduleRules.GetDueOccurrencesUtc(schedule, midnight, TimeSpan.FromSeconds(90)));
        Assert.Empty(PumpScheduleRules.GetDueOccurrencesUtc(schedule, midnight.AddHours(1), TimeSpan.FromSeconds(90)));
    }

    [Fact]
    public void Adjacent_schedules_that_touch_at_end_do_not_overlap()
    {
        var first = new PumpSchedule { WeekdayMask = 1, StartTime = new TimeOnly(6, 0), DurationSeconds = 600 };
        var adjacent = new PumpSchedule { WeekdayMask = 1, StartTime = new TimeOnly(6, 10), DurationSeconds = 600 };
        Assert.False(PumpScheduleRules.Overlaps(first, new[] { adjacent }));
        Assert.False(PumpScheduleRules.Overlaps(adjacent, new[] { first }));
    }
}
