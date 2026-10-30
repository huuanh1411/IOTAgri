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
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
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
    public async Task Correct_password_for_unconfirmed_user_returns_forbidden()
    {
        var user = new ApplicationUser { EmailConfirmed = false };
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByEmailAsync("unconfirmed@example.test")).ReturnsAsync(user);
        users.Setup(u => u.CheckPasswordAsync(user, "QaPassword1!")).ReturnsAsync(true);
        users.Setup(u => u.IsLockedOutAsync(user)).ReturnsAsync(false);
        users.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LoginAsync",
            new LoginRequest("unconfirmed@example.test", "QaPassword1!"), users.Object, null, null, null);

        Assert.Equal(403, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Fact]
    public async Task Correct_password_for_unconfirmed_admin_issues_tokens()
    {
        var user = new ApplicationUser { Id = "admin-user", EmailConfirmed = false };
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByEmailAsync("admin@example.test")).ReturnsAsync(user);
        users.Setup(u => u.CheckPasswordAsync(user, "QaPassword1!")).ReturnsAsync(true);
        users.Setup(u => u.IsLockedOutAsync(user)).ReturnsAsync(false);
        users.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(new List<string> { "Admin" });
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.CreateAccessToken(user, It.IsAny<IList<string>>())).Returns("access-token");
        tokens.Setup(t => t.GenerateRefreshTokenValue()).Returns("refresh-token");
        await using var db = CreateDatabase();

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "LoginAsync",
            new LoginRequest("admin@example.test", "QaPassword1!"), users.Object, db, tokens.Object, Configuration());

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    [Fact]
    public async Task Resend_for_unknown_email_returns_accepted_without_sending_mail()
    {
        var users = BackendTestDoubles.Users();
        var sender = new Mock<IEmailSender>();
        users.Setup(u => u.FindByEmailAsync("unknown@example.test")).ReturnsAsync((ApplicationUser?)null);

        await using var db = CreateDatabase();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "ResendVerificationCodeAsync",
            new ResendVerificationCodeRequest("unknown@example.test"), users.Object, db, sender.Object, Configuration());

        Assert.Equal(202, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        sender.Verify(s => s.SendVerificationCodeAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task Register_rejects_blank_verification_pepper_before_issuing_a_code()
    {
        var users = BackendTestDoubles.Users();
        var sender = new Mock<IEmailSender>();
        users.Setup(u => u.FindByEmailAsync("new@example.test")).ReturnsAsync((ApplicationUser?)null);
        users.Setup(u => u.CreateAsync(It.IsAny<ApplicationUser>(), "QaPassword1!")).ReturnsAsync(IdentityResult.Success)
            .Callback<ApplicationUser, string>((created, _) => created.Id = "new-user");
        users.Setup(u => u.AddToRoleAsync(It.IsAny<ApplicationUser>(), "User")).ReturnsAsync(IdentityResult.Success);
        await using var db = CreateDatabase();
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> { ["EmailVerification:Pepper"] = " " })
            .Build();

        var exception = await Assert.ThrowsAsync<InvalidOperationException>(() =>
            BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "RegisterAsync",
                new RegisterRequest("new@example.test", "QaPassword1!", "New User"), users.Object, db, sender.Object, configuration));

        Assert.Equal("EmailVerification:Pepper is not configured.", exception.Message);
        Assert.Empty(await db.EmailVerificationCodes.ToListAsync());
        sender.Verify(s => s.SendVerificationCodeAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task Register_creates_one_code_sends_mail_and_returns_accepted()
    {
        var user = new ApplicationUser { Id = "new-user" };
        var users = BackendTestDoubles.Users();
        var sender = new Mock<IEmailSender>();
        users.Setup(u => u.FindByEmailAsync("new@example.test")).ReturnsAsync((ApplicationUser?)null);
        users.Setup(u => u.CreateAsync(It.IsAny<ApplicationUser>(), "QaPassword1!")).ReturnsAsync(Microsoft.AspNetCore.Identity.IdentityResult.Success)
            .Callback<ApplicationUser, string>((created, _) => created.Id = user.Id);
        users.Setup(u => u.AddToRoleAsync(It.IsAny<ApplicationUser>(), "User")).ReturnsAsync(Microsoft.AspNetCore.Identity.IdentityResult.Success);

        await using var db = CreateDatabase();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "RegisterAsync",
            new RegisterRequest("new@example.test", "QaPassword1!", "New User"), users.Object, db, sender.Object, Configuration());

        Assert.Equal(202, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Single(await db.EmailVerificationCodes.ToListAsync());
        sender.Verify(s => s.SendVerificationCodeAsync("new@example.test", It.Is<string>(code => code.Length == 6), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Verification_consumes_valid_code_and_confirms_email()
    {
        var user = new ApplicationUser { Id = "verified-user", Email = "verify@example.test", NormalizedEmail = "VERIFY@EXAMPLE.TEST", EmailConfirmed = false };
        var users = BackendTestDoubles.Users();
        await using var db = CreateDatabase();
        db.Users.Add(user);
        db.EmailVerificationCodes.Add(EmailVerificationCode.Create(user.Id, "123456", "test-pepper", DateTime.UtcNow));
        await db.SaveChangesAsync();

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "VerifyEmailAsync",
            new VerifyEmailRequest("verify@example.test", "123456"), users.Object, db, Configuration());

        Assert.Equal(204, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.True(user.EmailConfirmed);
        Assert.NotNull((await db.EmailVerificationCodes.SingleAsync()).ConsumedAt);
    }

    [Fact]
    public async Task Verification_saves_code_consumption_and_confirmation_in_one_context_without_identity_update()
    {
        var user = new ApplicationUser { Id = "atomic-user", Email = "atomic@example.test", NormalizedEmail = "ATOMIC@EXAMPLE.TEST", EmailConfirmed = false };
        var users = BackendTestDoubles.Users();
        await using var db = CreateDatabase();
        db.Users.Add(user);
        db.EmailVerificationCodes.Add(EmailVerificationCode.Create(user.Id, "123456", "test-pepper", DateTime.UtcNow));
        await db.SaveChangesAsync();

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "VerifyEmailAsync",
            new VerifyEmailRequest("atomic@example.test", "123456"), users.Object, db, Configuration());

        Assert.Equal(204, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.True(user.EmailConfirmed);
        Assert.NotNull((await db.EmailVerificationCodes.SingleAsync()).ConsumedAt);
        users.Verify(u => u.UpdateAsync(It.IsAny<ApplicationUser>()), Times.Never);
    }

    [Theory]
    [InlineData("654321", 0, false)]
    [InlineData("123456", 0, true)]
    [InlineData("654321", 5, false)]
    public async Task Verification_rejects_invalid_expired_or_exhausted_codes(string suppliedCode, int attempts, bool expired)
    {
        var user = new ApplicationUser { Id = "rejected-user", Email = "reject@example.test", NormalizedEmail = "REJECT@EXAMPLE.TEST", EmailConfirmed = false };
        var users = BackendTestDoubles.Users();
        await using var db = CreateDatabase();
        db.Users.Add(user);
        var code = EmailVerificationCode.Create(user.Id, "123456", "test-pepper", DateTime.UtcNow);
        code.AttemptCount = attempts;
        if (expired) code.ExpiresAt = DateTime.UtcNow.AddMinutes(-1);
        db.EmailVerificationCodes.Add(code);
        await db.SaveChangesAsync();

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "VerifyEmailAsync",
            new VerifyEmailRequest("reject@example.test", suppliedCode), users.Object, db, Configuration());

        Assert.Equal(400, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.False(user.EmailConfirmed);
        if (suppliedCode == "654321" && attempts == 0)
        {
            Assert.Equal(1, (await db.EmailVerificationCodes.SingleAsync()).AttemptCount);
        }
    }

    [Fact]
    public async Task Resend_after_one_minute_replaces_active_code_and_sends_mail()
    {
        var user = new ApplicationUser { Id = "resend-user", EmailConfirmed = false, Email = "resend@example.test", NormalizedEmail = "RESEND@EXAMPLE.TEST" };
        var users = BackendTestDoubles.Users();
        var sender = new Mock<IEmailSender>();
        await using var db = CreateDatabase();
        db.Users.Add(user);
        var existing = EmailVerificationCode.Create(user.Id, "123456", "test-pepper", DateTime.UtcNow.AddMinutes(-2));
        db.EmailVerificationCodes.Add(existing);
        await db.SaveChangesAsync();

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "ResendVerificationCodeAsync",
            new ResendVerificationCodeRequest("resend@example.test"), users.Object, db, sender.Object, Configuration());

        Assert.Equal(202, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Equal(2, await db.EmailVerificationCodes.CountAsync());
        Assert.NotNull((await db.EmailVerificationCodes.SingleAsync(item => item.Id == existing.Id)).ConsumedAt);
        sender.Verify(s => s.SendVerificationCodeAsync("resend@example.test", It.Is<string>(code => code.Length == 6), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Resend_persists_user_concurrency_guard_before_sending_mail()
    {
        var user = new ApplicationUser
        {
            Id = "resend-guard-user",
            Email = "resend-guard@example.test",
            NormalizedEmail = "RESEND-GUARD@EXAMPLE.TEST",
            EmailConfirmed = false,
            ConcurrencyStamp = "before-resend",
        };
        var users = BackendTestDoubles.Users();
        var sender = new Mock<IEmailSender>();
        await using var db = CreateDatabase();
        db.Users.Add(user);
        await db.SaveChangesAsync();

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "ResendVerificationCodeAsync",
            new ResendVerificationCodeRequest("resend-guard@example.test"), users.Object, db, sender.Object, Configuration());

        Assert.Equal(202, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.NotEqual("before-resend", (await db.Users.SingleAsync(candidate => candidate.Id == user.Id)).ConcurrencyStamp);
        sender.Verify(s => s.SendVerificationCodeAsync(user.Email, It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Resend_within_one_minute_returns_accepted_without_sending_or_replacing_code()
    {
        var user = new ApplicationUser { Id = "limited-user", EmailConfirmed = false, Email = "limited@example.test", NormalizedEmail = "LIMITED@EXAMPLE.TEST" };
        var users = BackendTestDoubles.Users();
        var sender = new Mock<IEmailSender>();
        await using var db = CreateDatabase();
        db.Users.Add(user);
        var existing = EmailVerificationCode.Create(user.Id, "123456", "test-pepper", DateTime.UtcNow);
        db.EmailVerificationCodes.Add(existing);
        await db.SaveChangesAsync();

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "ResendVerificationCodeAsync",
            new ResendVerificationCodeRequest("limited@example.test"), users.Object, db, sender.Object, Configuration());

        Assert.Equal(202, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Single(await db.EmailVerificationCodes.ToListAsync());
        sender.Verify(s => s.SendVerificationCodeAsync(It.IsAny<string>(), It.IsAny<string>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task Delete_account_rejects_admin_user()
    {
        var user = new ApplicationUser { Id = "admin-1" };
        var users = BackendTestDoubles.Users();
        users.Setup(manager => manager.FindByIdAsync(user.Id)).ReturnsAsync(user);
        users.Setup(manager => manager.GetRolesAsync(user)).ReturnsAsync(new[] { "Admin" });

        var result = await BackendTestDoubles.InvokeHandler(
            typeof(AuthEndpoints), "DeleteAccountAsync", Principal(user.Id), users.Object, CreateDatabase(), CancellationToken.None);

        Assert.IsType<Microsoft.AspNetCore.Http.HttpResults.ForbidHttpResult>(result);
    }

    [Fact]
    public async Task Delete_account_returns_unauthorized_when_subject_is_missing()
    {
        var result = await BackendTestDoubles.InvokeHandler(
            typeof(AuthEndpoints), "DeleteAccountAsync", new ClaimsPrincipal(), BackendTestDoubles.Users().Object, CreateDatabase(), CancellationToken.None);

        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
    }

    private static ClaimsPrincipal Principal(string id) => new(new ClaimsIdentity(new[]
    {
        new Claim(ClaimTypes.NameIdentifier, id)
    }, "test"));

    private static ApplicationDbContext CreateDatabase() => new(new DbContextOptionsBuilder<ApplicationDbContext>()
        .UseInMemoryDatabase(Guid.NewGuid().ToString())
        .Options);

    private static IConfiguration Configuration() => new ConfigurationBuilder()
        .AddInMemoryCollection(new Dictionary<string, string?> { ["EmailVerification:Pepper"] = "test-pepper" })
        .Build();

    [Fact]
    public async Task Verified_google_identity_creates_confirmed_user_and_issues_tokens()
    {
        var identity = new GoogleIdentity("google-subject", "google@example.test", "Google User");
        var validator = new Mock<IGoogleTokenValidator>();
        validator.Setup(v => v.ValidateAsync("valid-id-token", It.IsAny<CancellationToken>())).ReturnsAsync(identity);
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByLoginAsync("Google", identity.Subject)).ReturnsAsync((ApplicationUser?)null);
        users.Setup(u => u.FindByEmailAsync(identity.Email)).ReturnsAsync((ApplicationUser?)null);
        users.Setup(u => u.CreateAsync(It.IsAny<ApplicationUser>())).ReturnsAsync(IdentityResult.Success)
            .Callback<ApplicationUser>(created => created.Id = "google-user");
        users.Setup(u => u.AddToRoleAsync(It.IsAny<ApplicationUser>(), "User")).ReturnsAsync(IdentityResult.Success);
        users.Setup(u => u.AddLoginAsync(It.IsAny<ApplicationUser>(), It.Is<UserLoginInfo>(login => login.LoginProvider == "Google" && login.ProviderKey == identity.Subject))).ReturnsAsync(IdentityResult.Success);
        users.Setup(u => u.GetRolesAsync(It.IsAny<ApplicationUser>())).ReturnsAsync(new List<string> { "User" });
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.CreateAccessToken(It.IsAny<ApplicationUser>(), It.IsAny<IList<string>>())).Returns("google-access-token");
        tokens.Setup(t => t.GenerateRefreshTokenValue()).Returns("google-refresh-token");

        await using var db = CreateDatabase();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "GoogleSignInAsync",
            new GoogleSignInRequest("valid-id-token"), validator.Object, users.Object, db, tokens.Object, Configuration());

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        var response = Assert.IsType<AuthResponse>(Assert.IsAssignableFrom<IValueHttpResult>(result).Value);
        Assert.Equal("google-access-token", response.AccessToken);
        users.Verify(u => u.CreateAsync(It.Is<ApplicationUser>(user => user.Email == identity.Email && user.UserName == identity.Email && user.FullName == identity.DisplayName && user.EmailConfirmed)), Times.Once);
        users.Verify(u => u.AddToRoleAsync(It.IsAny<ApplicationUser>(), "User"), Times.Once);
        users.Verify(u => u.AddLoginAsync(It.IsAny<ApplicationUser>(), It.IsAny<UserLoginInfo>()), Times.Once);
    }

    [Fact]
    public async Task Failed_external_login_for_new_google_user_rolls_back_identity_records()
    {
        var identity = new GoogleIdentity("google-subject", "new@example.test", "Google User");
        var validator = new Mock<IGoogleTokenValidator>();
        validator.Setup(v => v.ValidateAsync("valid-id-token", It.IsAny<CancellationToken>())).ReturnsAsync(identity);
        await using var connection = new Microsoft.Data.Sqlite.SqliteConnection("Data Source=:memory:");
        await connection.OpenAsync();
        await using var db = new ApplicationDbContext(new DbContextOptionsBuilder<ApplicationDbContext>().UseSqlite(connection).Options);
        await db.Database.EnsureCreatedAsync();
        db.Roles.Add(new IdentityRole { Id = "user-role", Name = "User", NormalizedName = "USER" });
        await db.SaveChangesAsync();
        var store = new Microsoft.AspNetCore.Identity.EntityFrameworkCore.UserStore<ApplicationUser, IdentityRole, ApplicationDbContext>(db);
        var users = new Mock<UserManager<ApplicationUser>>(
            store, Options.Create(new IdentityOptions()), new PasswordHasher<ApplicationUser>(),
            Array.Empty<IUserValidator<ApplicationUser>>(), Array.Empty<IPasswordValidator<ApplicationUser>>(),
            new UpperInvariantLookupNormalizer(), new IdentityErrorDescriber(), Mock.Of<IServiceProvider>(),
            Microsoft.Extensions.Logging.Abstractions.NullLogger<UserManager<ApplicationUser>>.Instance) { CallBase = true };
        users.Setup(u => u.AddLoginAsync(It.IsAny<ApplicationUser>(), It.IsAny<UserLoginInfo>()))
            .ReturnsAsync(IdentityResult.Failed(new IdentityError { Description = "Duplicate provider key" }));

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "GoogleSignInAsync",
            new GoogleSignInRequest("valid-id-token"), validator.Object, users.Object, db, new Mock<ITokenService>().Object, Configuration());

        Assert.Equal(409, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.Empty(await db.Users.ToListAsync());
        Assert.Empty(await db.UserRoles.ToListAsync());
    }

    [Fact]
    public async Task Unverified_google_email_is_rejected()
    {
        var validator = new Mock<IGoogleTokenValidator>();
        validator.Setup(v => v.ValidateAsync("unverified-id-token", It.IsAny<CancellationToken>())).ReturnsAsync((GoogleIdentity?)null);
        var users = BackendTestDoubles.Users();

        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "GoogleSignInAsync",
            new GoogleSignInRequest("unverified-id-token"), validator.Object, users.Object, null, null, Configuration());

        Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        users.Verify(u => u.FindByEmailAsync(It.IsAny<string>()), Times.Never);
    }

    [Fact]
    public async Task Google_identity_links_matching_confirmed_user_and_issues_tokens()
    {
        var identity = new GoogleIdentity("google-subject", "confirmed@example.test", "Google User");
        var user = new ApplicationUser { Id = "confirmed-user", Email = identity.Email, EmailConfirmed = true };
        var validator = new Mock<IGoogleTokenValidator>();
        validator.Setup(v => v.ValidateAsync("valid-id-token", It.IsAny<CancellationToken>())).ReturnsAsync(identity);
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByLoginAsync("Google", identity.Subject)).ReturnsAsync((ApplicationUser?)null);
        users.Setup(u => u.FindByEmailAsync(identity.Email)).ReturnsAsync(user);
        users.Setup(u => u.AddLoginAsync(user, It.Is<UserLoginInfo>(login => login.LoginProvider == "Google" && login.ProviderKey == identity.Subject))).ReturnsAsync(IdentityResult.Success);
        users.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.CreateAccessToken(user, It.IsAny<IList<string>>())).Returns("google-access-token");
        tokens.Setup(t => t.GenerateRefreshTokenValue()).Returns("google-refresh-token");

        await using var db = CreateDatabase();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "GoogleSignInAsync",
            new GoogleSignInRequest("valid-id-token"), validator.Object, users.Object, db, tokens.Object, Configuration());

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        users.Verify(u => u.CreateAsync(It.IsAny<ApplicationUser>()), Times.Never);
        users.Verify(u => u.AddLoginAsync(user, It.IsAny<UserLoginInfo>()), Times.Once);
    }

    [Fact]
    public async Task Google_identity_confirms_and_links_matching_unconfirmed_user()
    {
        var identity = new GoogleIdentity("google-subject", "unconfirmed@example.test", "Google User");
        var user = new ApplicationUser { Id = "unconfirmed-user", Email = identity.Email, EmailConfirmed = false };
        var validator = new Mock<IGoogleTokenValidator>();
        validator.Setup(v => v.ValidateAsync("valid-id-token", It.IsAny<CancellationToken>())).ReturnsAsync(identity);
        var users = BackendTestDoubles.Users();
        users.Setup(u => u.FindByLoginAsync("Google", identity.Subject)).ReturnsAsync((ApplicationUser?)null);
        users.Setup(u => u.FindByEmailAsync(identity.Email)).ReturnsAsync(user);
        users.Setup(u => u.UpdateAsync(user)).ReturnsAsync(IdentityResult.Success);
        users.Setup(u => u.AddLoginAsync(user, It.Is<UserLoginInfo>(login => login.LoginProvider == "Google" && login.ProviderKey == identity.Subject))).ReturnsAsync(IdentityResult.Success);
        users.Setup(u => u.GetRolesAsync(user)).ReturnsAsync(new List<string> { "User" });
        var tokens = new Mock<ITokenService>();
        tokens.Setup(t => t.CreateAccessToken(user, It.IsAny<IList<string>>())).Returns("google-access-token");
        tokens.Setup(t => t.GenerateRefreshTokenValue()).Returns("google-refresh-token");

        await using var db = CreateDatabase();
        var result = await BackendTestDoubles.InvokeHandler(typeof(AuthEndpoints), "GoogleSignInAsync",
            new GoogleSignInRequest("valid-id-token"), validator.Object, users.Object, db, tokens.Object, Configuration());

        Assert.Equal(200, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
        Assert.True(user.EmailConfirmed);
        users.Verify(u => u.UpdateAsync(user), Times.Once);
        users.Verify(u => u.AddLoginAsync(user, It.IsAny<UserLoginInfo>()), Times.Once);
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
