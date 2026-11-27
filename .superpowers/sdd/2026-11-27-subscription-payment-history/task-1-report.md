# Task 1 Report: Normalize Subscription Expiry and Remove Raw Payload Retention

## Scope
Completed only Task 1 from `docs/superpowers/plans/2026-11-27-subscription-payment-history.md`.

## Files Changed
- `backend/Endpoints/SubscriptionEndpoints.cs`
- `backend/Models/CropSubscription.cs`
- `backend/Migrations/20261127134606_RemoveCropSubscriptionRawPayload.cs`
- `backend/Migrations/20261127134606_RemoveCropSubscriptionRawPayload.Designer.cs`
- `backend/Migrations/ApplicationDbContextModelSnapshot.cs`
- `backend/tests/SubscriptionEndpointTests.cs`

## TDD Evidence
### RED
Command:
```powershell
Set-Location C:\Users\ADMIN\Documents\IOTAgriBackend\.worktrees\subscription-payment-history\backend
dotnet test tests\IOTAgriBackend.Tests.csproj --filter FullyQualifiedName~SubscriptionEndpointTests --no-restore -v minimal
```
Observed expected failure: 3 failed / 1 passed. List returned `Pending` instead of `Expired`; replacement checkout persisted two `Pending` rows; raw payload property still existed. Expired webhook rejection test already passed, proving existing late-payment guard remained effective.

### GREEN
Same focused command after implementation:
```text
Passed: 4, Failed: 0, Skipped: 0
```

## Implementation
- List and checkout create capture one `DateTime.UtcNow` then normalize all overdue `Pending` subscriptions before querying.
- Normalization changes only `Pending` rows whose `PaymentExpiresAt <= utcNow`, then saves only when rows changed.
- Webhook remains unnormalized and rejects late payments without changing status.
- Removed `SePayRawPayload` entity property and webhook assignment; retained transaction ID, paid time, expiry, amount, payment code, and status audit facts.

## Migration
Generated EF Core migration `20261127134606_RemoveCropSubscriptionRawPayload`.
- `Up`: drops `CropSubscriptions.SePayRawPayload`.
- `Down`: restores nullable `text` column.
- `dotnet ef migrations has-pending-model-changes --no-build`: no pending model changes.

## Regression Coverage
Command:
```powershell
dotnet test tests\IOTAgriBackend.Tests.csproj --filter "FullyQualifiedName~HttpIntegrationTests|FullyQualifiedName~PostgresIntegrationTests" --no-restore -v minimal
```
Result: 34 failures before test execution because Docker Desktop Linux engine named pipe was unavailable (`//./pipe/dockerDesktopLinuxEngine`). Focused SQLite suite passes.

## Self-review
- Route contracts unchanged.
- Active records unaffected by lazy expiry helper.
- Open-subscription logic retains unexpired `Pending` and `Active` rules.
- Generated migration and snapshot remove payload column; migration explicitly restores it in `Down`.
- `git diff --check` clean; editor diagnostics report no errors.

## Concerns
- Existing dependency audit warnings remain for MailKit, MimeKit, and System.Security.Cryptography.Pkcs; unchanged by Task 1.
- Docker-dependent integration suite could not run because Docker daemon was unavailable.

## Commit
`a8c4414ae2df6936723ee36085fabebb8221b33f` — `fix(subscriptions): persist expired payment history`


