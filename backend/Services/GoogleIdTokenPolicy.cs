using System.IdentityModel.Tokens.Jwt;

namespace IOTAgriBackend.Services;

public static class GoogleIdTokenPolicy
{
    private static readonly HashSet<string> ValidIssuers = ["accounts.google.com", "https://accounts.google.com"];

    public static void Validate(string idToken, IReadOnlyCollection<string> allowedClientIds, DateTime utcNow)
    {
        var token = new JwtSecurityTokenHandler().ReadJwtToken(idToken);
        if (!ValidIssuers.Contains(token.Issuer))
        {
            throw new InvalidOperationException("Google token issuer is invalid.");
        }

        if (!token.Audiences.Intersect(allowedClientIds, StringComparer.Ordinal).Any())
        {
            throw new InvalidOperationException("Google token audience is invalid.");
        }

        if (token.ValidTo <= utcNow)
        {
            throw new InvalidOperationException("Google token is expired.");
        }
    }
}
