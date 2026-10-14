using IOTAgriBackend.Services;
using Xunit;

namespace IOTAgriBackend.Tests;

public class AdminRoleRulesExtendedTests
{
    // Validate — role boundary cases
    [Theory]
    [InlineData("User")]
    [InlineData("Admin")]
    public void Allows_valid_roles_for_different_users(string role)
    {
        var error = AdminRoleRules.Validate("actor", "target", role, false, 2);

        Assert.Null(error);
    }

    [Theory]
    [InlineData("")]
    [InlineData("admin")]       // lowercase not allowed
    [InlineData("Moderator")]
    [InlineData(null)]
    public void Rejects_invalid_role_strings(string? role)
    {
        var error = AdminRoleRules.Validate("actor", "target", role, false, 2);

        Assert.NotNull(error);
    }

    [Fact]
    public void Promotes_non_admin_to_admin_is_allowed()
    {
        // targetIsAdmin=false means no last-admin check needed
        var error = AdminRoleRules.Validate("actor", "target", "Admin", false, 1);

        Assert.Null(error);
    }

    [Fact]
    public void Demotes_admin_when_multiple_admins_exist_is_allowed()
    {
        var error = AdminRoleRules.Validate("actor", "target", "User", true, 2);

        Assert.Null(error);
    }

    // ValidateLock — edge cases
    [Fact]
    public void Allows_unlock_of_last_admin()
    {
        // isLocked=false means we are UNLOCKING, not locking
        var error = AdminRoleRules.ValidateLock("actor", "target", false, true, 1);

        Assert.Null(error);
    }

    [Fact]
    public void Allows_locking_non_admin_user_even_if_only_one_admin_remains()
    {
        var error = AdminRoleRules.ValidateLock("actor", "target", true, false, 1);

        Assert.Null(error);
    }

    [Fact]
    public void Allows_locking_admin_when_multiple_admins_exist()
    {
        var error = AdminRoleRules.ValidateLock("actor", "target", true, true, 2);

        Assert.Null(error);
    }

    // ValidateListFilter — whitespace handling
    [Theory]
    [InlineData("  ", null)]
    [InlineData("  ACTIVE  ", "active")]
    public void Trims_and_normalizes_filter(string filter, string? expectedNormalized)
    {
        var error = AdminRoleRules.ValidateListFilter(filter, out var normalized);

        Assert.Null(error);
        Assert.Equal(expectedNormalized, normalized);
    }

    [Theory]
    [InlineData("pending")]
    [InlineData("all")]
    [InlineData("suspended")]
    public void Rejects_all_unsupported_filter_values(string filter)
    {
        var error = AdminRoleRules.ValidateListFilter(filter, out _);

        Assert.NotNull(error);
    }
}
