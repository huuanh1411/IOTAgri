using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using IOTAgriBackend.Data;
using IOTAgriBackend.Dtos.Auth;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace IOTAgriBackend.Endpoints;

public static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/auth").WithTags("Auth");

        group.MapPost("/register", RegisterAsync).RequireRateLimiting("authRegister");
        group.MapPost("/verify-email", VerifyEmailAsync).RequireRateLimiting("authVerifyEmail");
        group.MapPost("/resend-verification-code", ResendVerificationCodeAsync).RequireRateLimiting("authResendVerification");
        group.MapPost("/google", GoogleSignInAsync).RequireRateLimiting("authGoogle");
        group.MapPost("/login", LoginAsync);
        group.MapPost("/refresh", RefreshAsync);
        group.MapPost("/logout", LogoutAsync).RequireAuthorization();
        group.MapPost("/change-password", ChangePasswordAsync).RequireAuthorization();
        group.MapGet("/profile", GetProfileAsync).RequireAuthorization();
        group.MapPut("/profile", UpdateProfileAsync).RequireAuthorization();

        return app;
    }

    private static async Task<IResult> RegisterAsync(
        RegisterRequest request,
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db,
        IEmailSender emailSender,
        IConfiguration configuration)
    {
        if (string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password) ||
            string.IsNullOrWhiteSpace(request.FullName))
        {
            return Results.ValidationProblem(new Dictionary<string, string[]>
            {
                ["request"] = ["Email, password, and full name are required."]
            });
        }

        var existing = await userManager.FindByEmailAsync(request.Email);
        if (existing is not null)
        {
            return Results.Conflict(new { message = "A user with this email already exists." });
        }

        var user = new ApplicationUser
        {
            UserName = request.Email,
            Email = request.Email,
            FullName = request.FullName,
        };

        var createResult = await userManager.CreateAsync(user, request.Password);
        if (!createResult.Succeeded)
        {
            var errors = createResult.Errors.ToDictionary(e => e.Code, e => new[] { e.Description });
            return Results.ValidationProblem(errors);
        }

        await userManager.AddToRoleAsync(user, "User");
        await IssueVerificationCodeAsync(user, db, emailSender, configuration);

        return Results.Accepted();
    }

    private static async Task<IResult> VerifyEmailAsync(
        VerifyEmailRequest request,
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db,
        IConfiguration configuration)
    {
        var user = await db.Users.SingleOrDefaultAsync(user => user.NormalizedEmail == request.Email.ToUpperInvariant());
        if (user is null || user.EmailConfirmed)
        {
            return Results.BadRequest(new { error = "Invalid verification code." });
        }

        var now = DateTime.UtcNow;
        var code = await db.EmailVerificationCodes
            .Where(item => item.UserId == user.Id && item.ConsumedAt == null)
            .OrderByDescending(item => item.SentAt)
            .FirstOrDefaultAsync();
        if (code is null || code.ExpiresAt <= now || code.AttemptCount >= 5)
        {
            return Results.BadRequest(new { error = "Invalid verification code." });
        }

        if (!CryptographicOperations.FixedTimeEquals(
                Convert.FromHexString(code.CodeHash),
                Convert.FromHexString(HashVerificationCode(request.Code, configuration))))
        {
            code.AttemptCount++;
            return await SaveVerificationCodeChangeAsync(db);
        }

        // Save confirmation and code consumption in one EF unit of work. The code
        // concurrency token also rejects a concurrent resend using this code.
        code.ConsumedAt = now;
        user.EmailConfirmed = true;
        user.ConcurrencyStamp = Guid.NewGuid().ToString();
        try
        {
            await db.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            return Results.BadRequest(new { error = "Invalid verification code." });
        }

        return Results.NoContent();
    }

    private static async Task<IResult> ResendVerificationCodeAsync(
        ResendVerificationCodeRequest request,
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db,
        IEmailSender emailSender,
        IConfiguration configuration)
    {
        var user = await db.Users.SingleOrDefaultAsync(user => user.NormalizedEmail == request.Email.ToUpperInvariant());
        if (user is null || user.EmailConfirmed)
        {
            return Results.Accepted();
        }

        var latest = await db.EmailVerificationCodes
            .Where(item => item.UserId == user.Id && item.ConsumedAt == null)
            .OrderByDescending(item => item.SentAt)
            .FirstOrDefaultAsync();
        if (latest is not null && latest.SentAt > DateTime.UtcNow.AddMinutes(-1))
        {
            return Results.Accepted();
        }

        // Mutate the Identity concurrency stamp in the same save as replacement
        // creation. A confirmation that wins this race invalidates the resend save.
        user.ConcurrencyStamp = Guid.NewGuid().ToString();
        try
        {
            await IssueVerificationCodeAsync(user, db, emailSender, configuration, latest);
        }
        catch (DbUpdateConcurrencyException)
        {
            // Another request consumed or replaced this code first. Preserve the
            // enumeration-safe accepted response without sending a second email.
        }

        return Results.Accepted();
    }

    private static async Task<IResult> GoogleSignInAsync(
        GoogleSignInRequest request,
        IGoogleTokenValidator googleTokenValidator,
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db,
        ITokenService tokenService,
        IConfiguration configuration)
    {
        GoogleIdentity? identity;
        try
        {
            identity = await googleTokenValidator.ValidateAsync(request.IdToken);
        }
        catch (Exception)
        {
            return Results.Unauthorized();
        }

        if (identity is null)
        {
            return Results.Unauthorized();
        }

        var user = await userManager.FindByLoginAsync("Google", identity.Subject);
        if (user is null)
        {
            user = await userManager.FindByEmailAsync(identity.Email);
            if (user is not null && !user.EmailConfirmed)
            {
                return Results.Conflict(new { error = "Email verification is required before linking Google sign-in." });
            }

            if (user is null)
            {
                await using var transaction = db.Database.IsRelational()
                    ? await db.Database.BeginTransactionAsync()
                    : null;

                user = new ApplicationUser
                {
                    UserName = identity.Email,
                    Email = identity.Email,
                    EmailConfirmed = true,
                    FullName = identity.DisplayName,
                };

                var createResult = await userManager.CreateAsync(user);
                if (!createResult.Succeeded)
                {
                    return Results.ValidationProblem(createResult.Errors.ToDictionary(error => error.Code, error => new[] { error.Description }));
                }

                var roleResult = await userManager.AddToRoleAsync(user, "User");
                if (!roleResult.Succeeded)
                {
                    return Results.Problem("Unable to assign the user role.", statusCode: StatusCodes.Status500InternalServerError);
                }

                var loginResult = await userManager.AddLoginAsync(user, new UserLoginInfo("Google", identity.Subject, "Google"));
                if (!loginResult.Succeeded)
                {
                    return Results.Conflict(new { error = "Google sign-in is already linked to another account." });
                }

                if (transaction is not null)
                {
                    await transaction.CommitAsync();
                }

            }
            else
            {
                var loginResult = await userManager.AddLoginAsync(user, new UserLoginInfo("Google", identity.Subject, "Google"));
                if (!loginResult.Succeeded)
                {
                    return Results.Conflict(new { error = "Google sign-in is already linked to another account." });
                }
            }
        }

        if (await userManager.IsLockedOutAsync(user))
        {
            return Results.Unauthorized();
        }

        var roles = await userManager.GetRolesAsync(user);
        var response = await IssueTokensAsync(user, roles, db, tokenService, configuration);
        return Results.Ok(response);
    }

    private static async Task<IResult> LoginAsync(
        LoginRequest request,
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db,
        ITokenService tokenService,
        IConfiguration configuration)
    {
        var user = await userManager.FindByEmailAsync(request.Email);
        if (user is null || !await userManager.CheckPasswordAsync(user, request.Password))
        {
            return Results.Unauthorized();
        }

        if (await userManager.IsLockedOutAsync(user))
        {
            return Results.Unauthorized();
        }

        var roles = await userManager.GetRolesAsync(user);
        if (!user.EmailConfirmed && !roles.Contains("Admin"))
        {
            return Results.Json(new { error = "Email verification is required." }, statusCode: StatusCodes.Status403Forbidden);
        }

        var response = await IssueTokensAsync(user, roles, db, tokenService, configuration);
        return Results.Ok(response);
    }

    private static async Task<IResult> RefreshAsync(
        RefreshRequest request,
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db,
        ITokenService tokenService,
        IConfiguration configuration)
    {
        var existingToken = await db.RefreshTokens
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken);

        if (existingToken is null || !existingToken.IsActive || existingToken.User is null)
        {
            return Results.Unauthorized();
        }

        if (await userManager.IsLockedOutAsync(existingToken.User))
        {
            return Results.Unauthorized();
        }

        var roles = await userManager.GetRolesAsync(existingToken.User);
        var response = await IssueTokensAsync(existingToken.User, roles, db, tokenService, configuration, existingToken);
        return Results.Ok(response);
    }

    private static async Task<IResult> LogoutAsync(
        RefreshRequest request,
        ClaimsPrincipal principal,
        ApplicationDbContext db)
    {
        var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userId))
        {
            return Results.Unauthorized();
        }

        var token = await db.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == request.RefreshToken && rt.UserId == userId);

        if (token is null || !token.IsActive)
        {
            return Results.NoContent();
        }

        token.RevokedAt = DateTime.UtcNow;
        await db.SaveChangesAsync();

        return Results.NoContent();
    }

    private static async Task<IResult> ChangePasswordAsync(
        ChangePasswordRequest request,
        ClaimsPrincipal principal,
        UserManager<ApplicationUser> userManager,
        ApplicationDbContext db)
    {
        var user = await userManager.GetUserAsync(principal);
        if (user is null) return Results.Unauthorized();

        if (string.IsNullOrWhiteSpace(request.CurrentPassword) ||
            string.IsNullOrWhiteSpace(request.NewPassword) ||
            string.Equals(request.CurrentPassword, request.NewPassword, StringComparison.Ordinal))
        {
            return Results.BadRequest(new { error = "Current and new passwords are required and must differ." });
        }

        if (!await userManager.CheckPasswordAsync(user, request.CurrentPassword))
        {
            return Results.BadRequest(new { error = "Current password is incorrect." });
        }

        var result = await userManager.ChangePasswordAsync(user, request.CurrentPassword, request.NewPassword);
        if (!result.Succeeded)
        {
            return Results.ValidationProblem(result.Errors.ToDictionary(error => error.Code, error => new[] { error.Description }));
        }

        // Refresh tokens do not carry a device/session identifier, so this safely
        // revokes every refresh session when the user explicitly requests it.
        if (request.LogoutOtherDevices)
        {
            var now = DateTime.UtcNow;
            await db.RefreshTokens
                .Where(token => token.UserId == user.Id && token.RevokedAt == null && token.ExpiresAt > now)
                .ExecuteUpdateAsync(setters => setters.SetProperty(token => token.RevokedAt, now));
        }

        return Results.NoContent();
    }

    private static async Task<IResult> GetProfileAsync(
        ClaimsPrincipal principal,
        UserManager<ApplicationUser> userManager)
    {
        var user = await userManager.GetUserAsync(principal);
        if (user is null)
        {
            return Results.Unauthorized();
        }

        return Results.Ok(await ToProfileResponseAsync(user, userManager));
    }

    private static async Task<IResult> UpdateProfileAsync(
        UpdateProfileRequest request,
        ClaimsPrincipal principal,
        UserManager<ApplicationUser> userManager)
    {
        var user = await userManager.GetUserAsync(principal);
        if (user is null)
        {
            return Results.Unauthorized();
        }

        var error = ProfileRules.Validate(request.FullName, request.PhoneNumber, out var fullName, out var phoneNumber);
        if (error is not null)
        {
            return Results.BadRequest(new { error });
        }

        if (!string.Equals(user.PhoneNumber, phoneNumber, StringComparison.Ordinal))
        {
            user.PhoneNumberConfirmed = false;
        }

        user.FullName = fullName;
        user.PhoneNumber = phoneNumber;

        var updateResult = await userManager.UpdateAsync(user);
        if (!updateResult.Succeeded)
        {
            var errors = updateResult.Errors.ToDictionary(e => e.Code, e => new[] { e.Description });
            return Results.ValidationProblem(errors);
        }

        return Results.Ok(await ToProfileResponseAsync(user, userManager));
    }

    private static async Task<IResult> SaveVerificationCodeChangeAsync(ApplicationDbContext db)
    {
        try
        {
            await db.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            // A competing verification request already changed this code.
        }

        return Results.BadRequest(new { error = "Invalid verification code." });
    }

    private static async Task IssueVerificationCodeAsync(
        ApplicationUser user,
        ApplicationDbContext db,
        IEmailSender emailSender,
        IConfiguration configuration,
        EmailVerificationCode? codeToConsume = null)
    {
        var code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");
        if (codeToConsume is not null)
        {
            codeToConsume.ConsumedAt = DateTime.UtcNow;
        }

        db.EmailVerificationCodes.Add(EmailVerificationCode.Create(
            user.Id,
            code,
            VerificationPepper(configuration),
            DateTime.UtcNow));
        await db.SaveChangesAsync();
        await emailSender.SendVerificationCodeAsync(user.Email!, code);
    }

    private static string HashVerificationCode(string code, IConfiguration configuration) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes($"{VerificationPepper(configuration)}:{code}")));

    private static string VerificationPepper(IConfiguration configuration)
    {
        var pepper = configuration["EmailVerification:Pepper"];
        return !string.IsNullOrWhiteSpace(pepper)
            ? pepper
            : throw new InvalidOperationException("EmailVerification:Pepper is not configured.");
    }

    private static async Task<UserProfileResponse> ToProfileResponseAsync(
        ApplicationUser user,
        UserManager<ApplicationUser> userManager)
    {
        var roles = await userManager.GetRolesAsync(user);
        return new UserProfileResponse(
            user.Id,
            user.Email ?? string.Empty,
            user.FullName,
            user.PhoneNumber,
            roles.ToList());
    }

    private static async Task<AuthResponse> IssueTokensAsync(
        ApplicationUser user,
        IList<string> roles,
        ApplicationDbContext db,
        ITokenService tokenService,
        IConfiguration configuration,
        RefreshToken? tokenToRevoke = null)
    {
        var refreshExpiryDays = configuration.GetSection("Jwt").GetValue<int?>("RefreshTokenExpiryDays") ?? 7;
        var accessExpiryMinutes = configuration.GetSection("Jwt").GetValue<int?>("AccessTokenExpiryMinutes") ?? 15;

        var accessToken = tokenService.CreateAccessToken(user, roles);
        var refreshTokenValue = tokenService.GenerateRefreshTokenValue();

        var newRefreshToken = new RefreshToken
        {
            UserId = user.Id,
            Token = refreshTokenValue,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(refreshExpiryDays),
        };

        db.RefreshTokens.Add(newRefreshToken);

        if (tokenToRevoke is not null)
        {
            tokenToRevoke.RevokedAt = DateTime.UtcNow;
            tokenToRevoke.ReplacedByToken = refreshTokenValue;
        }

        await db.SaveChangesAsync();

        return new AuthResponse(accessToken, refreshTokenValue, DateTime.UtcNow.AddMinutes(accessExpiryMinutes));
    }
}
