using System;
using System.Diagnostics;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using Xunit;

namespace IOTAgriBackend.Tests;

// Owns one disposable PostgreSQL container. Never reads the application .env,
// accepts an external connection string, mounts a volume, or uses Compose state.
public sealed class PostgresTestFixture : IAsyncLifetime
{
    private readonly string _name = "iotagri-qa-" + Guid.NewGuid().ToString("N");
    private string? _container;
    private string _baseConnection = string.Empty;

    internal static async Task<string> Docker(params string[] arguments)
    {
        var info = new ProcessStartInfo("docker") { RedirectStandardOutput = true, RedirectStandardError = true, UseShellExecute = false, CreateNoWindow = true };
        foreach (var argument in arguments) info.ArgumentList.Add(argument);
        using var process = Process.Start(info) ?? throw new InvalidOperationException("Cannot start Docker CLI.");
        var stdout = process.StandardOutput.ReadToEndAsync();
        var stderr = process.StandardError.ReadToEndAsync();
        await process.WaitForExitAsync().WaitAsync(TimeSpan.FromMinutes(2));
        if (process.ExitCode != 0) throw new InvalidOperationException("QA Docker operation failed: " + await stderr);
        return (await stdout).Trim();
    }

    public async Task InitializeAsync()
    {
        _container = await Docker("run", "--detach", "--name", _name, "--label", "com.iotagri.qa=true",
            "--env", "POSTGRES_USER=qa", "--env", "POSTGRES_PASSWORD=qa-isolated-only-password",
            "--env", "POSTGRES_DB=qa_base", "--publish", "127.0.0.1::5432", "postgres:17-alpine");
        var mapping = await Docker("port", _container, "5432/tcp");
        if (!mapping.StartsWith("127.0.0.1:", StringComparison.Ordinal)) throw new InvalidOperationException("QA container must be bound to loopback only.");
        var port = int.Parse(mapping.Substring("127.0.0.1:".Length));
        _baseConnection = new NpgsqlConnectionStringBuilder { Host = "127.0.0.1", Port = port, Database = "qa_base", Username = "qa", Password = "qa-isolated-only-password", Timeout = 3 }.ConnectionString;
        Exception? lastError = null;
        for (var attempt = 0; attempt < 30; attempt++)
        {
            try { await using var connection = new NpgsqlConnection(_baseConnection); await connection.OpenAsync(); return; }
            catch (NpgsqlException error) { lastError = error; await Task.Delay(500); }
        }
        throw new InvalidOperationException("Disposable QA database did not become ready.", lastError);
    }

    internal async Task<ApplicationDbContext> CreateDatabaseAsync()
    {
        if (_container is null || !_name.StartsWith("iotagri-qa-", StringComparison.Ordinal)) throw new InvalidOperationException("QA fixture not initialized.");
        var database = "qa_" + Guid.NewGuid().ToString("N");
        await using var connection = new NpgsqlConnection(_baseConnection);
        await connection.OpenAsync();
        // Name generated locally from fixed prefix + GUID; never caller supplied.
        await using var command = new NpgsqlCommand("CREATE DATABASE \"" + database + "\"", connection);
        await command.ExecuteNonQueryAsync();
        var builder = new NpgsqlConnectionStringBuilder(_baseConnection) { Database = database };
        var db = new ApplicationDbContext(new DbContextOptionsBuilder<ApplicationDbContext>().UseNpgsql(builder.ConnectionString).Options);
        try { await db.Database.MigrateAsync(); return db; }
        catch { await db.DisposeAsync(); throw; }
    }

    public async Task DisposeAsync()
    {
        if (_container is null) return;
        // Verify identity/label before removing only this fixture's own container.
        var identity = await Docker("inspect", "--format", "{{.Name}}|{{index .Config.Labels \"com.iotagri.qa\"}}", _container);
        if (identity != "/" + _name + "|true") throw new InvalidOperationException("Refusing to remove a container not owned by this QA fixture.");
        await Docker("rm", "--force", "--volumes", _container);
    }
}
