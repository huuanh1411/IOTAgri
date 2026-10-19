using IOTAgriBackend.Models;

namespace IOTAgriBackend.Services;

public static class LightScheduleRules
{
    public static string? Validate(bool? isEnabled, int weekdayMask, TimeOnly? startTime, int durationSeconds, string? timeZone, int maximumDurationSeconds) =>
        PumpScheduleRules.Validate(isEnabled, weekdayMask, startTime, durationSeconds, timeZone, maximumDurationSeconds);

    public static List<DateTime> GetDueOccurrencesUtc(LightSchedule schedule, DateTime utcNow, TimeSpan dueWindow) =>
        PumpScheduleRules.GetDueOccurrencesUtc(ToPumpSchedule(schedule), utcNow, dueWindow);

    private static PumpSchedule ToPumpSchedule(LightSchedule schedule) => new()
    {
        IsEnabled = schedule.IsEnabled,
        WeekdayMask = schedule.WeekdayMask,
        StartTime = schedule.StartTime,
        DurationSeconds = schedule.DurationSeconds,
        TimeZone = schedule.TimeZone,
    };
}