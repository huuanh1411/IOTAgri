using Google.Apis.Auth;

namespace IOTAgriBackend.Services;

public static class GoogleIdTokenValidationSettingsFactory
{
    public static GoogleJsonWebSignature.ValidationSettings Create(IReadOnlyCollection<string> allowedClientIds) => new()
    {
        Audience = allowedClientIds,
    };
}
