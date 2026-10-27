using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;
using IOTAgriBackend.Services;

namespace IOTAgriBackend.Tests;

internal sealed class TestEmailSender : IEmailSender
{
    private static readonly ConcurrentDictionary<string, string> Codes = new();

    public Task SendVerificationCodeAsync(string email, string code, CancellationToken cancellationToken = default)
    {
        Codes[email] = code;
        return Task.CompletedTask;
    }

    public static string GetCode(string email) => Codes[email];
}
