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
