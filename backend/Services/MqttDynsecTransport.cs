using System.Buffers;
using System.Text;
using MQTTnet;
using MQTTnet.Protocol;

namespace IOTAgriBackend.Services;

public sealed class MqttDynsecTransport(IConfiguration configuration) : IMqttDynsecTransport
{
    private const string RequestTopic = "$CONTROL/dynamic-security/v1";
    private const string ResponseTopic = "$CONTROL/dynamic-security/v1/response";

    public async Task<string> SendAsync(string requestJson, CancellationToken cancellationToken)
    {
        var settings = configuration.GetSection("MqttBrokerAdmin");
        var host = settings["Host"] ?? throw new MqttBrokerAdminException("Broker administration is not configured.");
        var username = settings["Username"] ?? throw new MqttBrokerAdminException("Broker administration is not configured.");
        var password = settings["Password"] ?? throw new MqttBrokerAdminException("Broker administration is not configured.");
        var client = new MqttClientFactory().CreateMqttClient();
        var completion = new TaskCompletionSource<string>(TaskCreationOptions.RunContinuationsAsynchronously);

        client.ApplicationMessageReceivedAsync += args =>
        {
            if (args.ApplicationMessage.Topic == ResponseTopic)
            {
                completion.TrySetResult(Encoding.UTF8.GetString(args.ApplicationMessage.Payload.ToArray()));
            }
            return Task.CompletedTask;
        };

        var options = new MqttClientOptionsBuilder()
            .WithTcpServer(host, settings.GetValue<int?>("Port") ?? 8883)
            .WithClientId(settings["ClientId"] ?? $"iotagribackend-dynsec-{Guid.NewGuid():N}")
            .WithCredentials(username, password)
            .WithCleanSession();
        if (settings.GetValue<bool>("UseTls")) options.WithTlsOptions(tls => tls.UseTls());

        try
        {
            await client.ConnectAsync(options.Build(), cancellationToken);
            var subscription = new MqttClientFactory().CreateSubscribeOptionsBuilder()
                .WithTopicFilter(ResponseTopic)
                .Build();
            await client.SubscribeAsync(subscription, cancellationToken);
            await client.PublishAsync(new MqttApplicationMessageBuilder()
                .WithTopic(RequestTopic)
                .WithPayload(requestJson)
                .WithQualityOfServiceLevel(MqttQualityOfServiceLevel.AtLeastOnce)
                .Build(), cancellationToken);

            using var timeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            timeout.CancelAfter(TimeSpan.FromSeconds(10));
            return await completion.Task.WaitAsync(timeout.Token);
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            throw new MqttBrokerAdminException("Broker administration timed out.");
        }
        catch (MqttBrokerAdminException)
        {
            throw;
        }
        catch
        {
            throw new MqttBrokerAdminException("Broker administration is unavailable.");
        }
        finally
        {
            if (client.IsConnected) await client.DisconnectAsync();
            client.Dispose();
        }
    }
}
