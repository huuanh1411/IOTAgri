using IOTAgriBackend.Data;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Services;

public sealed class AccountDeletionAuditCleanupService(IServiceScopeFactory scopeFactory, ILogger<AccountDeletionAuditCleanupService> logger) : BackgroundService
{
    public static Task<int> DeleteExpiredAsync(ApplicationDbContext db, DateTime now, CancellationToken cancellationToken) =>
        db.AccountDeletionAudits
            .Where(audit => audit.DeletedAt <= now.AddDays(-30))
            .ExecuteDeleteAsync(cancellationToken);

    public static async Task RunCleanupCycleAsync(Func<CancellationToken, Task> cleanup, Action<Exception> logError, CancellationToken cancellationToken)
    {
        try
        {
            await cleanup(cancellationToken);
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (Exception exception)
        {
            logError(exception);
        }
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromDays(1));
        do
        {
            await RunCleanupCycleAsync(async cancellationToken =>
            {
                await using var scope = scopeFactory.CreateAsyncScope();
                var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                await DeleteExpiredAsync(db, DateTime.UtcNow, cancellationToken);
            }, exception => logger.LogError(exception, "Account deletion audit cleanup cycle failed."), stoppingToken);
        } while (await timer.WaitForNextTickAsync(stoppingToken));
    }
}
