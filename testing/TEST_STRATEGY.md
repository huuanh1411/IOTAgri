# Backend test strategy

## Objective and boundaries

Verify meaningful backend behavior without changing application code. Continue
and review the existing xUnit suite, including the 14 Antigravity files. Preserve
developer changes; do not weaken expectations, skip failures, migrate a shared
database, run a broker, or boot production Program.cs.

## Framework and isolation

- .NET 10 / xUnit 2.9.3 / Microsoft.NET.Test.Sdk 17.14.1; the existing framework
  and test naming pattern are retained.
- Moq 4.20.72 is a test-only dependency for UserManager, RoleManager, token issuer,
  scoped services and the refresh-token DbSet. The units under test are real.
- Coverlet collector 6.0.4 is private to the test project. Include only the backend
  assembly; exclude migration source, generated `obj` source and test code.
  Program.cs and untouched/unexecuted application logic stay in the denominator.
- Microsoft.AspNetCore.TestHost 10.0.11 is private to tests. HTTP component tests
  use real JWT/Identity/routes with a reconstructed Program.cs pipeline and fresh
  request scopes; production startup and hosted jobs are not executed.
- PostgreSQL integration now uses Docker fixtures that own uniquely labelled,
  loopback-only containers, new qa_GUID databases per test and no host mounts.
  Fixture cleanup verifies its container name/label before removal. Existing
  Compose services, databases and application .env are never used.
- No new application interfaces, annotations, constructors or runtime settings.
- Private Minimal API handlers are invoked using a test-only reflection helper.
  Signature changes fail the tests rather than being silently ignored.
- The test ProjectReference supplies `DefaultItemExcludes=**/bin/**;**/obj/**`
  only to the referenced build. This prevents generated nested test artifacts
  from being copied recursively by Web SDK content discovery. The production
  csproj is unchanged.

## Classification

| Layer | Tests performed | Claims explicitly not made |
| --- | --- | --- |
| Business rules | Profile/admin decisions, ticket transitions, threshold boundaries, presence, schedules | Persistence or server request correctness |
| DTO/mapper | Alert mapping, pump and sensor JSON, constructor annotations, paging/ranges, median-series completion | That annotation validation executes in the HTTP pipeline |
| JWT/security | Local signature, claims, expiry, missing key, wrong signing key, refresh token representation | Entire JWT bearer middleware integration |
| Endpoint handlers | Early authorization/validation branches and isolated auth/profile behavior | Full server/integration testing or database ownership guarantees |
| Endpoint metadata | 49 mapped business routes; authorization and claim rate-limit metadata | Enforcement by middleware, rate-limit timing, network behavior |
| Bootstrap | Admin creation, preserving existing accounts, role assignment/errors, missing configuration, role seeding | Database transaction or store behavior |
| EF model | Unique keys, filtered indexes, FK deletion rules and selected SQL constraints | PostgreSQL actually enforcing constraints or translating LINQ |
| Background jobs/MQTT | Disabled scheduler, disconnected publish, null/oversized input early guards | Connected ingestion, retry/concurrency, broker delivery or pump hardware |

Route metadata tests construct an unstarted WebApplication; classify them as
component tests, not pure unit or HTTP integration tests. EF metadata tests use
Npgsql model construction without opening a connection. Other new tests directly
exercise units/handlers with isolated inputs or mocks.

## Design techniques and assertions

Boundary analysis covers name/phone length, pump durations, pagination, water
thresholds, weekday masks, interval pairing, due-window inclusion, week rollover,
overnight windows and adjacent schedules. Equivalence/negative testing covers
unknown roles/statuses, malformed input, missing identity and missing configuration.
Ticket transitions and refresh-token activity use decision tables.

Assertions check returned status, payload shape, mapping, claims/signature,
result sequence and state. Interaction checks are limited to meaningful effects
such as not persisting invalid input or not creating a database scope after an
early guard. Passing a null downstream dependency in guard tests ensures an
accidental access fails immediately rather than reaching a real service.

Mocks contain synthetic IDs, passwords and tokens. No real environment values
are loaded. Scheduling/presence use fixed UTC dates. Token expiry captures before
and after instants with tolerance for JWT whole-second rounding. Refresh activity
uses extreme fixed dates, avoiding clock-boundary races. Cryptographic generation
tests validate format and verification, not uniqueness by random sampling or
timing-side-channel properties.

The pre-existing PumpSchemaTests unique-ID assertion remains unchanged; it has
the negligible theoretical collision risk of Guid.NewGuid. It is not evidence of
a mathematically guaranteed uniqueness property. Existing broad tests may group
several related assertions; all are preserved and individually traceable.

## Execution and reporting

Run the whole suite with the supplied runner. Capture stdout/stderr and exit code;
preserve failing product regressions. Fix only test defects and test configuration.
TRX is authoritative; JUnit is derived from it without substituting outcomes.
The case catalog distinguishes 212 method definitions from 345 executed cases.
Each InlineData row receives a stable ID and native TRX linkage.

Coverage includes passing and failing test execution. Use exact collector counters,
not case counts, to calculate line/branch coverage. Instruction coverage is not
provided. No coverage threshold is claimed or added to CI.

## Outstanding work and safe future expansion

The authorized follow-up implemented disposable PostgreSQL fixtures and 26 new
integration cases: real date_trunc/percentile_cont/ILike behavior, provisioning
ExecuteUpdate/sequential reuse/concurrent contention, serializable schedule CRUD,
selected unique/filtered constraints, refresh rotation/logout, reporting/audits,
MQTT persistence adapters and scheduler claim dedup/pending retry. Migration Up
chain runs; full Down attempt retains a failing product regression. The current
Compose database remains shared development state and is not used.

Connected MQTT ingestion/acknowledgement, scheduled retry/idempotency and HTTP
middleware enforcement need separate labeled integration fixtures. Starting the
current Program.cs automatically migrates/seeds and starts hosted services; it is
not safe to reuse directly against live local dependencies in this unit-test run.
HTTP JWT/CORS/claim rate limiting now have component integration coverage. Actual
broker transport, production startup/HTTPS, successful timer dispatch and complete
error/concurrency/validation matrices still need expansion. Scope groups are now
PARTIALLY COVERED, not wholly unexecuted and not skipped/invented tests.
