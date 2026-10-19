namespace IOTAgriBackend.Dtos.Devices;

public record ClaimDeviceResponse(
    string DeviceKey,
    string MqttHost,
    int MqttPort,
    bool UseTls,
    string MqttUsername,
    string MqttPassword,
    string MqttClientId
);
