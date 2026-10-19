namespace IOTAgriBackend.Dtos.Lights;

public record LightCommandRequest(Guid? CommandId, bool IsOn);

public record LightCommandMessage(Guid CommandId, bool IsOn);
