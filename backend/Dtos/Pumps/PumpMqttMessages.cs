using IOTAgriBackend.Models;

namespace IOTAgriBackend.Dtos.Pumps;

public record PumpCommandMessage(Guid CommandId, bool IsOn, int? DurationSeconds,
    string Source, DateTime IssuedAtUtc, DateTime? ScheduledEndUtc)
{
    public static PumpCommandMessage From(PumpCommand command) => new(
        command.Id, command.IsOn, command.DurationSeconds,
        command.Source == PumpCommandSource.Scheduled ? "scheduled" : "manual",
        command.IssuedAt,
        command.Source == PumpCommandSource.Scheduled && command.DurationSeconds is int duration
            ? command.IssuedAt.AddSeconds(duration) : null);
}

public record PumpStatusMessage(
    Guid? CommandId,
    bool IsOn,
    bool? Success = null,
    string? Reason = null)
{
    public bool WasSuccessful => Success ?? true;

    public string? NormalizedReason
    {
        get
        {
            if (string.IsNullOrWhiteSpace(Reason)) return null;
            var value = Reason.Trim();
            return value.Length <= 512 ? value : value[..512];
        }
    }
}
