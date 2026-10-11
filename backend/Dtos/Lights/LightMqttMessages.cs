namespace IOTAgriBackend.Dtos.Lights;

public record LightCommandRequest(Guid CommandId, bool IsOn)
{
    public bool IsValid => CommandId != Guid.Empty;
}

public record LightCommandMessage(Guid CommandId, bool IsOn);

public record LightCommandResponse(Guid CommandId, bool IsOn, string Status);

public record LightStatusMessage(
    Guid? CommandId,
    bool IsOn,
    bool? Success = null,
    string? Reason = null);
