using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Google.Apis.Auth;
using IOTAgriBackend.Services;
using Microsoft.Extensions.Options;
using Moq;
using Xunit;

namespace IOTAgriBackend.Tests;

public class GoogleTokenValidatorTests
{
    [Theory]
    [InlineData("invalid signature")]
    [InlineData("invalid issuer")]
    [InlineData("invalid audience")]
    [InlineData("expired token")]
    public async Task Rejects_library_validation_failures(string failure)
    {
        var verifier = new Mock<IGoogleIdTokenVerifier>();
        verifier.Setup(v => v.VerifyAsync("id-token", It.IsAny<IReadOnlyCollection<string>>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new InvalidJwtException(failure));
        var validator = CreateValidator(verifier.Object);

        var identity = await validator.ValidateAsync("id-token");

        Assert.Null(identity);
        verifier.Verify(v => v.VerifyAsync("id-token", It.Is<IReadOnlyCollection<string>>(audiences => audiences.Single() == "client-id"), It.IsAny<CancellationToken>()), Times.Once);
    }

    [Theory]
    [InlineData("https://evil.example", "client-id", false)]
    [InlineData("https://accounts.google.com", "other-client", false)]
    [InlineData("https://accounts.google.com", "client-id", true)]
    public async Task Production_verifier_rejects_invalid_claims_before_calling_google_signature_validator(
        string issuer,
        string audience,
        bool expired)
    {
        var googleValidationCalled = false;
        var verifier = new GoogleIdTokenVerifier((_, _) =>
        {
            googleValidationCalled = true;
            return Task.FromResult(new GoogleJsonWebSignature.Payload());
        });
        var token = CreateUnsignedJwt(issuer, audience, expired ? DateTime.UtcNow.AddMinutes(-1) : DateTime.UtcNow.AddHours(1));

        await Assert.ThrowsAsync<InvalidOperationException>(() => verifier.VerifyAsync(token, ["client-id"]));

        Assert.False(googleValidationCalled);
    }

    [Fact]
    public async Task Production_verifier_sends_valid_claim_token_to_google_signature_validator()
    {
        GoogleJsonWebSignature.ValidationSettings? capturedSettings = null;
        var verifier = new GoogleIdTokenVerifier((_, settings) =>
        {
            capturedSettings = settings;
            throw new InvalidJwtException("bad signature");
        });
        var token = CreateUnsignedJwt("https://accounts.google.com", "client-id", DateTime.UtcNow.AddHours(1));

        await Assert.ThrowsAsync<InvalidJwtException>(() => verifier.VerifyAsync(token, ["client-id"]));

        Assert.NotNull(capturedSettings);
        Assert.Equal(new[] { "client-id" }, capturedSettings!.Audience);
    }

    [Fact]
    public void Production_verification_settings_pass_configured_audiences_to_google_library()
    {
        var settings = GoogleIdTokenValidationSettingsFactory.Create(["client-id"]);

        Assert.Equal(new[] { "client-id" }, settings.Audience);
    }

    [Fact]
    public async Task Rejects_payload_with_unverified_email()
    {
        var verifier = new Mock<IGoogleIdTokenVerifier>();
        verifier.Setup(v => v.VerifyAsync("id-token", It.IsAny<IReadOnlyCollection<string>>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new GoogleJsonWebSignature.Payload
            {
                Subject = "google-subject",
                Email = "google@example.test",
                EmailVerified = false,
            });
        var validator = CreateValidator(verifier.Object);

        var identity = await validator.ValidateAsync("id-token");

        Assert.Null(identity);
    }

    private static string CreateUnsignedJwt(string issuer, string audience, DateTime expiresAt) =>
        new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler().WriteToken(
            new System.IdentityModel.Tokens.Jwt.JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                expires: expiresAt,
                claims: [new System.Security.Claims.Claim("sub", "subject")]));

    private static string CreateInvalidJwt(string failure) => failure switch
    {
        "invalid signature" => "eyJhbGciOiJSUzI1NiIsImtpZCI6Im5vdC1nb29nbGUifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXVkIjoiY2xpZW50LWlkIiwiZXhwIjo0MTAyNDQ0ODAwLCJzdWIiOiJzdWJqZWN0IiwiZW1haWwiOiJnb29nbGVAZXhhbXBsZS50ZXN0In0.invalid",
        "invalid issuer" => "eyJhbGciOiJSUzI1NiIsImtpZCI6Im5vdC1nb29nbGUifQ.eyJpc3MiOiJodHRwczovL2V2aWwuZXhhbXBsZSIsImF1ZCI6ImNsaWVudC1pZCIsImV4cCI6NDEwMjQ0NDgwMCwic3ViIjoic3ViamVjdCIsImVtYWlsIjoiZ29vZ2xlQGV4YW1wbGUudGVzdCJ9.invalid",
        "invalid audience" => "eyJhbGciOiJSUzI1NiIsImtpZCI6Im5vdC1nb29nbGUifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXVkIjoiZWRpbC1jbGllbnQiLCJleHAiOjQxMDI0NDQ4MDAsInN1YiI6InN1YmplY3QiLCJlbWFpbCI6Imdvb2dsZUBleGFtcGxlLnRlc3QifQ.invalid",
        "expired token" => "eyJhbGciOiJSUzI1NiIsImtpZCI6Im5vdC1nb29nbGUifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXVkIjoiY2xpZW50LWlkIiwiZXhwIjoxLCJzdWIiOiJzdWJqZWN0IiwiZW1haWwiOiJnb29nbGVAZXhhbXBsZS50ZXN0In0.invalid",
        _ => throw new ArgumentOutOfRangeException(nameof(failure)),
    };

    private static GoogleTokenValidator CreateValidator(IGoogleIdTokenVerifier verifier) => new(
        Options.Create(new GoogleAuthOptions { AllowedClientIds = ["client-id"] }), verifier);
}
