namespace IOTAgriBackend.Dtos.Lights;

public record LightCommandRequest(Guid CommandId, bool IsOn);

public record LightCommandResponse(Guid CommandId, bool IsOn, string Status);

public record LightStatusResponse(bool IsOn, DateTime? UpdatedAt, bool IsAvailable);

public record LightCommandMessage(Guid CommandId, bool IsOn);

public record LightStatusMessage(Guid? CommandId, bool IsOn, bool? Success, string? Reason)
{
    public bool WasSuccessful => Success is not false;
}
