using IOTAgriBackend.Data;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Services;

public sealed class LightScheduleDispatchService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IConfiguration _configuration;
    private readonly MqttIngestionService _mqtt;
    private readonly ILogger<LightScheduleDispatchService> _logger;

    public LightScheduleDispatchService(IServiceScopeFactory scopeFactory, IConfiguration configuration, MqttIngestionService mqtt, ILogger<LightScheduleDispatchService> logger) =>
        (_scopeFactory, _configuration, _mqtt, _logger) = (scopeFactory, configuration, mqtt, logger);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var settings = _configuration.GetSection("LightScheduling");
        if (!settings.GetValue<bool>("Enabled")) return;
        var pollSeconds = Math.Clamp(settings.GetValue<int?>("PollSeconds") ?? 30, 5, 300);
        using var timer = new PeriodicTimer(TimeSpan.FromSeconds(pollSeconds));
        do { await DispatchAsync(TimeSpan.FromSeconds(Math.Max(settings.GetValue<int?>("DueWindowSeconds") ?? 90, pollSeconds)), stoppingToken); }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }

    private async Task DispatchAsync(TimeSpan dueWindow, CancellationToken cancellationToken)
    {
        try
        {
            var now = DateTime.UtcNow;
            using var scope = _scopeFactory.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            var schedules = await db.LightSchedules.Include(schedule => schedule.Device).Where(schedule => schedule.IsEnabled).ToListAsync(cancellationToken);
            foreach (var schedule in schedules)
            {
                var starts = LightScheduleRules.GetDueOccurrencesUtc(schedule, now, dueWindow);
                foreach (var start in starts.Where(start => schedule.LastDispatchedOccurrenceUtc != start))
                    await PublishAsync(schedule, true, start, cancellationToken);
                if (schedule.LastDispatchedOccurrenceUtc is DateTime last && schedule.LastTurnedOffOccurrenceUtc != last && now >= last.AddSeconds(schedule.DurationSeconds) && now - last.AddSeconds(schedule.DurationSeconds) <= dueWindow)
                    await PublishAsync(schedule, false, last, cancellationToken);
            }
        }
        catch (Exception exception) when (exception is not OperationCanceledException)
        {
            _logger.LogError(exception, "Light schedule dispatch cycle failed.");
        }
    }

    private async Task PublishAsync(Models.LightSchedule schedule, bool isOn, DateTime occurrenceUtc, CancellationToken cancellationToken)
    {
        if (schedule.Device is null) return;
        await _mqtt.PublishLightCommandAsync(schedule.Device.DeviceKey, Guid.NewGuid(), isOn, cancellationToken);
        using var scope = _scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var saved = await db.LightSchedules.FindAsync([schedule.Id], cancellationToken);
        if (saved is null) return;
        if (isOn) saved.LastDispatchedOccurrenceUtc = occurrenceUtc;
        else saved.LastTurnedOffOccurrenceUtc = occurrenceUtc;
        await db.SaveChangesAsync(cancellationToken);
    }
}