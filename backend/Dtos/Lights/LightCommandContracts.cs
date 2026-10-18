namespace IOTAgriBackend.Dtos.Lights;

public record LightCommandRequest(bool IsOn);

public record LightCommandMessage(bool IsOn);
