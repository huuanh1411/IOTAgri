using System;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace IOTAgriBackend.Tests;

public class AccountDeletionAuditCleanupServiceTests
{
    [Fact]
    public async Task Cleanup_removes_only_audits_at_least_thirty_days_old()
    {
        await using var connection = new Microsoft.Data.Sqlite.SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = CreateDatabase(connection);
        await db.Database.EnsureCreatedAsync();
        var now = DateTime.UtcNow;
        db.AccountDeletionAudits.AddRange(
            new AccountDeletionAudit { DeletedAt = now.AddDays(-30) },
            new AccountDeletionAudit { DeletedAt = now.AddDays(-29).AddHours(-23) });
        await db.SaveChangesAsync();

        await AccountDeletionAuditCleanupService.DeleteExpiredAsync(db, now, CancellationToken.None);

        var remaining = await db.AccountDeletionAudits.SingleAsync();
        Assert.True(remaining.DeletedAt > now.AddDays(-30));
    }

    private static ApplicationDbContext CreateDatabase(Microsoft.Data.Sqlite.SqliteConnection connection) => new(new DbContextOptionsBuilder<ApplicationDbContext>()
        .UseSqlite(connection)
        .Options);
}
