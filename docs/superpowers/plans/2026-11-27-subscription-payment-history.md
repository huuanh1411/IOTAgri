# Subscription Payment History Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete record-only subscription payments with direct QR rendering, persisted expired history, bounded webhook audit data, and verifiable production operations.

**Architecture:** The backend lazily transitions overdue `Pending` subscriptions to `Expired` in its existing list and create handlers, keeping the SePay webhook as the only transition to `Active`. The existing Flutter subscription screen remains the only UI surface: it renders the direct VietQR SVG, stops polling terminal states, and displays API-backed history. EF migration removes raw webhook storage; deploy documentation describes external SePay setup and manual proof.

**Tech Stack:** ASP.NET Core minimal APIs, EF Core/Npgsql migrations, xUnit, Flutter/Dart, flutter_test, Caddy/Docker Compose, Markdown.

**Spec:** `docs/superpowers/specs/2026-11-27-subscription-payment-history-design.md`

## Global Constraints

- Keep the product record-only: active, expired, and pending subscriptions must not gate device access or any product feature.
- Keep `POST /api/payments/sepay/webhook` anonymous, but require valid HMAC, timestamp, account, amount, and duplicate-transaction checks before setting `Active`.
- Do not add dependencies, a background worker, a new route, a billing-plan model, provider proxying, or a new Flutter route.
- Persist `Expired` lazily only for overdue `Pending` subscriptions; never mutate `Active` by expiry cleanup.
- Do not retain `SePayRawPayload` after processing.
- Use `compact2.svg` through `Image.network`; do not download or process QR image bytes.
- Retain current authenticated ownership rules and response model fields.

---

## File Structure

| File | Responsibility |
|---|---|
| `backend/Endpoints/SubscriptionEndpoints.cs` | Subscription expiry normalization, existing checkout/list behavior, validated webhook activation without raw payload persistence. |
| `backend/Models/CropSubscription.cs` | Persisted subscription state fields; remove raw webhook payload. |
| `backend/Data/ApplicationDbContext.cs` | EF model configuration after raw payload removal. |
| `backend/Migrations/<timestamp>_RemoveCropSubscriptionRawPayload.cs` | Drops the raw webhook payload column from existing production databases. |
| `backend/Migrations/<timestamp>_RemoveCropSubscriptionRawPayload.Designer.cs` | EF migration metadata. |
| `backend/Migrations/ApplicationDbContextModelSnapshot.cs` | Current EF model snapshot. |
| `backend/tests/SubscriptionEndpointTests.cs` | Fast handler tests for expiry, replacement checkout, valid/expired callback behavior, and raw-payload non-retention. |
| `backend/tests/HttpIntegrationTests.cs` | HTTP-level ownership/history and webhook regression proof where needed. |
| `frontend/lib/screens/subscription_screen.dart` | Direct SVG QR rendering, polling lifecycle, history section. |
| `frontend/test/subscription_screen_test.dart` | Widget tests for SVG URL, terminal polling, and history display. |
| `frontend/lib/l10n/app_en.arb` | English source copy for subscription history and statuses. |
| `frontend/lib/l10n/app_vi.arb` | Vietnamese source copy for subscription history and statuses. |
| `frontend/lib/l10n/app_localizations*.dart` | Generated Flutter localization output; regenerate rather than hand-author. |
| `deploy/README.md` | SePay callback configuration and operator acceptance procedure. |
| `backend/tests/ProductionRuntimeTests.cs` | Repository-level proof for production payment configuration and public callback route. |

## Task 1: Normalize subscription expiry and remove raw payload retention

**Files:**
- Modify: `backend/Endpoints/SubscriptionEndpoints.cs:20-135`
- Modify: `backend/Models/CropSubscription.cs:3-18`
- Modify: `backend/Data/ApplicationDbContext.cs:79-91`
- Modify: `backend/tests/SubscriptionEndpointTests.cs:18-75`
- Create: `backend/Migrations/<timestamp>_RemoveCropSubscriptionRawPayload.cs`
- Create: `backend/Migrations/<timestamp>_RemoveCropSubscriptionRawPayload.Designer.cs`
- Modify: `backend/Migrations/ApplicationDbContextModelSnapshot.cs`

**Interfaces:**
- Consumes: `CropSubscription` fields `Status`, `PaymentExpiresAt`, `SePayTransactionId`, `PaidAt`, `ExpiresAt`.
- Produces: `NormalizeExpiredPendingSubscriptionsAsync(ApplicationDbContext db, DateTime utcNow, CancellationToken cancellationToken) : Task` private helper; persisted states `Pending`, `Active`, and `Expired`.
- Preserves: `GET /api/subscriptions/`, `POST /api/subscriptions/devices/{deviceId}`, and `POST /api/payments/sepay/webhook` request and response contracts.

- [ ] **Step 1: Write failing handler tests for expiry and audit retention**

Add these tests to `SubscriptionEndpointTests.cs`. Use the existing in-memory SQLite setup, principal, device, `SubscriptionOptions`, and reflection helper already in that file.

```csharp
[Fact]
public async Task Listing_subscriptions_marks_overdue_pending_payment_expired()
{
    // Arrange one caller-owned CropSubscription with Status = "Pending"
    // and PaymentExpiresAt = DateTime.UtcNow.AddMinutes(-1).
    // Invoke private ListAsync with BackendTestDoubles.InvokeHandler.

    // Assert the IValueHttpResult contains a CropSubscriptionResponse whose
    // Status is "Expired", then reload it from db and assert Status == "Expired".
}

[Fact]
public async Task Expired_pending_payment_allows_a_replacement_checkout()
{
    // Arrange one caller-owned expired Pending CropSubscription.
    // Invoke CreateAsync with the existing device and valid options.

    // Assert 201 Created, a different PaymentCode, and database has one
    // Expired row plus one new Pending row.
}

[Fact]
public async Task Expired_pending_payment_rejects_validly_signed_webhook()
{
    // Arrange one overdue Pending CropSubscription and a syntactically valid,
    // signed SePay body using its payment code and exact amount.
    // Invoke ReceiveSePayWebhookAsync.

    // Assert 409 Conflict and persisted Status == "Pending" before list/create
    // normalization; it must never become Active.
}

[Fact]
public async Task Valid_webhook_does_not_retain_raw_payload()
{
    // Invoke valid webhook as existing test does.
    // Assert Status == "Active", SePayTransactionId is set, and no entity
    // property named SePayRawPayload exists on CropSubscription.
}
```

For the final assertion, compile-time removal is stronger than reflection. Remove any `SePayRawPayload` initializer/assertion from test setup and assert persisted payment facts instead:

```csharp
Assert.Equal(92704, subscription.SePayTransactionId);
Assert.NotNull(subscription.PaidAt);
Assert.NotNull(subscription.ExpiresAt);
```

- [ ] **Step 2: Run the focused tests to verify failure**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\backend
dotnet test tests\IOTAgriBackend.Tests.csproj --filter "FullyQualifiedName~SubscriptionEndpointTests" --no-restore
```

Expected: expiry tests fail because list/create retain `Pending`, replacement checkout returns `409`, and the entity still exposes raw payload.

- [ ] **Step 3: Add minimal lazy expiry normalization**

In `SubscriptionEndpoints.cs`, call a single private helper before the list query and before the create handler checks open subscriptions. Make the helper change only expired `Pending` records and save only if any row changed:

```csharp
private static async Task NormalizeExpiredPendingSubscriptionsAsync(
    ApplicationDbContext db,
    DateTime utcNow,
    CancellationToken cancellationToken)
{
    var overdue = await db.CropSubscriptions
        .Where(item => item.Status == "Pending" && item.PaymentExpiresAt <= utcNow)
        .ToListAsync(cancellationToken);

    foreach (var item in overdue)
    {
        item.Status = "Expired";
    }

    if (overdue.Count > 0)
    {
        await db.SaveChangesAsync(cancellationToken);
    }
}
```

Use `var now = DateTime.UtcNow;` once per handler and pass it to the helper. In `ListAsync`, normalize before querying caller-owned history. In `CreateAsync`, normalize before querying the device’s open subscription. Retain open-subscription logic that admits only non-expired `Pending` and `Active` records.

Do not normalize inside `ReceiveSePayWebhookAsync`. Its existing `PaymentExpiresAt <= DateTime.UtcNow` check rejects a late payment without allowing the webhook to mutate status.

- [ ] **Step 4: Stop storing raw webhook data**

Remove this entity property:

```csharp
public string? SePayRawPayload { get; set; }
```

Remove this webhook assignment:

```csharp
subscription.SePayRawPayload = rawBody;
```

Remove the property from EF model snapshot through a migration—not by manually changing existing migration `20261124150421_AddCropSubscriptions`.

Create migration from `backend`:

```powershell
dotnet ef migrations add RemoveCropSubscriptionRawPayload --project IOTAgriBackend.csproj --startup-project IOTAgriBackend.csproj
```

Inspect generated migration. Its `Up` must call:

```csharp
migrationBuilder.DropColumn(
    name: "SePayRawPayload",
    table: "CropSubscriptions");
```

Its `Down` must restore nullable `text` column:

```csharp
migrationBuilder.AddColumn<string>(
    name: "SePayRawPayload",
    table: "CropSubscriptions",
    type: "text",
    nullable: true);
```

- [ ] **Step 5: Run focused backend tests to verify pass**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\backend
dotnet test tests\IOTAgriBackend.Tests.csproj --filter "FullyQualifiedName~SubscriptionEndpointTests" --no-restore
```

Expected: all `SubscriptionEndpointTests` pass.

- [ ] **Step 6: Run migration/integration regression coverage**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\backend
dotnet test tests\IOTAgriBackend.Tests.csproj --filter "FullyQualifiedName~HttpIntegrationTests|FullyQualifiedName~PostgresIntegrationTests" --no-restore
```

Expected: subscription HTTP/webhook flow and migration application tests pass.

- [ ] **Step 7: Commit backend state changes**

```powershell
git add backend/Endpoints/SubscriptionEndpoints.cs backend/Models/CropSubscription.cs backend/Data/ApplicationDbContext.cs backend/Migrations backend/tests/SubscriptionEndpointTests.cs backend/tests/HttpIntegrationTests.cs
git commit -m "fix(subscriptions): persist expired payment history" -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

## Task 2: Render direct VietQR SVG, stop terminal polling, and show history

**Files:**
- Modify: `frontend/lib/screens/subscription_screen.dart:20-390`
- Modify: `frontend/test/subscription_screen_test.dart:1-220`
- Modify: `frontend/lib/l10n/app_en.arb`
- Modify: `frontend/lib/l10n/app_vi.arb`
- Modify: generated `frontend/lib/l10n/app_localizations.dart`
- Modify: generated `frontend/lib/l10n/app_localizations_en.dart`
- Modify: generated `frontend/lib/l10n/app_localizations_vi.dart`

**Interfaces:**
- Consumes: existing `ApiService.getSubscriptions() : Future<List<CropSubscription>>`; existing `CropSubscription` fields and `isPending`/`isActive` getters.
- Produces: screen-owned `List<CropSubscription> _subscriptions`, `_loadSubscriptions() : Future<void>`, and terminal-polling behavior that cancels `_statusTimer` on `Active` or expiry.
- Preserves: `ApiService` public API and current create/resume behavior.

- [ ] **Step 1: Write failing widget tests**

In `subscription_screen_test.dart`, extend `_FakeApiService` with controllable history and a request counter:

```dart
int subscriptionRequests = 0;
List<CropSubscription> history = const [];

@override
Future<List<CropSubscription>> getSubscriptions() async {
  subscriptionRequests++;
  return history.isEmpty
      ? [_payment(status: active ? 'Active' : 'Pending').subscription]
      : history;
}
```

Replace the PNG expectation with this failing test:

```dart
testWidgets('renders VietQR using direct SVG endpoint', (tester) async {
  final api = _FakeApiService();
  await tester.pumpWidget(_app(api));
  await tester.pumpAndSettle();
  await _selectLettuce(tester);
  await tester.tap(find.text('Tiếp tục thanh toán'));
  await tester.pump();

  final image = tester.widget<Image>(find.byType(Image));
  final provider = image.image as NetworkImage;
  expect(provider.url, contains('compact2.svg'));
  expect(provider.url, isNot(contains('compact2.png')));
});
```

Add an expiry polling test with a pending payment whose `paymentExpiresAt` is in the past. After entering payment details and advancing more than five seconds, assert no additional `getSubscriptions` request happened:

```dart
testWidgets('does not poll an expired payment', (tester) async {
  // Configure fake payment expiry to DateTime.now().toUtc().subtract(const Duration(minutes: 1)).
  // Create payment, record api.subscriptionRequests, then pump 6 seconds.
  // Expect api.subscriptionRequests stays unchanged.
});
```

Add a history rendering test with three records (`Pending`, `Active`, `Expired`) and assert crop names and each localized status are visible after initial load.

- [ ] **Step 2: Run widget tests to verify failure**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\frontend
flutter test test/subscription_screen_test.dart
```

Expected: SVG test fails because URL contains `.png`; expiry and history tests fail because the screen neither cancels terminal polling nor loads/renders history.

- [ ] **Step 3: Add only required localization copy and regenerate**

Add source keys to both ARB files:

```json
"subscriptionHistory": "Subscription history",
"subscriptionStatusPending": "Waiting for payment",
"subscriptionStatusActive": "Active",
"subscriptionStatusExpired": "Expired",
"subscriptionPaidAt": "Paid",
"subscriptionCreatedAt": "Created",
"subscriptionHistoryEmpty": "No subscription requests yet"
```

Use Vietnamese equivalents in `app_vi.arb`. Keep existing `paymentPending`, `paymentSucceeded`, and `paymentExpired` unchanged because payment-detail UI already uses them.

Generate localization code:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\frontend
flutter gen-l10n
```

Do not manually edit generated localization Dart files except if the project generation command demonstrably does not produce them.

- [ ] **Step 4: Implement minimal subscription history state**

Add to `_SubscriptionScreenState`:

```dart
List<CropSubscription> _subscriptions = const [];
```

Add `_loadSubscriptions` which calls `_apiService.getSubscriptions()`, returns silently on a transient exception, checks `mounted`, and assigns newest API-returned records to `_subscriptions`. Invoke it from `initState` alongside `_loadDevices`; invoke it after payment request creation and after a successful status refresh.

Keep history errors separate from checkout errors: existing form must remain usable if historical list fetch fails.

Render a history section below the existing payment/form card. It must:

- use `context.l10n.subscriptionHistory` title;
- show `subscriptionHistoryEmpty` when no entries exist;
- use a `Card`/`ListTile` style already present in the screen;
- show crop name, formatted amount, and a status string selected by explicit status mapping;
- show paid date for `Active`, payment expiry for `Pending`, and created date for `Expired`.

Use a private status-label helper with no default active behavior:

```dart
String _subscriptionStatusLabel(CropSubscription subscription) => switch (subscription.status) {
  'Pending' => context.l10n.subscriptionStatusPending,
  'Active' => context.l10n.subscriptionStatusActive,
  'Expired' => context.l10n.subscriptionStatusExpired,
  _ => subscription.status,
};
```

- [ ] **Step 5: Implement direct QR and terminal timer handling**

Change only QR path suffix:

```dart
'/image/${payment.bankCode}-${payment.accountNumber}-compact2.svg'
```

Update `_startStatusPolling` to avoid starting for an expired or active payment. Introduce one clear terminal predicate based on existing state:

```dart
bool _isTerminal(CropSubscription subscription) =>
    subscription.isActive ||
    (subscription.isPending && !subscription.paymentExpiresAt.isAfter(DateTime.now().toUtc())) ||
    subscription.status == 'Expired';
```

Use it in `_startStatusPolling` and `_refreshStatus`; when terminal, call `_statusTimer?.cancel()` and do not call the API. After a refresh returns a terminal record, cancel timer. Preserve manual refresh button only when non-terminal.

- [ ] **Step 6: Run widget tests to verify pass**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\frontend
flutter test test/subscription_screen_test.dart
```

Expected: direct-SVG, no-expired-polling, history, existing checkout, refresh, layout, and navigation cases pass.

- [ ] **Step 7: Run Flutter analyzer**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\frontend
flutter analyze
```

Expected: exit code 0 with no new diagnostics.

- [ ] **Step 8: Commit Flutter payment completion**

```powershell
git add frontend/lib/screens/subscription_screen.dart frontend/test/subscription_screen_test.dart frontend/lib/l10n/app_en.arb frontend/lib/l10n/app_vi.arb frontend/lib/l10n/app_localizations.dart frontend/lib/l10n/app_localizations_en.dart frontend/lib/l10n/app_localizations_vi.dart
git commit -m "feat(subscriptions): show payment history" -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

## Task 3: Document external SePay configuration and production contract checks

**Files:**
- Modify: `deploy/README.md:27-57`
- Modify: `backend/tests/ProductionRuntimeTests.cs:44-70`
- Modify: `backend/tests/ProxyConfigurationTests.cs`

**Interfaces:**
- Consumes: deployed `api.aerogreen.vn`, `POST /api/payments/sepay/webhook`, `SEPAY_WEBHOOK_SECRET`, `Subscription__*` production Compose variables, and current `WebApplicationSecurityExtensions` CORS policy.
- Produces: operator instructions to configure/test the provider; source tests proving only repository-controlled production policy.
- Preserves: no production secret is committed and no fake external callback is added to CI.

- [ ] **Step 1: Write failing production-source tests**

In `ProductionRuntimeTests.cs`, add a test that reads `.env.production.example`, `compose.production.yaml`, and `.github/workflows/cd.yml` if needed. Assert environment template and Compose retain all fields:

```csharp
Assert.Contains("SUBSCRIPTION_MONTHLY_PRICE_VND=", environment);
Assert.Contains("SUBSCRIPTION_BANK_CODE=", environment);
Assert.Contains("SUBSCRIPTION_ACCOUNT_NUMBER=", environment);
Assert.Contains("SUBSCRIPTION_ACCOUNT_NAME=", environment);
Assert.Contains("SEPAY_WEBHOOK_SECRET=", environment);
Assert.Contains("SePay__WebhookSecret", compose);
Assert.Contains("Subscription__MonthlyPriceVnd", compose);
```

In `ProxyConfigurationTests.cs`, add a test built through its existing host/pipeline helpers that sends an unauthenticated `POST /api/payments/sepay/webhook` with no signature and asserts it reaches the endpoint’s validation boundary as `401`, not authentication middleware `401`/`403. If the existing test host cannot distinguish those sources, assert route endpoint metadata includes `AllowAnonymous` by mapping `MapSubscriptionEndpoints` into the test application and inspecting matched endpoint metadata.

- [ ] **Step 2: Run focused tests to verify failure**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\backend
dotnet test tests\IOTAgriBackend.Tests.csproj --filter "FullyQualifiedName~ProductionRuntimeTests|FullyQualifiedName~ProxyConfigurationTests" --no-restore
```

Expected: newly introduced callback-route/config assertion fails until production contract checks are added or adjusted to real existing configuration.

- [ ] **Step 3: Add only source-level contract proof necessary**

Do not modify runtime behavior if source already meets the assertions. Add/adjust tests so they establish:

- production Compose passes subscription bank/price settings and SePay secret into API;
- example environment declares all settings without values;
- webhook route has explicit `.AllowAnonymous()`; and
- CORS tests continue to allow only configured frontend origins.

If the route currently has `.AllowAnonymous()`, this step is test-only.

- [ ] **Step 4: Add SePay operator runbook**

Add a `## SePay subscription callback` section after Continuous deployment in `deploy/README.md`:

```markdown
## SePay subscription callback

1. On the VPS, set `SEPAY_WEBHOOK_SECRET` in `/opt/iotagri/.env.production` to a high-entropy secret. Deploy after changing it.
2. In SePay, configure callback URL `https://api.aerogreen.vn/api/payments/sepay/webhook` and configure exactly the same callback secret.
3. SePay must send `X-SePay-Timestamp` and `X-SePay-Signature`. The API accepts an HMAC-SHA256 signature for `<unix timestamp>.<raw body>` only within five minutes.
4. Create an authenticated subscription payment request. Transfer its exact quoted amount using its exact transfer content.
5. Confirm SePay reports callback success. Then call authenticated `GET /api/subscriptions/` or refresh the app; matching request must become `Active` and show its transaction timestamp.
6. If callback fails, inspect API container logs without printing `.env.production` or payment secrets:
   `docker compose --env-file .env.production -f compose.production.yaml logs --tail=200 api`.
```

Add a note: this record-only system records payment history; it does not unlock or restrict features.

- [ ] **Step 5: Run production contract tests to verify pass**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\backend
dotnet test tests\IOTAgriBackend.Tests.csproj --filter "FullyQualifiedName~ProductionRuntimeTests|FullyQualifiedName~ProxyConfigurationTests" --no-restore
```

Expected: all focused production configuration/proxy tests pass.

- [ ] **Step 6: Commit production documentation and proof**

```powershell
git add deploy/README.md backend/tests/ProductionRuntimeTests.cs backend/tests/ProxyConfigurationTests.cs
git commit -m "docs(deploy): add SePay callback verification" -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

## Task 4: Full regression and delivery verification

**Files:**
- Modify: only files required to resolve failures directly caused by Tasks 1-3.

**Interfaces:**
- Consumes: completed backend, Flutter, migration, and production documentation changes.
- Produces: clean repository diff and evidence that the implemented record-only flow is compatible with existing tests.

- [ ] **Step 1: Run complete backend suite**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\backend
dotnet test tests\IOTAgriBackend.Tests.csproj --no-restore
```

Expected: exit code 0. If Docker-backed PostgreSQL tests require an unavailable local Docker daemon, record exact failing infrastructure evidence and still run all non-container tests available under the same project.

- [ ] **Step 2: Run complete Flutter test suite**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\frontend
flutter test
```

Expected: exit code 0.

- [ ] **Step 3: Verify format, diagnostics, and migration diff**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend
flutter format --set-exit-if-changed frontend/lib/screens/subscription_screen.dart frontend/test/subscription_screen_test.dart
git diff --check
git status --short
```

If format changes files, inspect the diff, rerun targeted Flutter test, and commit the formatting change with the relevant task commit.

- [ ] **Step 4: Update code graph and inspect final diff**

Run:

```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend
graphify update .
git --no-pager diff HEAD~3..HEAD --check
git --no-pager log --oneline -4
```

Expected: graph updates successfully; no whitespace errors; commits contain only subscription-history work plus graph artifacts only if repository convention tracks them.

- [ ] **Step 5: Commit final coupled fixes only if needed**

```powershell
git add <only-files-fixed-during-regression>
git commit -m "fix(subscriptions): preserve payment history flow" -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```

Do not create this commit when no regression fix was necessary.

## Plan Self-Review

- **Spec coverage:** Task 1 covers explicit expiry and raw-payload removal; Task 2 covers direct SVG, polling lifecycle, and same-screen history; Task 3 covers provider configuration and repository-verifiable production policy; Task 4 covers end-to-end regression evidence. Record-only behavior is a global constraint and no task introduces an entitlement check.
- **Gaps intentionally excluded:** repository code cannot configure SePay dashboard credentials or execute a bank transfer. Task 3 provides exact operator procedure instead.
- **Placeholder scan:** no `TBD`, `TODO`, deferred implementation, or undefined function/type references remain. Migration timestamp is intentionally generated by EF Core command and not hand-selected.
- **Type consistency:** `CropSubscription`, `CropSubscriptionPayment`, `ApiService.getSubscriptions`, and existing endpoint routes retain their current signatures. The new private expiry helper is fully specified in Task 1 and not called from other components.
