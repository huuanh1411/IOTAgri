using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.RateLimiting;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Endpoints;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace IOTAgriBackend.Tests;

internal static class BackendHttpTestHost
{
    internal static async Task<WebApplication> CreateAsync(ApplicationDbContext db)
    {
        // Reconstruct the production authentication/authorization/CORS/rate-limit
        // pipeline with real endpoint mappings. Do not run Program.cs or hosted jobs.
        // This is HTTP component integration, not production startup verification.
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions { EnvironmentName = "Testing", Args = Array.Empty<string>() });
        builder.WebHost.UseTestServer();
        const string key = "qa-http-signing-key-0123456789abcdef-0123456789abcdef";
        builder.Configuration.AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Jwt:Key"] = key, ["Jwt:Issuer"] = "qa-http", ["Jwt:Audience"] = "qa-clients",
            ["DeviceProvisioning:MqttHost"] = "qa-broker",
        });
        builder.Services.AddDbContext<ApplicationDbContext>(o => o.UseNpgsql(db.Database.GetConnectionString()));
        builder.Services.AddIdentity<ApplicationUser, IdentityRole>(o => { o.Password.RequiredLength = 8; o.User.RequireUniqueEmail = true; })
            .AddEntityFrameworkStores<ApplicationDbContext>().AddDefaultTokenProviders();
        builder.Services.AddAuthentication(o => { o.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme; o.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme; })
            .AddJwtBearer(o => o.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true, ValidateIssuerSigningKey = true,
                ValidIssuer = "qa-http", ValidAudience = "qa-clients", IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            });
        builder.Services.AddAuthorization(o => o.AddPolicy("AdminOnly", p => p.RequireRole("Admin")));
        builder.Services.AddCors(o => o.AddPolicy("FlutterClient", p => p.WithOrigins("http://localhost:8081").AllowAnyHeader().AllowAnyMethod()));
        builder.Services.AddRateLimiter(o => o.AddPolicy("deviceClaims", c => RateLimitPartition.GetFixedWindowLimiter(
            c.Connection.RemoteIpAddress?.ToString() ?? "unknown", _ => new FixedWindowRateLimiterOptions { PermitLimit = 10, Window = TimeSpan.FromMinutes(1), QueueLimit = 0, AutoReplenishment = true })));
        builder.Services.AddScoped<ITokenService, TokenService>();
        builder.Services.AddSingleton<MqttIngestionService>();
        var app = builder.Build();
        app.UseCors("FlutterClient");
        app.UseAuthentication();
        app.UseAuthorization();
        app.UseRateLimiter();
        app.MapAuthEndpoints();
        app.MapAdminEndpoints();
        app.MapTicketEndpoints();
        app.MapDeviceEndpoints();
        app.MapDeviceProvisioningEndpoints();
        app.MapSensorEndpoints();
        app.MapDashboardEndpoints();
        await RoleSeeder.SeedAsync(app.Services);
        await app.StartAsync();
        return app;
    }
}
