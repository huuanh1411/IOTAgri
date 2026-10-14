using System;
using System.Linq;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Endpoints;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace IOTAgriBackend.Tests;

public class BackendEndpointMetadataTests
{
    [Fact]
    public async Task All_protected_routes_have_authorization_and_public_claim_has_rate_limit_metadata()
    {
        // Component metadata test, not a middleware integration test. Never start app.
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions { EnvironmentName = "Testing", Args = Array.Empty<string>() });
        builder.Services.AddDbContext<ApplicationDbContext>(o => o.UseNpgsql("Host=127.0.0.1;Port=1;Database=qa_metadata"));
        builder.Services.AddIdentityCore<ApplicationUser>().AddRoles<IdentityRole>().AddEntityFrameworkStores<ApplicationDbContext>();
        builder.Services.AddSingleton<MqttIngestionService>();
        builder.Services.AddScoped<ITokenService, TokenService>();
        await using var app = builder.Build();
        app.MapAuthEndpoints();
        app.MapAdminEndpoints();
        app.MapTicketEndpoints();
        app.MapDeviceEndpoints();
        app.MapDeviceProvisioningEndpoints();
        app.MapSensorEndpoints();
        app.MapDashboardEndpoints();
        var routes = ((IEndpointRouteBuilder)app).DataSources.SelectMany(s => s.Endpoints).OfType<RouteEndpoint>().ToList();
        Assert.Equal(49, routes.Count);
        foreach (var route in routes)
        {
            var path = route.RoutePattern.RawText!;
            var authorization = route.Metadata.GetOrderedMetadata<IAuthorizeData>();
            if (path is "/api/auth/register" or "/api/auth/login" or "/api/auth/refresh" or "/api/device-provisioning/claims")
                Assert.Empty(authorization);
            else if (path.StartsWith("/api/admin", StringComparison.Ordinal))
                Assert.Contains(authorization, a => a.Policy == "AdminOnly");
            else
                Assert.NotEmpty(authorization);
        }
        var claim = Assert.Single(routes, r => r.RoutePattern.RawText == "/api/device-provisioning/claims");
        Assert.Equal("deviceClaims", claim.Metadata.GetMetadata<EnableRateLimitingAttribute>()?.PolicyName);
    }
}
