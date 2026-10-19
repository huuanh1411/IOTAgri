namespace IOTAgriBackend.Services;

public interface IMqttDynsecTransport
{
    Task<string> SendAsync(string requestJson, CancellationToken cancellationToken);
}
