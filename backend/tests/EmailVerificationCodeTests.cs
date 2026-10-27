using System;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Models;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace IOTAgriBackend.Tests;

public class EmailVerificationCodeTests
{
    [Fact]
    public void Verification_code_expiry_is_fifteen_minutes_after_issue()
    {
        var issuedAt = new DateTime(2026, 10, 27, 10, 0, 0, DateTimeKind.Utc);

        var code = EmailVerificationCode.Create("user-1", "123456", "pepper", issuedAt);

        Assert.Equal(issuedAt.AddMinutes(15), code.ExpiresAt);
        Assert.NotEqual("123456", code.CodeHash);
        Assert.Equal(0, code.AttemptCount);
    }

    [Fact]
    public async Task Verification_code_uses_concurrency_token_to_reject_stale_consumption()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        var issuedAt = DateTime.UtcNow;
        Guid codeId;

        await using (var setup = new ApplicationDbContext(options))
        {
            var code = EmailVerificationCode.Create("user-1", "123456", "pepper", issuedAt);
            setup.EmailVerificationCodes.Add(code);
            await setup.SaveChangesAsync();
            codeId = code.Id;
        }

        await using var first = new ApplicationDbContext(options);
        await using var second = new ApplicationDbContext(options);
        var firstCopy = await first.EmailVerificationCodes.SingleAsync(code => code.Id == codeId);
        var staleCopy = await second.EmailVerificationCodes.SingleAsync(code => code.Id == codeId);

        firstCopy.ConsumedAt = issuedAt.AddSeconds(1);
        await first.SaveChangesAsync();
        staleCopy.ConsumedAt = issuedAt.AddSeconds(2);

        await Assert.ThrowsAsync<DbUpdateConcurrencyException>(() => second.SaveChangesAsync());
    }
}
