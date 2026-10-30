# Account Deletion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let standard Aerogreen users permanently delete their account and every owned device/data record, while publishing a bilingual Google Play-compliant deletion page.

**Architecture:** A protected backend endpoint derives the user from the JWT and performs ordered, transactional deletion. It leaves only a non-identifying account-deletion audit record, purged after 30 days. Flutter exposes the action behind typed `DELETE` confirmation, clears local credentials only on a committed server deletion, and serves a public EN/VI `/delete-account` route through the existing Flutter web application.

**Tech Stack:** ASP.NET Core 10 Minimal APIs, ASP.NET Core Identity, Entity Framework Core/PostgreSQL, Flutter/Dart, Riverpod, GoRouter, Flutter localization.

**Spec:** [2026-10-30-account-deletion-design.md](../specs/2026-10-30-account-deletion-design.md)

## Global Constraints

- Only authenticated non-admin users can delete their own account.
- Never accept a target user ID from client input; use `ClaimTypes.NameIdentifier` from the authenticated principal.
- Deletion permanently removes account/profile, devices/configuration, sensor history, schedules, alerts, refresh tokens, verification codes, support tickets, and support-ticket messages.
- Hardware is permanently deleted, never transferred or unclaimed.
- Store only a non-identifying deletion audit event and remove it after exactly 30 days.
- The app requires exact uppercase `DELETE` before enabling confirmation.
- All new display copy must be English and Vietnamese.
- Do not disclose emails, tokens, passwords, or device keys in audit records, API errors, tests, logs, or documentation.
- Preserve existing login, logout, admin, device, and web-routing behavior.

---

## File Structure

| File | Responsibility |
|---|---|
| `backend/Models/AccountDeletionAudit.cs` | Minimal non-identifying deletion timestamp record. |
| `backend/Data/ApplicationDbContext.cs` | Expose audit set and configure its schema/index. |
| `backend/Services/AccountDeletionAuditCleanupService.cs` | Daily deletion of audit records 30+ days old. |
| `backend/Endpoints/AuthEndpoints.cs` | Protected own-account deletion endpoint and transaction orchestration. |
| `backend/Program.cs` | Register audit retention cleanup hosted service. |
| `backend/Migrations/<timestamp>_AddAccountDeletionAudits.cs` | Create audit table/index. |
| `backend/Migrations/<timestamp>_AddAccountDeletionAudits.Designer.cs` | EF migration model metadata. |
| `backend/Migrations/ApplicationDbContextModelSnapshot.cs` | Current EF model snapshot. |
| `backend/tests/AuthHandlerTests.cs` | Unit coverage for authorization and account-delete handler outcomes. |
| `backend/tests/PostgresIntegrationTests.cs` | Real PostgreSQL cascade/transaction deletion coverage. |
| `frontend/lib/constants/api_constants.dart` | API path constant. |
| `frontend/lib/services/api_service.dart` | Authenticated delete call plus local credential clearing only after HTTP 204. |
| `frontend/lib/data/repositories/auth_repository.dart` | Account-deletion repository method. |
| `frontend/lib/providers/auth_controller.dart` | UI-facing delete result state and session transition. |
| `frontend/lib/screens/settings_screen.dart` | Destructive settings entry point. |
| `frontend/lib/screens/delete_account_screen.dart` | Typed-confirmation UI and errors. |
| `frontend/lib/screens/delete_account_info_screen.dart` | Public bilingual Play deletion instructions. |
| `frontend/lib/router.dart` | Public `/delete-account` route and unauthenticated guard exemption. |
| `frontend/lib/l10n/app_en.arb` | English deletion copy. |
| `frontend/lib/l10n/app_vi.arb` | Vietnamese deletion copy. |
| `frontend/test/account_deletion_test.dart` | UI confirmation, success, and error tests. |
| `frontend/test/delete_account_info_screen_test.dart` | EN/VI public page and direct route tests. |

### Task 1: Add retained deletion-audit persistence

**Files:**
- Create: `backend/Models/AccountDeletionAudit.cs`
- Modify: `backend/Data/ApplicationDbContext.cs`
- Create: `backend/Migrations/<timestamp>_AddAccountDeletionAudits.cs`
- Create: `backend/Migrations/<timestamp>_AddAccountDeletionAudits.Designer.cs`
- Modify: `backend/Migrations/ApplicationDbContextModelSnapshot.cs`
- Test: `backend/tests/PostgresIntegrationTests.cs`

**Interfaces:**
- Produces: `AccountDeletionAudit { Guid Id; DateTime DeletedAt; }` and `ApplicationDbContext.AccountDeletionAudits`.
- Consumes: existing EF Core PostgreSQL migration workflow and `ApplicationDbContext` model conventions.

- [ ] **Step 1: Write a failing PostgreSQL integration test for minimal audit persistence**

```csharp
[Fact]
public async Task Account_deletion_audit_stores_only_id_and_timestamp()
{
    await using var db = await _fixture.CreateDbAsync();

    db.AccountDeletionAudits.Add(new AccountDeletionAudit());
    await db.SaveChangesAsync();

    var audit = await db.AccountDeletionAudits.SingleAsync();
    Assert.NotEqual(Guid.Empty, audit.Id);
    Assert.InRange(audit.DeletedAt, DateTime.UtcNow.AddMinutes(-1), DateTime.UtcNow);
}
```

- [ ] **Step 2: Run the new test to verify it fails**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~Account_deletion_audit_stores_only_id_and_timestamp`

Expected: compilation failure because `AccountDeletionAudit` and `AccountDeletionAudits` do not exist.

- [ ] **Step 3: Add model and EF mapping**

Create `backend/Models/AccountDeletionAudit.cs`:

```csharp
namespace IOTAgriBackend.Models;

public class AccountDeletionAudit
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime DeletedAt { get; set; } = DateTime.UtcNow;
}
```

Add to `ApplicationDbContext`:

```csharp
public DbSet<AccountDeletionAudit> AccountDeletionAudits => Set<AccountDeletionAudit>();
```

Add model configuration:

```csharp
builder.Entity<AccountDeletionAudit>(entity =>
{
    entity.HasKey(audit => audit.Id);
    entity.HasIndex(audit => audit.DeletedAt);
});
```

- [ ] **Step 4: Generate migration and inspect it**

Run:

```powershell
Set-Location backend
dotnet ef migrations add AddAccountDeletionAudits --project IOTAgriBackend.csproj --startup-project IOTAgriBackend.csproj
```

Confirm migration creates `AccountDeletionAudits` with only `Id` and `DeletedAt`, and an index on `DeletedAt`.

- [ ] **Step 5: Run the test to verify it passes**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~Account_deletion_audit_stores_only_id_and_timestamp`

Expected: PASS.

- [ ] **Step 6: Commit persistence work**

```bash
git add backend/Models/AccountDeletionAudit.cs backend/Data/ApplicationDbContext.cs backend/Migrations backend/tests/PostgresIntegrationTests.cs
git commit -m "feat(auth): add account deletion audit"
```

### Task 2: Add 30-day audit retention cleanup

**Files:**
- Create: `backend/Services/AccountDeletionAuditCleanupService.cs`
- Modify: `backend/Program.cs`
- Test: `backend/tests/AccountDeletionAuditCleanupServiceTests.cs`

**Interfaces:**
- Consumes: `ApplicationDbContext.AccountDeletionAudits` from Task 1.
- Produces: `AccountDeletionAuditCleanupService : BackgroundService`, registered as a hosted service.

- [ ] **Step 1: Write failing cleanup test**

```csharp
[Fact]
public async Task Cleanup_removes_only_audits_at_least_thirty_days_old()
{
    await using var db = CreateDatabase();
    db.AccountDeletionAudits.AddRange(
        new AccountDeletionAudit { DeletedAt = DateTime.UtcNow.AddDays(-30) },
        new AccountDeletionAudit { DeletedAt = DateTime.UtcNow.AddDays(-29).AddHours(-23) });
    await db.SaveChangesAsync();

    await AccountDeletionAuditCleanupService.DeleteExpiredAsync(db, DateTime.UtcNow, CancellationToken.None);

    var remaining = await db.AccountDeletionAudits.SingleAsync();
    Assert.True(remaining.DeletedAt > DateTime.UtcNow.AddDays(-30));
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~Cleanup_removes_only_audits_at_least_thirty_days_old`

Expected: compilation failure because cleanup service does not exist.

- [ ] **Step 3: Implement cleanup service**

Create a service with testable static deletion method:

```csharp
public sealed class AccountDeletionAuditCleanupService(IServiceScopeFactory scopeFactory) : BackgroundService
{
    internal static Task DeleteExpiredAsync(ApplicationDbContext db, DateTime now, CancellationToken cancellationToken) =>
        db.AccountDeletionAudits
            .Where(audit => audit.DeletedAt <= now.AddDays(-30))
            .ExecuteDeleteAsync(cancellationToken);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromDays(1));
        do
        {
            await using var scope = scopeFactory.CreateAsyncScope();
            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            await DeleteExpiredAsync(db, DateTime.UtcNow, stoppingToken);
        } while (await timer.WaitForNextTickAsync(stoppingToken));
    }
}
```

Register it in `Program.cs`:

```csharp
builder.Services.AddHostedService<AccountDeletionAuditCleanupService>();
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~Cleanup_removes_only_audits_at_least_thirty_days_old`

Expected: PASS.

- [ ] **Step 5: Commit retention cleanup**

```bash
git add backend/Services/AccountDeletionAuditCleanupService.cs backend/Program.cs backend/tests/AccountDeletionAuditCleanupServiceTests.cs
git commit -m "feat(auth): expire deletion audits after thirty days"
```

### Task 3: Implement transactional own-account deletion API

**Files:**
- Modify: `backend/Endpoints/AuthEndpoints.cs`
- Test: `backend/tests/AuthHandlerTests.cs`
- Test: `backend/tests/PostgresIntegrationTests.cs`

**Interfaces:**
- Consumes: `AccountDeletionAudit` and `ApplicationDbContext.AccountDeletionAudits` from Task 1.
- Produces: authenticated `DELETE /api/auth/account`, returning `204`, `403`, or `401`.

- [ ] **Step 1: Write failing handler tests for identity and admin protection**

```csharp
[Fact]
public async Task Delete_account_rejects_admin_user()
{
    var user = new ApplicationUser { Id = "admin-1" };
    var users = BackendTestDoubles.Users();
    users.Setup(manager => manager.FindByIdAsync(user.Id)).ReturnsAsync(user);
    users.Setup(manager => manager.GetRolesAsync(user)).ReturnsAsync(new[] { "Admin" });

    var result = await BackendTestDoubles.InvokeHandler(
        typeof(AuthEndpoints), "DeleteAccountAsync", Principal(user.Id), users.Object, CreateDatabase());

    Assert.Equal(403, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
}
```

```csharp
[Fact]
public async Task Delete_account_returns_unauthorized_when_subject_is_missing()
{
    var result = await BackendTestDoubles.InvokeHandler(
        typeof(AuthEndpoints), "DeleteAccountAsync", new ClaimsPrincipal(), BackendTestDoubles.Users().Object, CreateDatabase());

    Assert.Equal(401, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~Delete_account_`

Expected: handler method missing.

- [ ] **Step 3: Add endpoint registration and authorization handler**

Register:

```csharp
group.MapDelete("/account", DeleteAccountAsync).RequireAuthorization();
```

Implement handler shape:

```csharp
private static async Task<IResult> DeleteAccountAsync(
    ClaimsPrincipal principal,
    UserManager<ApplicationUser> userManager,
    ApplicationDbContext db,
    CancellationToken cancellationToken)
```

Read user ID via:

```csharp
var userId = principal.FindFirstValue(ClaimTypes.NameIdentifier);
if (string.IsNullOrWhiteSpace(userId)) return Results.Unauthorized();
```

Load `userManager.FindByIdAsync(userId)`, return `Unauthorized` when absent, reject `Admin` role with `Results.Forbid()`.

- [ ] **Step 4: Write failing PostgreSQL deletion integration test**

Set up a standard user with one owned device, reading, pump/light schedules, alert, refresh token, verification code, ticket, and ticket message. Invoke the endpoint with that user's claims. Assert:

```csharp
Assert.Equal(204, Assert.IsAssignableFrom<IStatusCodeHttpResult>(result).StatusCode);
Assert.False(await db.Users.AnyAsync(item => item.Id == user.Id));
Assert.Empty(await db.Devices.Where(item => item.OwnerId == user.Id).ToListAsync());
Assert.Empty(await db.SensorReadings.ToListAsync());
Assert.Empty(await db.PumpSchedules.ToListAsync());
Assert.Empty(await db.LightSchedules.ToListAsync());
Assert.Empty(await db.DeviceAlerts.ToListAsync());
Assert.Empty(await db.RefreshTokens.Where(item => item.UserId == user.Id).ToListAsync());
Assert.Empty(await db.EmailVerificationCodes.Where(item => item.UserId == user.Id).ToListAsync());
Assert.Empty(await db.SupportTickets.Where(item => item.UserId == user.Id).ToListAsync());
Assert.Single(await db.AccountDeletionAudits.ToListAsync());
```

- [ ] **Step 5: Run integration test to verify it fails**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~Delete_account_removes_owned_data_transactionally`

Expected: at least one account-owned record remains.

- [ ] **Step 6: Implement ordered transaction deletion**

Within a relational transaction, delete dependent records before user deletion:

```csharp
await using var transaction = db.Database.IsRelational()
    ? await db.Database.BeginTransactionAsync(cancellationToken)
    : null;

var ticketIds = await db.SupportTickets
    .Where(ticket => ticket.UserId == userId)
    .Select(ticket => ticket.Id)
    .ToListAsync(cancellationToken);
await db.SupportTicketMessages.Where(message => ticketIds.Contains(message.TicketId) || message.AuthorUserId == userId)
    .ExecuteDeleteAsync(cancellationToken);
await db.SupportTickets.Where(ticket => ticket.UserId == userId).ExecuteDeleteAsync(cancellationToken);

var deviceIds = await db.Devices.Where(device => device.OwnerId == userId)
    .Select(device => device.Id)
    .ToListAsync(cancellationToken);
await db.Devices.Where(device => deviceIds.Contains(device.Id)).ExecuteDeleteAsync(cancellationToken);
await db.RefreshTokens.Where(token => token.UserId == userId).ExecuteDeleteAsync(cancellationToken);
await db.EmailVerificationCodes.Where(code => code.UserId == userId).ExecuteDeleteAsync(cancellationToken);
db.AccountDeletionAudits.Add(new AccountDeletionAudit());
var deleteResult = await userManager.DeleteAsync(user);
if (!deleteResult.Succeeded) return Results.Problem("Unable to delete account.", statusCode: 500);
await db.SaveChangesAsync(cancellationToken);
if (transaction is not null) await transaction.CommitAsync(cancellationToken);
return Results.NoContent();
```

Before deleting `Devices`, explicitly delete device-dependent rows with `ExecuteDeleteAsync` for every device ID so deletion behavior does not depend on database cascade configuration. Delete in child-first order: alerts, readings, pump schedule occurrences, pump schedules, light schedules, pump commands, then devices.

- [ ] **Step 7: Run handler and PostgreSQL deletion tests to verify they pass**

Run:

```powershell
dotnet test backend/tests/IOTAgriBackend.Tests.csproj --filter "FullyQualifiedName~Delete_account_"
```

Expected: all account-deletion tests PASS.

- [ ] **Step 8: Commit endpoint work**

```bash
git add backend/Endpoints/AuthEndpoints.cs backend/tests/AuthHandlerTests.cs backend/tests/PostgresIntegrationTests.cs
git commit -m "feat(auth): delete standard user accounts"
```

### Task 4: Add Flutter account-deletion API and state transition

**Files:**
- Modify: `frontend/lib/constants/api_constants.dart`
- Modify: `frontend/lib/services/api_service.dart`
- Modify: `frontend/lib/data/repositories/auth_repository.dart`
- Modify: `frontend/lib/providers/auth_controller.dart`
- Test: `frontend/test/api_service_auth_storage_test.dart`
- Test: `frontend/test/auth_login_error_test.dart`

**Interfaces:**
- Consumes: `DELETE /api/auth/account` from Task 3.
- Produces: `ApiService.deleteAccount()`, `AuthRepository.deleteAccount()`, and `AuthController.deleteAccount(): Future<AccountDeletionResult>`.

- [ ] **Step 1: Write failing API token-clearing test**

```dart
test('deleteAccount clears credentials only after a 204 response', () async {
  final service = ApiService(client: MockClient((request) async {
    expect(request.method, 'DELETE');
    expect(request.url.path, '/api/auth/account');
    return http.Response('', 204);
  }), storage: storage);

  await service.login('qa@example.test', 'QaPassword1!');
  await service.deleteAccount();

  expect(await storage.read(key: 'access_token'), isNull);
  expect(await storage.read(key: 'refresh_token'), isNull);
});
```

Add complementary `500` test asserting both tokens remain present.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/api_service_auth_storage_test.dart --plain-name "deleteAccount clears credentials only after a 204 response"`

Expected: `deleteAccount` method not found.

- [ ] **Step 3: Implement API and repository methods**

Add constant:

```dart
static const String deleteAccount = '/api/auth/account';
```

Implement `ApiService.deleteAccount()` with `_authenticatedRequest`, delete request, `204` status check, and `_clearTokens()` only after `204`:

```dart
Future<void> deleteAccount() async {
  final response = await _authenticatedRequest(
    (headers) => _client.delete(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteAccount}'),
      headers: headers,
    ),
  );
  if (response.statusCode == 204) {
    await _clearTokens();
    return;
  }
  throw ApiError.fromResponse(response);
}
```

Expose it through `AuthRepository.deleteAccount()`.

- [ ] **Step 4: Write failing controller success/error test**

```dart
test('deleteAccount clears auth state only after repository success', () async {
  final controller = AuthController(_DeletingRepository());
  await Future<void>.delayed(Duration.zero);

  final deleted = await controller.deleteAccount();

  expect(deleted, isTrue);
  expect(controller.state.user, isNull);
});
```

Create a failing repository variant and assert its user remains populated after `false` result.

- [ ] **Step 5: Implement controller operation**

Add:

```dart
Future<bool> deleteAccount() async {
  state = state.copyWith(isLoading: true, error: null, errorType: null);
  try {
    await _repo.deleteAccount();
    state = const AuthState(isInitializing: false);
    return true;
  } catch (error) {
    state = state.copyWith(isLoading: false, error: _displayMessage(error));
    return false;
  }
}
```

Map HTTP `403` to a localized administrative-account refusal in the UI layer.

- [ ] **Step 6: Run API and controller tests to verify they pass**

Run:

```powershell
flutter test test/api_service_auth_storage_test.dart test/auth_login_error_test.dart
```

Expected: all selected tests PASS.

- [ ] **Step 7: Commit Flutter API/state work**

```bash
git add frontend/lib/constants/api_constants.dart frontend/lib/services/api_service.dart frontend/lib/data/repositories/auth_repository.dart frontend/lib/providers/auth_controller.dart frontend/test/api_service_auth_storage_test.dart frontend/test/auth_login_error_test.dart
git commit -m "feat(frontend): delete account session"
```

### Task 5: Add destructive Settings confirmation UI

**Files:**
- Create: `frontend/lib/screens/delete_account_screen.dart`
- Modify: `frontend/lib/screens/settings_screen.dart`
- Modify: `frontend/lib/l10n/app_en.arb`
- Modify: `frontend/lib/l10n/app_vi.arb`
- Regenerate: `frontend/lib/l10n/app_localizations.dart`, `frontend/lib/l10n/app_localizations_en.dart`, `frontend/lib/l10n/app_localizations_vi.dart`
- Test: `frontend/test/account_deletion_test.dart`

**Interfaces:**
- Consumes: `AuthController.deleteAccount(): Future<bool>` from Task 4.
- Produces: `DeleteAccountScreen`, opened from Settings.

- [ ] **Step 1: Write failing confirmation-gating test**

```dart
testWidgets('delete confirmation remains disabled until DELETE is typed', (tester) async {
  await tester.pumpWidget(buildDeleteAccountApp());

  final confirm = find.widgetWithText(FilledButton, 'Delete account');
  expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

  await tester.enterText(find.byType(TextField), 'DELETE');
  await tester.pump();

  expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/account_deletion_test.dart --plain-name "delete confirmation remains disabled until DELETE is typed"`

Expected: `DeleteAccountScreen` missing.

- [ ] **Step 3: Implement deletion screen**

Create a screen that lists irreversible deletion effects, includes a `TextField`, and enables destructive button only when `controller.text == 'DELETE'`. On successful deletion, use `context.go('/auth')`. On error, display inline message and preserve the entered authenticated route.

Add Settings `ListTile` after password change:

```dart
ListTile(
  leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
  title: Text(context.l10n.deleteAccountTitle),
  subtitle: Text(context.l10n.deleteAccountSubtitle),
  onTap: () => Navigator.of(context).push(
    AppMotion.detailRoute<void>(context: context, builder: (_) => const DeleteAccountScreen()),
  ),
)
```

- [ ] **Step 4: Add localized copy and generate localization classes**

Add every new deletion screen string to both ARB files. Run:

```powershell
Set-Location frontend
flutter gen-l10n
```

- [ ] **Step 5: Write failing success and error UI tests**

```dart
testWidgets('successful deletion returns user to authentication', (tester) async {
  await tester.pumpWidget(buildDeleteAccountApp(repository: _SuccessfulDeleteRepository()));
  await tester.enterText(find.byType(TextField), 'DELETE');
  await tester.tap(find.widgetWithText(FilledButton, 'Delete account'));
  await tester.pumpAndSettle();
  expect(find.byType(AuthScreen), findsOneWidget);
});
```

```dart
testWidgets('failed deletion remains on confirmation screen and shows error', (tester) async {
  await tester.pumpWidget(buildDeleteAccountApp(repository: _FailingDeleteRepository()));
  await tester.enterText(find.byType(TextField), 'DELETE');
  await tester.tap(find.widgetWithText(FilledButton, 'Delete account'));
  await tester.pumpAndSettle();
  expect(find.byType(DeleteAccountScreen), findsOneWidget);
  expect(find.textContaining('Unable'), findsOneWidget);
});
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test test/account_deletion_test.dart`

Expected: all delete-account UI tests PASS.

- [ ] **Step 7: Commit deletion UI**

```bash
git add frontend/lib/screens/delete_account_screen.dart frontend/lib/screens/settings_screen.dart frontend/lib/l10n frontend/test/account_deletion_test.dart
git commit -m "feat(frontend): add account deletion confirmation"
```

### Task 6: Publish bilingual public deletion instructions

**Files:**
- Create: `frontend/lib/screens/delete_account_info_screen.dart`
- Modify: `frontend/lib/router.dart`
- Modify: `frontend/lib/l10n/app_en.arb`
- Modify: `frontend/lib/l10n/app_vi.arb`
- Regenerate: `frontend/lib/l10n/app_localizations.dart`, `frontend/lib/l10n/app_localizations_en.dart`, `frontend/lib/l10n/app_localizations_vi.dart`
- Test: `frontend/test/delete_account_info_screen_test.dart`

**Interfaces:**
- Consumes: localized copy from Task 5 and existing unauthenticated public-route pattern for `/privacy-policy`.
- Produces: public route `https://aerogreen.vn/delete-account`.

- [ ] **Step 1: Write failing direct-route and bilingual-content tests**

```dart
testWidgets('delete account route is public without authentication', (tester) async {
  final location = await redirectedLocation(tester, null, from: '/delete-account');
  expect(location, '/delete-account');
  expect(find.byType(DeleteAccountInfoScreen), findsOneWidget);
});
```

```dart
testWidgets('Vietnamese deletion page explains typed DELETE confirmation', (tester) async {
  await tester.pumpWidget(buildLocalizedMaterialApp(home: const DeleteAccountInfoScreen()));
  expect(find.text('Xóa tài khoản'), findsWidgets);
  expect(find.textContaining('DELETE'), findsWidgets);
  expect(find.textContaining('30 ngày'), findsOneWidget);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/delete_account_info_screen_test.dart`

Expected: screen and route do not exist.

- [ ] **Step 3: Add public page and route exemption**

Add:

```dart
GoRoute(
  path: '/delete-account',
  builder: (context, state) => const DeleteAccountInfoScreen(),
),
```

Extend public-route guard:

```dart
state.matchedLocation == '/delete-account'
```

Page must explicitly state sign-in path, typed confirmation, permanently deleted categories, 30-day non-identifying audit retention, and `xteam.aerogreen@gmail.com` contact.

- [ ] **Step 4: Generate translations and run page tests**

Run:

```powershell
Set-Location frontend
flutter gen-l10n
flutter test test/delete_account_info_screen_test.dart test/admin_route_test.dart
```

Expected: all selected tests PASS.

- [ ] **Step 5: Commit public deletion page**

```bash
git add frontend/lib/screens/delete_account_info_screen.dart frontend/lib/router.dart frontend/lib/l10n frontend/test/delete_account_info_screen_test.dart frontend/test/admin_route_test.dart
git commit -m "feat(frontend): publish account deletion instructions"
```

### Task 7: Verify complete deletion feature and release metadata

**Files:**
- Modify: `frontend/pubspec.yaml`
- Modify: `frontend/pubspec.lock`
- Test: all backend and Flutter test suites.

**Interfaces:**
- Consumes: completed Tasks 1-6.
- Produces: verified version `1.0.0+2` source state for the next Play release.

- [ ] **Step 1: Preserve release version source change**

Confirm `frontend/pubspec.yaml` contains:

```yaml
version: 1.0.0+2
```

Run `flutter pub get` and stage updated `pubspec.lock` only if dependency resolution changes it.

- [ ] **Step 2: Run complete backend suite**

Run: `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --configuration Release`

Expected: all tests PASS, including PostgreSQL tests with Docker running.

- [ ] **Step 3: Run complete Flutter quality gate**

Run:

```powershell
Set-Location frontend
flutter analyze
flutter test
flutter build web --release --dart-define=API_BASE_URL=https://api.aerogreen.vn --dart-define=GOOGLE_WEB_CLIENT_ID=$env:GOOGLE_WEB_CLIENT_ID --dart-define=GOOGLE_ANDROID_SERVER_CLIENT_ID=$env:GOOGLE_ANDROID_SERVER_CLIENT_ID
```

Expected: analyzer reports no issues, all tests PASS, web build succeeds.

- [ ] **Step 4: Validate direct public URL through production container**

With Docker running:

```powershell
Set-Location frontend
docker build -t iotagri-frontend-account-deletion .
docker run --rm -d -p 18080:80 --name iotagri-frontend-account-deletion iotagri-frontend-account-deletion
Invoke-WebRequest http://localhost:18080/delete-account -UseBasicParsing
```

Expected: HTTP 200 and response contains `flutter_bootstrap.js`.

Stop container:

```powershell
docker stop iotagri-frontend-account-deletion
```

- [ ] **Step 5: Commit release-ready source**

```bash
git add frontend/pubspec.yaml frontend/pubspec.lock
git commit -m "chore(android): prepare version two release"
```

- [ ] **Step 6: Push commits only after all validation passes**

Run:

```bash
git push origin main
```

Then verify CD deploy finishes before entering `https://aerogreen.vn/delete-account` in Google Play Console.
