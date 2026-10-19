using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Endpoints;
using IOTAgriBackend.Models;
using IOTAgriBackend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace IOTAgriBackend.Tests;

internal static class BackendHttpTestHost
{
    internal static async Task<WebApplication> CreateAsync(ApplicationDbContext db, string environmentName = "Testing")
    {
        // Reconstruct the production authentication/authorization/CORS/rate-limit
        // pipeline with real endpoint mappings. Do not run Program.cs or hosted jobs.
        // This is HTTP component integration, not production startup verification.
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions { EnvironmentName = environmentName, Args = Array.Empty<string>() });
        builder.WebHost.UseTestServer();
        const string key = "qa-http-signing-key-0123456789abcdef-0123456789abcdef";
        var configuration = new Dictionary<string, string?>
        {
            ["Jwt:Key"] = key, ["Jwt:Issuer"] = "qa-http", ["Jwt:Audience"] = "qa-clients",
            ["DeviceProvisioning:MqttHost"] = "qa-broker",
            ["Cors:AllowedOrigins:0"] = "https://app.aerogreen.vn",
            ["Cors:AllowPrivateLanOrigins"] = "true"
        };
        if (!string.Equals(environmentName, "Production", StringComparison.OrdinalIgnoreCase))
        {
            configuration["Cors:AllowedOrigins:1"] = "http://localhost:8081";
        }
        builder.Configuration.AddInMemoryCollection(configuration);
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
        builder.Services.AddApplicationWebSecurity(builder.Configuration, builder.Environment);
        builder.Services.AddScoped<ITokenService, TokenService>();
        builder.Services.AddSingleton<MqttIngestionService>();
        var app = builder.Build();
        app.UseApplicationWebSecurity();
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
        await RoleSeeder.SeedAsync(app.Services, app.Configuration);
        await app.StartAsync();
        return app;
    }
}
