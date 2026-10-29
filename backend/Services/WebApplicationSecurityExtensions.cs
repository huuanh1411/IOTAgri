using System.Net;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace IOTAgriBackend.Services;

public static class WebApplicationSecurityExtensions
{
    public const string FlutterCorsPolicy = "FlutterClient";

    public static IServiceCollection AddApplicationWebSecurity(
        this IServiceCollection services,
        IConfiguration configuration,
        IHostEnvironment environment)
    {
        var allowedCorsOrigins = configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? [];
        var allowPrivateLanOrigins = environment.IsDevelopment()
            && configuration.GetValue<bool>("Cors:AllowPrivateLanOrigins");

        services.AddCors(options => options.AddPolicy(FlutterCorsPolicy, policy => policy
            .SetIsOriginAllowed(origin =>
                allowedCorsOrigins.Contains(origin, StringComparer.OrdinalIgnoreCase)
                || (allowPrivateLanOrigins && IsPrivateLanFrontendOrigin(origin)))
            .AllowAnyHeader()
            .AllowAnyMethod()));

        services.AddRateLimiter(options =>
        {
            AddFixedWindowPolicy(options, "deviceClaims", permitLimit: 10, window: TimeSpan.FromMinutes(1));
            AddFixedWindowPolicy(options, "authRegister", permitLimit: 5, window: TimeSpan.FromMinutes(15));
            AddFixedWindowPolicy(options, "authVerifyEmail", permitLimit: 10, window: TimeSpan.FromMinutes(15));
            AddFixedWindowPolicy(options, "authResendVerification", permitLimit: 3, window: TimeSpan.FromMinutes(15));
            AddFixedWindowPolicy(options, "authGoogle", permitLimit: 10, window: TimeSpan.FromMinutes(1));
        });

        services.Configure<ForwardedHeadersOptions>(options =>
        {
            options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
            options.KnownIPNetworks.Clear();
            options.KnownProxies.Clear();
            options.KnownIPNetworks.Add(System.Net.IPNetwork.Parse("172.16.0.0/12"));
        });

        return services;
    }

    private static void AddFixedWindowPolicy(RateLimiterOptions options, string name, int permitLimit, TimeSpan window)
    {
        options.AddPolicy(name, context => RateLimitPartition.GetFixedWindowLimiter(
            context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = permitLimit,
                Window = window,
                QueueLimit = 0,
                AutoReplenishment = true,
            }));
    }

    public static WebApplication UseApplicationWebSecurity(this WebApplication app)
    {
        app.UseForwardedHeaders();
        app.UseHttpsRedirection();
        app.UseCors(FlutterCorsPolicy);
        return app;
    }

    private static bool IsPrivateLanFrontendOrigin(string origin)
    {
        if (!Uri.TryCreate(origin, UriKind.Absolute, out var uri)
            || (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps)
            || uri.Port != 8081)
        {
            return false;
        }

        if (uri.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase)) return true;
        if (!IPAddress.TryParse(uri.Host, out var address)) return false;
        if (IPAddress.IsLoopback(address)) return true;
        if (address.AddressFamily != System.Net.Sockets.AddressFamily.InterNetwork) return false;

        var bytes = address.GetAddressBytes();
        return bytes[0] == 10
            || (bytes[0] == 172 && bytes[1] is >= 16 and <= 31)
            || (bytes[0] == 192 && bytes[1] == 168);
    }
}
