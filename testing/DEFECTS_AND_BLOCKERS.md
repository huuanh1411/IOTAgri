# Defects, risks and blockers

## BE-001 — Locked account can receive fresh login tokens

- **Classification:** confirmed handler-level security/business defect.
- **Severity:** High.
- **Component:** `backend/Endpoints/AuthEndpoints.cs`, `LoginAsync`; account-lock
  feature in `AdminEndpoints.UpdateLockAsync` sets LockoutEnabled/LockoutEnd.
- **Reproduction:** isolated UserManager returns a user with LockoutEnabled=true,
  LockoutEnd=DateTimeOffset.MaxValue, correct password and User role;
  IsLockedOutAsync would return true. Mock token issuer and DbContext record
  issuance without any real Identity store or database.
- **Expected:** login denied (401), no refresh-token generation.
- **Actual:** handler returns 200 and enters token issuance. It checks password
  but does not check lockout. The first assertion fails at AuthHandlerTests.cs:56.
- **Evidence:** `AuthHandlerTests.Locked_user_with_correct_password_must_not_receive_tokens`,
  its stable case ID in TEST_CASES.md/registry, final TRX and final-test.log.
- **Verification:** reproduced by the isolated handler regression and now by
  HttpIntegrationTests.Locked_user_login_over_http_must_be_denied using actual
  Identity persistence/JWT/routes with fresh request scope. Two retained FAIL
  cases in the latest suite; no product fix, skip, filter or weakening.
- **Developer next step:** enforce account lock at the intended authentication
  boundary and define treatment of refresh/existing access tokens. HTTP component
  reproduction is now verified; production startup/session-revocation is not.

## BE-002 — Migration rollback fails with invalid SQL identifier escapes

- **Classification / severity:** confirmed PostgreSQL migration defect / High.
- **Component:** backend/Migrations/20260921104101_AddAdminManagement.cs,
  Down, raw SQL DO block (line 61 onward).
- **Reproduce:** fresh disposable qa_GUID database, apply all 14 migrations,
  then Database.MigrateAsync("0") with no application data.
- **Expected:** full rollback succeeds; no applied migrations remain.
- **Actual:** Npgsql.PostgresException, SQLSTATE 42601, syntax error near backslash,
  position 43. Raw string contains escaped identifiers `\"Devices\"`/`\"OwnerId\"`.
- **Evidence:** TC-BE-90FC4CE0BC, PostgresIntegrationTests.
  All_migrations_can_roll_back_on_empty_disposable_database; latest TRX/log.
- **Status:** reproduced; test stays FAIL. Migration source is unchanged.
- **Limit:** later Down operations after this failing migration are not verified.

## BE-003 — Ticket reply cannot persist a new message

- **Classification / severity:** confirmed persistence defect / High.
- **Component:** backend/Endpoints/TicketEndpoints.cs, ReplyAsync, SaveChangesAsync
  at line 162.
- **Reproduce:** create a valid user and ticket on disposable PostgreSQL, give
  user Admin role, then POST `/api/admin/tickets/{id}/messages` with a valid message.
- **Expected:** 200 and two persisted messages (initial plus reply).
- **Actual:** DbUpdateConcurrencyException, expected one affected row but zero.
  No competing request or shared database is involved.
- **Evidence:** TC-BE-7D9CE29880 (direct handler) and TC-BE-AC1A30D175 (HTTP with
  actual Identity, fresh request scope). Reproduced in expanded/final suites.
- **Status:** two retained FAIL cases. Exact EF tracking/root-cause diagnosis is
  left to developer; no source fix or fixture pretracking workaround.
- **Limit:** later assertions after reply in the compound case do not execute;
  a separate passing case verifies status/priority/search/audit updates.

## BE-004 — Device creation accepts whitespace-only required name

- **Classification / severity:** confirmed validation gap in HTTP component / Medium.
- **Components:** DeviceEndpoints.CreateAsync, CreateDeviceRequest constructor's
  Required declaration; Program.cs has no AddValidation registration.
- **Reproduce:** actual register/login via test HTTP host, authenticated POST
  `/api/devices/` with `{ "name": " " }` on a fresh database.
- **Expected:** 400 for blank required field.
- **Actual:** 201 Created.
- **Evidence:** TC-BE-68FB64C3A3,
  HttpIntegrationTests.Device_create_over_http_must_reject_blank_required_name.
- **Status:** retained FAIL; neither validation annotations nor source modified.
- **Limit:** pipeline is reconstructed from Program.cs; production startup was
  not launched. This does not assert every DTO has the same validation gap.

## RISK-002 — Failed role creation result is ignored

- **Classification:** suspected error-handling risk, not a confirmed failing case.
- **Component:** `backend/Data/RoleSeeder.cs`, `SeedAsync`.
- **Observation:** the awaited CreateAsync IdentityResult is not checked. A failed
  role creation may let startup proceed with missing roles.
- **Expected policy:** developer should confirm whether startup must abort/retry.
- **Verification:** static inspection only; no product contract or store failure
  integration reproduction is asserted. Not included in FAIL counts.

## RISK-003 — DTO annotation declaration is not HTTP validation evidence

- **Classification:** validation-integration risk requiring verification.
- **Components:** positional record constructors in RegisterRequest, LoginRequest,
  RefreshRequest, ClaimDeviceRequest, CreateDeviceRequest and UpdateDeviceRequest;
  `Program.cs` and the related endpoint handlers.
- **Observation:** annotations are on constructor parameters; TryValidateObject
  does not inspect them as property attributes. Program.cs has no AddValidation
  registration. Some handlers apply explicit guards, while device name validation
  and complete registration validation can depend on other layers.
- **Evidence:** unit tests explicitly validate constructor attributes; they make
  no claim of automatic request pipeline validation.
- **Expected next step:** HTTP integration tests for blank device names, malformed
  emails and short passwords using an isolated database. Do not infer that every
  invalid request is accepted: Identity/manual guards may reject it.
- **Status:** full DTO validation matrix remains incomplete. Blank device name
  is now specifically reproduced as BE-004; other DTO risks are not automatically
  promoted to confirmed defects.

## ENV-001 — Initial build/test configuration failures (resolved for tests)

- Antigravity files lacked System imports in DevicePresenceExtendedTests,
  PumpScheduleRulesExtendedTests, PumpMqttMessageExtendedTests and
  PumpCommandHistoryQueryExtendedTests. CS0246/CS0103 prevented initial execution.
  Added imports only in test files; no production edits.
- Web SDK content discovery copied nested test bin/obj output and caused
  MSB3030. Fixed using test ProjectReference metadata only; original runtime/build
  project file stays unchanged.
- A sandboxed initial compile stalled; interrupted only that task's test session
  and ran the compiler with approved access and UseSharedCompilation=false.
- Logs: baseline.log, baseline-retry.log, reviewed-existing.log, iteration.log.
  These are build/environment attempts, not PASS results.

## TEST-001 — DTO validation helper inspected the wrong attribute target (resolved)

- The first coverage run used TryValidateObject on positional records and produced
  eight test failures. The source places attributes on constructor parameters.
- Corrected the test helper to read those parameters and invoke the declared
  ValidationAttribute instances. All ten DTO annotation cases now run and pass;
  expected outcomes remain unchanged. No runtime validation behavior was altered.
- Evidence: historical `reports/coverage/run/backend-tests.trx` has 9 FAIL
  (8 helper failures + BE-001), compared with the final TRX's 1 FAIL (BE-001).
- The initial constant-time test name was also corrected: functional mismatch
  testing cannot establish timing-side-channel safety. A probabilistic code
  uniqueness assertion was replaced by generation/hash verification before running.

## ENV-002 — NuGet advisory feed unavailable during baseline

NU1900 warned that https://api.nuget.org/v3/index.json could not be read for
vulnerability data. Packages restored from available cache. Runner uses
NuGetAudit=false only on its restore invocation; this does not constitute an
advisory scan. Runtime dependencies, versions and CI are unchanged. Final tests
compile and execute. Baseline logs retain the warning.

## ENV-003 — Graphify update unavailable initially; RESOLVED

`graphify-out/graph.json` and the graphify executable/Python module are absent.
The required `graphify update .` could not run. The installed skill file exists,
but its CLI dependency does not. Installing graphifyy into `.run/graphify-tools`
was rejected by automatic approval review because it executes installation code
for an unrelated/unverified package and lacks specific authorization. No install
was performed and no indirect retry was used. This does not block test execution.
The user subsequently explicitly authorized installing missing tools. graphifyy
0.9.89 was installed locally under .run/graphify-tools; AST-only update succeeded
and produced graphify-out/graph.json, graph.html and GRAPH_REPORT.md. The reusable
wrapper is testing/update-graph.ps1; actual install/update logs are retained.
.graphifyignore excludes tools/SDK/generated artifacts. Warnings for one frontend
Linux header parse error and platform files with no symbols are disclosed. A
sandbox worker denial led to sequential extraction; it did not prevent completion.

## Residual scope groups after follow-up (not individual written test cases)

| ID | Gap | Status / reason |
| --- | --- | --- |
| GAP-01 | Full DB query/error/filter/constraint matrix | PARTIALLY COVERED: real CRUD/ownership/aggregates/hourly median/dashboard/audit/CSV/defaults now tested; matrix not exhaustive |
| GAP-02 | Concurrent admin/schedule mutations | PARTIALLY COVERED: concurrent provisioning claim tested; serializable schedule CRUD tested; admin/schedule race matrix outstanding |
| GAP-03 | Locked-session refresh/access policy | PARTIALLY COVERED: persisted refresh rotation/reuse/logout verified; locked refresh/access-session semantics outstanding |
| GAP-04 | Production startup/HTTPS/full middleware/DTO matrix | PARTIALLY COVERED: HTTP component JWT/CORS/rate-limiter executed; reconstructed host does not verify Program.cs startup or every request/exception branch |
| GAP-05 | Connected broker transport/reconnect and successful timer dispatch | PARTIALLY COVERED: persisted MQTT reading/alert/failed-ack adapters and scheduler claim dedup/pending disconnected retry tested; broker transport/timer success outstanding |
| GAP-06 | Remaining rollback chain and generated migration source review | PARTIALLY COVERED: all 14 Up migrations executed; Down regression fails at BE-002; later Down operations and full generated-source review outstanding |

No written test is BLOCKED or SKIPPED in the latest run. The six residual groups
above must not be counted as executable/skipped test cases. Latest results: 345
executed, 339 PASS, 6 FAIL for four defect categories.
