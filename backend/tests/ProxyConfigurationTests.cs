using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.TestHost;
using Xunit;

namespace IOTAgriBackend.Tests;

[Trait("Category", "Integration")]
public class ProxyConfigurationTests : IClassFixture<PostgresTestFixture>
{
    private readonly PostgresTestFixture _fixture;

    public ProxyConfigurationTests(PostgresTestFixture fixture) => _fixture = fixture;

    [Fact]
    public async Task Production_cors_allows_only_configured_https_frontend()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db, "Production");
        using var client = app.GetTestClient();

        using var allowed = CreatePreflight("https://app.aerogreen.vn");
        using var allowedResponse = await client.SendAsync(allowed);
        Assert.Equal(HttpStatusCode.NoContent, allowedResponse.StatusCode);
        Assert.Equal("https://app.aerogreen.vn", Assert.Single(allowedResponse.Headers.GetValues("Access-Control-Allow-Origin")));

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