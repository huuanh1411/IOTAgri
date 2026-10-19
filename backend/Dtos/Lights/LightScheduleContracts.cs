namespace IOTAgriBackend.Dtos.Lights;

public record LightScheduleRequest(
    bool? IsEnabled,
    int WeekdayMask,
    TimeOnly? StartTime,
    int DurationSeconds,
    string? TimeZone);

public record LightScheduleResponse(
    Guid Id,
    Guid DeviceId,
    bool IsEnabled,
    int WeekdayMask,
    TimeOnly StartTime,
    int DurationSeconds,
    string TimeZone,
    DateTime? LastDispatchedOccurrenceUtc,
    DateTime? LastTurnedOffOccurrenceUtc,
    DateTime CreatedAt);