using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using IOTAgriBackend.Data;
using IOTAgriBackend.Endpoints;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace IOTAgriBackend.Tests;

public class SePayWebhookRouteTests
{
    [Fact]
    public async Task SePay_webhook_route_is_explicitly_anonymous()
    {
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions
        {
            EnvironmentName = "Testing",
            Args = Array.Empty<string>()
        });
        builder.Services.AddDbContext<ApplicationDbContext>(options =>
            options.UseInMemoryDatabase("sepay-anonymous-route-metadata"));
        var app = builder.Build();
        app.MapSubscriptionEndpoints();
        await app.StartAsync();

        var endpoint = app.Services.GetRequiredService<EndpointDataSource>().Endpoints
            .Single(candidate => candidate is RouteEndpoint route
                && route.RoutePattern.RawText == "/api/payments/sepay/webhook");

        Assert.NotNull(endpoint.Metadata.GetMetadata<IAllowAnonymous>());
        await app.DisposeAsync();
    }
}

[Trait("Category", "Integration")]
public class ProxyConfigurationTests : IClassFixture<PostgresTestFixture>
{
    private readonly PostgresTestFixture _fixture;

    public ProxyConfigurationTests(PostgresTestFixture fixture) => _fixture = fixture;

    [Theory]
    [InlineData("https://app.aerogreen.vn")]
    [InlineData("https://aerogreen.vn")]
    public async Task Production_cors_allows_configured_https_frontend(string origin)
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db, "Production");
        using var client = app.GetTestClient();

        using var allowed = CreatePreflight(origin);
        using var allowedResponse = await client.SendAsync(allowed);
        Assert.Equal(HttpStatusCode.NoContent, allowedResponse.StatusCode);
        Assert.Equal(origin, Assert.Single(allowedResponse.Headers.GetValues("Access-Control-Allow-Origin")));

        using var refused = CreatePreflight("http://localhost:8081");
        using var refusedResponse = await client.SendAsync(refused);
        Assert.False(refusedResponse.Headers.Contains("Access-Control-Allow-Origin"));
    }

    private static HttpRequestMessage CreatePreflight(string origin)
    {
        var request = new HttpRequestMessage(HttpMethod.Options, "https://localhost/api/auth/login");
        request.Headers.Add("Origin", origin);
        request.Headers.Add("Access-Control-Request-Method", "POST");
        return request;
    }
}
