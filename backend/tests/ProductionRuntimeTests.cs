using System;
using System.IO;
using Xunit;

namespace IOTAgriBackend.Tests;

public class ProductionRuntimeTests
{
    [Fact]
    public void Production_compose_exposes_only_caddy_and_mosquitto_ports()
    {
        var compose = File.ReadAllText(RepoFile("compose.production.yaml"));

        Assert.Contains("\"80:80\"", compose);
        Assert.Contains("\"443:443\"", compose);
        Assert.Contains("\"8883:8883\"", compose);
        Assert.DoesNotContain("\"8080:8080\"", compose);
        Assert.DoesNotContain("\"5432:5432\"", compose);
    }

    [Fact]
    public void Production_stack_hosts_flutter_web_behind_caddy()
    {
        var compose = File.ReadAllText(RepoFile("compose.production.yaml"));
        var caddyfile = File.ReadAllText(RepoFile("deploy/Caddyfile"));
        var frontendDockerfile = File.ReadAllText(RepoFile("frontend/Dockerfile"));

        Assert.Contains("  frontend:", compose);
        Assert.Contains("context: ./frontend", compose);
        Assert.Contains("app.aerogreen.vn", caddyfile);
        Assert.Contains("reverse_proxy frontend:80", caddyfile);
        Assert.Contains("--dart-define=API_BASE_URL=$API_BASE_URL", frontendDockerfile);
    }

    [Fact]
    public void Production_compose_has_health_checks_single_api_replica_and_resource_limits()
    {
        var compose = File.ReadAllText(RepoFile("compose.production.yaml"));

        Assert.Equal(4, Count(compose, "healthcheck:"));
        Assert.Contains("replicas: 1", compose);
        Assert.Contains("cpus:", compose);
        Assert.Contains("memory:", compose);
    }

    [Fact]
    public void Production_image_runs_as_non_root_user()
    {
        var dockerfile = File.ReadAllText(RepoFile("Dockerfile"));

        Assert.Contains("USER app", dockerfile);
    }

    [Fact]
    public void Continuous_deployment_requires_mqtt_certificate_and_key_before_compose_reconciliation()
    {
        var workflow = File.ReadAllText(RepoFile(".github/workflows/cd.yml"));
        var certificateIndex = workflow.IndexOf("test -s deploy/mosquitto-certs/server.crt", StringComparison.Ordinal);
        var keyIndex = workflow.IndexOf("test -s deploy/mosquitto-certs/server.key", StringComparison.Ordinal);
        var composeIndex = workflow.IndexOf("up -d --build --remove-orphans", StringComparison.Ordinal);

        Assert.True(certificateIndex >= 0, "CD must require the MQTT certificate before touching Mosquitto.");
        Assert.True(keyIndex > certificateIndex, "CD must require the matching MQTT private key.");
        Assert.True(composeIndex > keyIndex, "Certificate checks must run before Compose reconciliation.");
    }

    [Fact]
    public void Mqtt_certificate_sync_requires_both_certificate_and_private_key_to_match()
    {
        var script = File.ReadAllText(RepoFile("deploy/sync-mqtt-certs.sh"));

        Assert.Contains("cmp -s \"$tmp/server.crt\" \"$dst/server.crt\"", script);
        Assert.Contains("cmp -s \"$tmp/server.key\" \"$dst/server.key\"", script);
    }

    [Fact]
    public void Mqtt_certificate_sync_timer_is_persistent_and_runs_daily()
    {
        var service = File.ReadAllText(RepoFile("deploy/iotagri-mqtt-cert-sync.service"));
        var timer = File.ReadAllText(RepoFile("deploy/iotagri-mqtt-cert-sync.timer"));

        Assert.Contains("ExecStart=/usr/bin/bash /opt/iotagri/deploy/sync-mqtt-certs.sh", service);
        Assert.Contains("OnCalendar=*-*-* 03:17:00", timer);
        Assert.Contains("Persistent=true", timer);
    }

    private static string RepoFile(string relativePath) => Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../..", relativePath));

    private static int Count(string text, string value)
    {
        var count = 0;
        var index = 0;
        while ((index = text.IndexOf(value, index, StringComparison.Ordinal)) >= 0)
        {
            count++;
            index += value.Length;
        }

        return count;
    }
}
