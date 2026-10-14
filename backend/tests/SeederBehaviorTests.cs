using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Moq;
using Xunit;

namespace IOTAgriBackend.Tests;

public class SeederBehaviorTests
{
    private static IConfiguration Configuration(string? email = "qa@example.test", string? fullName = null) =>
        new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["AdminBootstrap:Email"] = email, ["AdminBootstrap:Password"] = "QaPassword1!", ["AdminBootstrap:FullName"] = fullName,
        }).Build();

    [Fact]
    public async Task Unconfigured_bootstrap_does_not_resolve_user_manager()
    {
        using var services = new ServiceCollection().BuildServiceProvider();
        await AdminBootstrapper.SeedAsync(services, Configuration(email: null));
        Assert.Null(services.GetService<UserManager<ApplicationUser>>());
    }

    [Theory]
    [InlineData(null, "Administrator")]
    [InlineData("  ", "Administrator")]
    [InlineData("QA Admin", "QA Admin")]
    public async Task New_admin_is_created_with_expected_profile_and_assigned_role(string? name, string expectedName)
    {
        var users = BackendTestDoubles.Users();
        ApplicationUser? created = null;
        users.Setup(u => u.FindByEmailAsync("qa@example.test")).ReturnsAsync((ApplicationUser?)null);
        users.Setup(u => u.CreateAsync(It.IsAny<ApplicationUser>(), "QaPassword1!"))
            .Callback<ApplicationUser, string>((u, _) => created = u).ReturnsAsync(IdentityResult.Success);
        users.Setup(u => u.AddToRoleAsync(It.IsAny<ApplicationUser>(), "Admin")).ReturnsAsync(IdentityResult.Success);
        using var services = new ServiceCollection().AddSingleton(users.Object).BuildServiceProvider();
        await AdminBootstrapper.SeedAsync(services, Configuration(fullName: name));
        Assert.NotNull(created);
        Assert.Equal("qa@example.test", created.Email);
        Assert.Equal(created.Email, created.UserName);
        Assert.Equal(expectedName, created.FullName);
        users.Verify(u => u.AddToRoleAsync(created, "Admin"), Times.Once);
    }

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public async Task Existing_admin_account_is_preserved_and_role_only_added_if_missing(bool hasRole)
    {
        var user = new ApplicationUser { FullName = "Existing Profile" };
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByEmailAsync("qa@example.test")).ReturnsAsync(user);
        users.Setup(u => u.IsInRoleAsync(user, "Admin")).ReturnsAsync(hasRole);
        users.Setup(u => u.AddToRoleAsync(user, "Admin")).ReturnsAsync(IdentityResult.Success);
        using var services = new ServiceCollection().AddSingleton(users.Object).BuildServiceProvider();
        await AdminBootstrapper.SeedAsync(services, Configuration());
        Assert.Equal("Existing Profile", user.FullName);
        users.Verify(u => u.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()), Times.Never);
        users.Verify(u => u.AddToRoleAsync(user, "Admin"), hasRole ? Times.Never() : Times.Once());
    }

    [Fact]
    public async Task Create_failure_throws_error_code_and_does_not_assign_role()
    {
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.CreateAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Code = "InvalidPassword" }));
        using var services = new ServiceCollection().AddSingleton(users.Object).BuildServiceProvider();
        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => AdminBootstrapper.SeedAsync(services, Configuration()));
        Assert.Contains("InvalidPassword", error.Message);
        users.Verify(u => u.AddToRoleAsync(It.IsAny<ApplicationUser>(), It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task Role_assignment_failure_throws_error_code()
    {
        var users = BackendTestDoubles.Users();
        var user = new ApplicationUser();
        users.Setup(u => u.FindByEmailAsync("qa@example.test")).ReturnsAsync(user);
        users.Setup(u => u.AddToRoleAsync(user, "Admin"))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Code = "RoleUnavailable" }));
        using var services = new ServiceCollection().AddSingleton(users.Object).BuildServiceProvider();
        var error = await Assert.ThrowsAsync<InvalidOperationException>(() => AdminBootstrapper.SeedAsync(services, Configuration()));
        Assert.Contains("RoleUnavailable", error.Message);
    }

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public async Task Role_seeder_creates_only_missing_user_and_admin_roles(bool rolesExist)
    {
        var roles = BackendTestDoubles.Roles();
        var created = new List<string>();
        roles.Setup(r => r.RoleExistsAsync(It.IsAny<string>())).ReturnsAsync(rolesExist);
        roles.Setup(r => r.CreateAsync(It.IsAny<IdentityRole>()))
            .Callback<IdentityRole>(role => created.Add(role.Name!)).ReturnsAsync(IdentityResult.Success);
        using var services = new ServiceCollection().AddSingleton(roles.Object).BuildServiceProvider();
        await RoleSeeder.SeedAsync(services);
        Assert.Equal(rolesExist ? Array.Empty<string>() : new[] { "User", "Admin" }, created);
    }
}
