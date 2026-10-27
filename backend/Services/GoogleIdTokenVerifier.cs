using Google.Apis.Auth;

namespace IOTAgriBackend.Services;

public sealed class GoogleIdTokenVerifier : IGoogleIdTokenVerifier
{
    private readonly GoogleJwtValidationDelegate _validateAsync;

    public GoogleIdTokenVerifier()
        : this(GoogleJsonWebSignature.ValidateAsync)
    {
    }

    public GoogleIdTokenVerifier(GoogleJwtValidationDelegate validateAsync)
    {
        _validateAsync = validateAsync;
    }

    public async Task<GoogleJsonWebSignature.Payload?> VerifyAsync(
        string idToken,
        IReadOnlyCollection<string> allowedClientIds,
        CancellationToken cancellationToken = default)
    {
        GoogleIdTokenPolicy.Validate(idToken, allowedClientIds, DateTime.UtcNow);
        return await _validateAsync(idToken, GoogleIdTokenValidationSettingsFactory.Create(allowedClientIds));
    }
}
