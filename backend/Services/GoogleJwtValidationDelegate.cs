using Google.Apis.Auth;

namespace IOTAgriBackend.Services;

public delegate Task<GoogleJsonWebSignature.Payload> GoogleJwtValidationDelegate(
    string idToken,
    GoogleJsonWebSignature.ValidationSettings settings);
