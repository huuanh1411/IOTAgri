using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Services;

namespace IOTAgriBackend.Tests;

internal sealed class TestGoogleTokenValidator : IGoogleTokenValidator
{
    public Task<GoogleIdentity?> ValidateAsync(string idToken, CancellationToken cancellationToken = default) =>
        Task.FromResult<GoogleIdentity?>(null);
}
