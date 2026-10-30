using IOTAgriBackend.Data;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Services;

public sealed class AccountDeletionAuditCleanupService(IServiceScopeFactory scopeFactory) : BackgroundService
{
    public static Task<int> DeleteExpiredAsync(ApplicationDbContext db, DateTime now, CancellationToken cancellationToken) =>
        db.AccountDeletionAudits
            .Where(audit => audit.DeletedAt <= now.AddDays(-30))
            .ExecuteDeleteAsync(cancellationToken);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromDays(1));
        do
        {
            await using var scope = scopeFactory.CreateAsyncScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            await DeleteExpiredAsync(db, DateTime.UtcNow, stoppingToken);
        } while (await timer.WaitForNextTickAsync(stoppingToken));
    }
}
