using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Auth;
using IOTAgriBackend.Endpoints;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Moq;
using Xunit;

namespace IOTAgriBackend.Tests;

public class AuthHandlerTests
{
    [Theory]
    [InlineData(false, false)]
    [InlineData(true, false)]
    public async Task Unknown_user_or_wrong_password_returns_unauthorized_without_database(bool exists, bool passwordCorrect)
    {
        var user = new ApplicationUser();
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByEmailAsync("qa@example.test")).ReturnsAsync(exists ? user : null);
        users.Setup(u => u.CheckPasswordAsync(user, "wrong-password")).ReturnsAsync(passwordCorrect);
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LoginAsync", new LoginRequest("qa@example.test", "wrong-password"), users.Object, null, null, null);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        users.Verify(u => u.GetRolesAsync(It.IsAny<ApplicationUser>()), Times.Never);
    }

    [Fact]
    public async Task Locked_user_with_correct_password_must_not_receive_tokens()
    {
        // Regression for the account-lock feature. No real DB or token issuer is used.
        // Intentionally retain FAIL if LoginAsync bypasses Identity lockout.
        var user = new ApplicationUser { Id = "locked-user", LockoutEnabled = true, LockoutEnd = DateTimeOffset.MaxValue };
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByEmailAsync("locked@example.test")).ReturnsAsync(user);
        users.Setup(u => u.CheckPasswordAsync(user, "QaPassword1!")).ReturnsAsync(true);
        users.Setup(u => u.IsLockedOutAsync(user)).ReturnsAsync(true);
        users.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.CreateAccessToken(user, It.IsAny<IList<string>>())).Returns("qa-access-token");
        tokens.Setup(t => t.GenerateRefreshTokenValue()).Returns("qa-refresh-token");
        var set = new Mock<DbSet<RefreshToken>>();
        var db = new Mock<ApplicationDbContext>(new DbContextOptionsBuilder<ApplicationDbContext>().Options);
        db.Setup(d => d.Set<RefreshToken>()).Returns(set.Object);
        db.Setup(d => d.SaveChangesAsync(It.IsAny<CancellationToken>())).ReturnsAsync(1);
        var config = new ConfigurationBuilder().AddInMemoryCollection().Build();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LoginAsync",
            new LoginRequest("locked@example.test", "QaPassword1!"), users.Object, db.Object, tokens.Object, config);
        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        tokens.Verify(t => t.GenerateRefreshTokenValue(), Times.Never);
    }

    [Fact]
    public async Task Profile_update_normalizes_fields_resets_phone_confirmation_and_returns_roles()
    {
        var user = new ApplicationUser { Id = "qa-user", Email = "qa@example.test", PhoneNumber = "0912345678", PhoneNumberConfirmed = true };
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.GetUserAsync(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(user);
        users.Setup(u => u.UpdateAsync(user)).ReturnsAsync(Microsoft.AspNetCore.Identity.IdentityResult.Success);
        users.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "UpdateProfileAsync",
            new UpdateProfileRequest("  QA Name  ", "  0987654321  "), new ClaimsPrincipal(), users.Object);
        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        var profile = Assert.IsType<UserProfileResponse>(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        Assert.Equal("QA Name", profile.FullName);
        Assert.Equal("0987654321", profile.PhoneNumber);
        Assert.Equal(new[] { "User" }, profile.Roles);
        Assert.False(user.PhoneNumberConfirmed);
    }

    [Fact]
    public async Task Profile_update_validation_failure_does_not_persist()
    {
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.GetUserAsync(It.IsAny<ClaimsPrincipal>())).ReturnsAsync(new ApplicationUser());
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "UpdateProfileAsync",
            new UpdateProfileRequest(" ", null), new ClaimsPrincipal(), users.Object);
        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        users.Verify(u => u.UpdateAsync(It.IsAny<ApplicationUser>()), Times.Never);
    }
}
