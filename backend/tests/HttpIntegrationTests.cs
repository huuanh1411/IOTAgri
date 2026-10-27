using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Threading.Tasks;
using IOTAgriBackend.Dtos.Auth;
using IOTAgriBackend.Dtos.Devices;
using IOTAgriBackend.Dtos.Tickets;
using IOTAgriBackend.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace IOTAgriBackend.Tests;

[Trait("Category", "Integration")]
public class HttpIntegrationTests : IClassFixture<PostgresTestFixture>
{
    private readonly PostgresTestFixture _fixture;
    public HttpIntegrationTests(PostgresTestFixture fixture) => _fixture = fixture;
    private static async Task<AuthResponse> RegisterLogin(HttpClient client, string email = "qa@example.test")
    {
        using var register = await client.PostAsJsonAsync("/api/auth/register", new RegisterRequest(email, "QaPassword1!", "QA User"));
        Assert.Equal(HttpStatusCode.Accepted, register.StatusCode);
        var code = TestEmailSender.GetCode(email);
        using var verify = await client.PostAsJsonAsync("/api/auth/verify-email", new VerifyEmailRequest(email, code));
        Assert.Equal(HttpStatusCode.NoContent, verify.StatusCode);
        using var login = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest(email, "QaPassword1!"));
        Assert.Equal(HttpStatusCode.OK, login.StatusCode);
        return (await login.Content.ReadFromJsonAsync<AuthResponse>())!;
    }

    [Fact]
    public async Task Jwt_middleware_denies_anonymous_and_user_admin_access_but_allows_real_admin_token()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        using var anonymous = await client.GetAsync("/api/admin/overview");
        Assert.Equal(HttpStatusCode.Unauthorized, anonymous.StatusCode);
        var tokens = await RegisterLogin(client);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        using var denied = await client.GetAsync("/api/admin/overview");
        Assert.Equal(HttpStatusCode.Forbidden, denied.StatusCode);
        using var scope = app.Services.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var user = (await users.FindByEmailAsync("qa@example.test"))!;
        Assert.True((await users.AddToRoleAsync(user, "Admin")).Succeeded);
        using var login = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest(user.Email!, "QaPassword1!"));
        var adminToken = (await login.Content.ReadFromJsonAsync<AuthResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", adminToken.AccessToken);
        using var allowed = await client.GetAsync("/api/admin/overview");
        Assert.Equal(HttpStatusCode.OK, allowed.StatusCode);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "invalid-qa-token");
        using var invalid = await client.GetAsync("/api/devices/");
        Assert.Equal(HttpStatusCode.Unauthorized, invalid.StatusCode);
    }

    [Fact]
    public async Task Cors_preflight_allows_configured_frontend_origin_and_omits_unknown_origin()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        using var request = new HttpRequestMessage(HttpMethod.Options, "/api/auth/login");
        request.Headers.Add("Origin", "http://localhost:8081");
        request.Headers.Add("Access-Control-Request-Method", "POST");
        using var response = await client.SendAsync(request);
        Assert.Equal("http://localhost:8081", Assert.Single(response.Headers.GetValues("Access-Control-Allow-Origin")));
        using var unknown = new HttpRequestMessage(HttpMethod.Options, "/api/auth/login");
        unknown.Headers.Add("Origin", "http://unknown.example.test");
        unknown.Headers.Add("Access-Control-Request-Method", "POST");
        using var refused = await client.SendAsync(unknown);
        Assert.False(refused.Headers.Contains("Access-Control-Allow-Origin"));
    }

    [Fact]
    public async Task Provisioning_rate_limiter_rejects_eleventh_request_in_same_window()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        for (var i = 0; i < 10; i++)
        {
            using var response = await client.PostAsJsonAsync("/api/device-provisioning/claims", new { code = "", hardwareId = "" });
            Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        }
        using var rejected = await client.PostAsJsonAsync("/api/device-provisioning/claims", new { code = "", hardwareId = "" });
        Assert.Equal(HttpStatusCode.ServiceUnavailable, rejected.StatusCode);
    }

    [Fact]
    public async Task Auth_sensitive_endpoints_reject_requests_over_their_fixed_ip_windows()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();

        for (var i = 0; i < 5; i++)
        {
            using var response = await client.PostAsJsonAsync("/api/auth/register", new RegisterRequest($"rate-register-{i}@example.test", "QaPassword1!", "QA User"));
            Assert.NotEqual(HttpStatusCode.ServiceUnavailable, response.StatusCode);
        }
        using var registerRejected = await client.PostAsJsonAsync("/api/auth/register", new RegisterRequest("rate-register-over@example.test", "QaPassword1!", "QA User"));
        Assert.Equal(HttpStatusCode.ServiceUnavailable, registerRejected.StatusCode);

        for (var i = 0; i < 10; i++)
        {
            using var response = await client.PostAsJsonAsync("/api/auth/verify-email", new VerifyEmailRequest("nobody@example.test", "000000"));
            Assert.NotEqual(HttpStatusCode.ServiceUnavailable, response.StatusCode);
        }
        using var verificationRejected = await client.PostAsJsonAsync("/api/auth/verify-email", new VerifyEmailRequest("nobody@example.test", "000000"));
        Assert.Equal(HttpStatusCode.ServiceUnavailable, verificationRejected.StatusCode);

        for (var i = 0; i < 3; i++)
        {
            using var response = await client.PostAsJsonAsync("/api/auth/resend-verification-code", new ResendVerificationCodeRequest("nobody@example.test"));
            Assert.NotEqual(HttpStatusCode.ServiceUnavailable, response.StatusCode);
        }
        using var resendRejected = await client.PostAsJsonAsync("/api/auth/resend-verification-code", new ResendVerificationCodeRequest("nobody@example.test"));
        Assert.Equal(HttpStatusCode.ServiceUnavailable, resendRejected.StatusCode);

        for (var i = 0; i < 10; i++)
        {
            using var response = await client.PostAsJsonAsync("/api/auth/google", new GoogleSignInRequest("invalid-token"));
            Assert.NotEqual(HttpStatusCode.ServiceUnavailable, response.StatusCode);
        }
        using var googleRejected = await client.PostAsJsonAsync("/api/auth/google", new GoogleSignInRequest("invalid-token"));
        Assert.Equal(HttpStatusCode.ServiceUnavailable, googleRejected.StatusCode);
    }

    [Fact]
    public async Task Locked_user_login_over_http_must_be_denied()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        await RegisterLogin(client);
        using var scope = app.Services.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var user = (await users.FindByEmailAsync("qa@example.test"))!;
        user.LockoutEnabled = true;
        user.LockoutEnd = DateTimeOffset.MaxValue;
        Assert.True((await users.UpdateAsync(user)).Succeeded);
        Assert.True(await users.IsLockedOutAsync(user));
        using var response = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest(user.Email!, "QaPassword1!"));
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Ticket_reply_over_http_with_fresh_request_scope_must_persist_new_message()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        var tokens = await RegisterLogin(client);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        using var create = await client.PostAsJsonAsync("/api/tickets", new CreateSupportTicketRequest("QA Ticket", "Initial message"));
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);
        var ticket = (await create.Content.ReadFromJsonAsync<SupportTicketDetailResponse>())!;
        using var scope = app.Services.CreateScope();
        var users = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var user = (await users.FindByEmailAsync("qa@example.test"))!;
        Assert.True((await users.AddToRoleAsync(user, "Admin")).Succeeded);
        using var login = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest(user.Email!, "QaPassword1!"));
        var admin = (await login.Content.ReadFromJsonAsync<AuthResponse>())!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", admin.AccessToken);
        using var reply = await client.PostAsJsonAsync($"/api/admin/tickets/{ticket.Ticket.Id}/messages", new AddSupportTicketMessageRequest("QA Reply"));
        Assert.Equal(HttpStatusCode.OK, reply.StatusCode);
        var detail = (await reply.Content.ReadFromJsonAsync<SupportTicketDetailResponse>())!;
        Assert.Equal(2, detail.Messages.Count);
        Assert.Contains(detail.Messages, m => m.Message == "QA Reply");
    }

    [Fact]
    public async Task Ticket_owner_can_list_read_and_reply_but_another_user_cannot_read_it()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        var owner = await RegisterLogin(client, "owner@example.test");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", owner.AccessToken);
        using var create = await client.PostAsJsonAsync("/api/tickets", new CreateSupportTicketRequest("QA Ticket", "Initial message", "Cảm biến"));
        Assert.Equal(HttpStatusCode.Created, create.StatusCode);
        var ticket = (await create.Content.ReadFromJsonAsync<SupportTicketDetailResponse>())!;
        Assert.Equal("Cảm biến", ticket.Ticket.Category);

        using var list = await client.GetAsync("/api/tickets?status=open");
        Assert.Equal(HttpStatusCode.OK, list.StatusCode);
        var page = (await list.Content.ReadFromJsonAsync<SupportTicketPage>())!;
        Assert.Contains(page.Items, item => item.Id == ticket.Ticket.Id);

        using var reply = await client.PostAsJsonAsync($"/api/tickets/{ticket.Ticket.Id}/messages", new AddSupportTicketMessageRequest("Owner reply"));
        Assert.Equal(HttpStatusCode.OK, reply.StatusCode);
        var detail = (await reply.Content.ReadFromJsonAsync<SupportTicketDetailResponse>())!;
        Assert.Contains(detail.Messages, message => message.Message == "Owner reply");

        var other = await RegisterLogin(client, "other@example.test");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", other.AccessToken);
        using var forbiddenByOwnership = await client.GetAsync($"/api/tickets/{ticket.Ticket.Id}");
        Assert.Equal(HttpStatusCode.NotFound, forbiddenByOwnership.StatusCode);
    }

    [Fact]
    public async Task Password_change_rejects_wrong_current_password_and_accepts_new_password()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        var tokens = await RegisterLogin(client);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);

        using var rejected = await client.PostAsJsonAsync("/api/auth/change-password", new ChangePasswordRequest("wrong-password", "NewQaPassword1!"));
        Assert.Equal(HttpStatusCode.BadRequest, rejected.StatusCode);
        using var changed = await client.PostAsJsonAsync("/api/auth/change-password", new ChangePasswordRequest("QaPassword1!", "NewQaPassword1!"));
        Assert.Equal(HttpStatusCode.NoContent, changed.StatusCode);
        using var login = await client.PostAsJsonAsync("/api/auth/login", new LoginRequest("qa@example.test", "NewQaPassword1!"));
        Assert.Equal(HttpStatusCode.OK, login.StatusCode);
    }

    [Fact]
    public async Task Device_create_over_http_must_reject_blank_required_name()
    {
        await using var db = await _fixture.CreateDatabaseAsync();
        await using var app = await BackendHttpTestHost.CreateAsync(db);
        using var client = app.GetTestClient();
        var tokens = await RegisterLogin(client);
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        using var response = await client.PostAsJsonAsync("/api/devices/", new CreateDeviceRequest(" "));
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
