using Google.Apis.Auth;

namespace IOTAgriBackend.Services;

public interface IGoogleIdTokenVerifier
{
    Task<GoogleJsonWebSignature.Payload?> VerifyAsync(string idToken, IReadOnlyCollection<string> allowedClientIds, CancellationToken cancellationToken = default);
}
