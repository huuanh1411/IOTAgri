using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class AdminRoleRulesTests
{
    [Fact]
    public void Rejects_self_changes_and_last_admin_demotion()
    {
        Assert.NotNull(AdminRoleRules.Validate("admin", "admin", "User", true, 2));
        Assert.NotNull(AdminRoleRules.Validate("other", "admin", "User", true, 1));
        Assert.Null(AdminRoleRules.Validate("other", "admin", "User", true, 2));
    }

    [Fact]
    public void Rejects_unknown_role()
    {
        Assert.NotNull(AdminRoleRules.Validate("admin", "user", "Owner", false, 1));
    }

    [Fact]
    public void Rejects_self_and_last_admin_locking()
    {
        Assert.NotNull(AdminRoleRules.ValidateLock("admin", "admin", true, true, 2));
        Assert.NotNull(AdminRoleRules.ValidateLock("other", "admin", true, true, 1));
        Assert.Null(AdminRoleRules.ValidateLock("other", "admin", true, true, 2));
        Assert.Null(AdminRoleRules.ValidateLock("other", "user", false, false, 1));
    }
}
