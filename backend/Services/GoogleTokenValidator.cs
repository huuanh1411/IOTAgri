using Google.Apis.Auth;
using Microsoft.Extensions.Options;

namespace IOTAgriBackend.Services;

public sealed class GoogleTokenValidator(IOptions<GoogleAuthOptions> options, IGoogleIdTokenVerifier verifier) : IGoogleTokenValidator
{
    private readonly GoogleAuthOptions _options = options.Value;
    private readonly IGoogleIdTokenVerifier _verifier = verifier;

    public async Task<GoogleIdentity?> ValidateAsync(string idToken, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(idToken) || _options.AllowedClientIds.Length == 0)
        {
            return null;
        }

        try
        {
            var payload = await _verifier.VerifyAsync(idToken, _options.AllowedClientIds, cancellationToken);
            if (payload is null)
            {
                return null;
            }

            if (!payload.EmailVerified || string.IsNullOrWhiteSpace(payload.Subject) || string.IsNullOrWhiteSpace(payload.Email))
            {
                return null;
            }

            return new GoogleIdentity(payload.Subject, payload.Email, payload.Name ?? string.Empty);
        }
        catch (Exception exception) when (exception is InvalidJwtException or HttpRequestException)
        {
            return null;
        }
    }
}
