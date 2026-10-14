using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Xunit;

namespace IOTAgriBackend.Tests;

public class TokenServiceTests
{
    private const string Key = "qa-only-signing-key-0123456789abcdef-0123456789abcdef";
    private static IConfiguration Configuration(string? key = Key, string? expiry = null) =>
        new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Jwt:Key"] = key, ["Jwt:Issuer"] = "qa-issuer", ["Jwt:Audience"] = "qa-audience",
            ["Jwt:AccessTokenExpiryMinutes"] = expiry,
        }).Build();

    [Theory]
    [InlineData(null, 15)]
    [InlineData("5", 5)]
    public void Access_token_has_valid_signature_identity_roles_and_expiry(string? configuredExpiry, int minutes)
    {
        var user = new ApplicationUser { Id = "qa-user", Email = "qa@example.test", FullName = "QA User" };
        var before = DateTime.UtcNow;
        var token = new TokenService(Configuration(expiry: configuredExpiry)).CreateAccessToken(user, new[] { "User", "Admin" });
        var after = DateTime.UtcNow;
        var handler = new JwtSecurityTokenHandler { MapInboundClaims = false };
        var principal = handler.ValidateToken(token, new TokenValidationParameters
        {
            ValidIssuer = "qa-issuer", ValidAudience = "qa-audience",
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Key)),
            ValidateLifetime = true, ClockSkew = TimeSpan.Zero,
        }, out var validated);
        var jwt = Assert.IsType<JwtSecurityToken>(validated);
        Assert.Equal(SecurityAlgorithms.HmacSha256, jwt.Header.Alg);
        Assert.Equal(user.Id, principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value);
        Assert.Equal(user.Id, principal.FindFirst(ClaimTypes.NameIdentifier)?.Value);
        Assert.Equal(user.Email, principal.FindFirst(JwtRegisteredClaimNames.Email)?.Value);
        Assert.Equal(user.FullName, principal.FindFirst("fullName")?.Value);
        Assert.Equal(new[] { "Admin", "User" }, principal.FindAll(ClaimTypes.Role).Select(c => c.Value).OrderBy(v => v));
        Assert.True(Guid.TryParse(principal.FindFirst(JwtRegisteredClaimNames.Jti)?.Value, out _));
        // JWT NumericDate truncates sub-second precision. Capture both sides of the call.
        Assert.InRange(jwt.ValidTo, before.AddMinutes(minutes).AddSeconds(-1), after.AddMinutes(minutes));
    }

    [Fact]
    public void Missing_key_throws_explicit_configuration_error()
    {
        var error = Assert.Throws<InvalidOperationException>(() => new TokenService(Configuration(null))
            .CreateAccessToken(new ApplicationUser(), Array.Empty<string>()));
        Assert.Equal("Jwt:Key is not configured.", error.Message);
    }

    [Fact]
    public void Null_email_and_no_roles_produce_empty_email_without_role_claims()
    {
        var token = new TokenService(Configuration()).CreateAccessToken(new ApplicationUser { Email = null }, Array.Empty<string>());
        var jwt = new JwtSecurityTokenHandler().ReadJwtToken(token);
        Assert.Equal(string.Empty, jwt.Claims.Single(c => c.Type == JwtRegisteredClaimNames.Email).Value);
        Assert.DoesNotContain(jwt.Claims, c => c.Type == ClaimTypes.Role);
    }

    [Fact]
    public void Token_is_rejected_when_validated_with_a_different_signing_key()
    {
        var handler = new JwtSecurityTokenHandler();
        var token = new TokenService(Configuration()).CreateAccessToken(new ApplicationUser(), Array.Empty<string>());
        Assert.Throws<SecurityTokenSignatureKeyNotFoundException>(() => handler.ValidateToken(token, new TokenValidationParameters
        {
            ValidIssuer = "qa-issuer", ValidAudience = "qa-audience",
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Key.Replace("qa-only", "wrong!!"))),
        }, out _));
    }

    [Fact]
    public void Refresh_token_is_valid_base64_encoding_of_64_bytes()
    {
        var token = new TokenService(Configuration()).GenerateRefreshTokenValue();
        Assert.Equal(64, Convert.FromBase64String(token).Length);
    }
}
