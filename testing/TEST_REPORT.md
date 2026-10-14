# Backend QA final report

## Executive summary

The authorized follow-up installed missing tooling and executed 26 additional PostgreSQL/HTTP integration cases. Latest suite: **345 executed, 339 PASS, 6 FAIL**, representing **4 confirmed defect categories**. Broad backend acceptance remains **PARTIALLY COMPLETED** because defects and explicitly documented residual coverage gaps remain. Execution and records are complete for every implemented case.

## Scope and architecture

ASP.NET Core 10 Minimal APIs / EF Core Npgsql PostgreSQL / Identity / JWT / MQTT / schedules / provisioning / tickets. All 98 production source/config files inventoried; handwritten behavior inspected. Generated migration Designer/snapshot not exhaustively line-reviewed. Fourteen migration Up operations now run on new test databases; Down rollback is attempted and fails at BE-002.

xUnit/Moq/Coverlet retained, Microsoft.AspNetCore.TestHost 10.0.11 added privately to tests. PostgreSQL fixture owns separate loopback-only containers and qa_GUID databases, removed after testing. HTTP component host uses real endpoint mapping and security with fresh scopes, but reconstructs startup wiring and does not run Program.cs. MQTT persistence adapters tested directly without connecting a broker. No production/FE/firmware/shared database modifications.

## Measured results

| Measure | Actual |
| --- | --- |
| Cases designed / implemented / executed | 345 / 345 / 345 |
| Test definitions / source files | 212 / 44 |
| Original isolated cases / added integration cases | 319 / 26 |
| PASS / FAIL | 339 / 6 |
| SKIPPED / BLOCKED written / NOT EXECUTED written | 0 / 0 / 0 |
| Pass rate | 98.26% = 339/345 executed, not a product-quality score |
| Line coverage | 67.55% = 1399/2071 |
| Branch coverage | 60.92% = 463/760 |
| Instruction coverage | NOT AVAILABLE: Coverlet emits no instruction counters |
| Exit code | 1, retained product regressions |

Coverage includes passing and failing tests and all instrumented handwritten backend source including unexecuted Program.cs. Only migration sources, generated obj sources and tests excluded. JSON branches reconcile exactly with Cobertura root; no estimates. Migration execution is verified by integration tests even though migration source is excluded from percentage denominators.

[Module/file coverage](reports/coverage/SUMMARY.md), [Cobertura](reports/coverage/coverage.cobertura.xml), [JSON](reports/coverage/coverage.json), [TRX](reports/coverage/followup-final/backend-tests.trx), [JUnit](reports/junit/backend-tests.xml), [log](reports/summary/followup-final-test.log), [machine totals](reports/summary/results.json), [registry](reports/summary/test-case-registry.json).

## Confirmed failures

- **BE-001, High:** locked user receives fresh token, confirmed by original unit test and HTTP/real Identity test (2 FAIL).
- **BE-002, High:** rollback AddAdminManagement fails with SQLSTATE 42601, escaped identifiers in raw Down SQL (1 FAIL).
- **BE-003, High:** ticket ReplyAsync throws DbUpdateConcurrencyException, confirmed with direct PostgreSQL handler and fresh HTTP request scope (2 FAIL). Exact cause needs developer correction; exception reproduced without concurrent actors.
- **BE-004, Medium:** authenticated device POST accepts whitespace-only required name (201 instead of 400) in the reconstructed HTTP pipeline (1 FAIL). Program.cs has no automatic validation registration; actual production startup not launched.

No source fixes, disabled tests, assertion weakening or fabricated passes. Complete reproduction/IDs/source references are in DEFECTS_AND_BLOCKERS.md and TEST_CASES.md. Other static risks (ignored RoleSeeder failed result, full DTO HTTP validation matrix) remain separately labelled suspected/unverified.

## Covered follow-up and residual limits

Now verified: device CRUD/ownership, PostgreSQL aggregate/percentile median SQL, owner dashboard/latest alert, one-use/concurrent provisioning claims, unique/filtered constraints, persisted refresh rotation/reuse/logout, schedule CRUD/overlap/claim dedup/pending disconnected publish, alert/ack persistence adapters, ticket status/priority/search/audit, admin report/CSV/defaults, JWT authorization/CORS/rate limiting and migration Up/Down regression.

Still incomplete: production Program.cs/HTTPS startup/deployment, connected broker transport/reconnect and successful timer dispatch, exhaustive database error/filter/constraint matrix, concurrent admin/schedule mutations, locked refresh/access-session policy, complete middleware/validation exception matrix and generated migration source review. GAP-01 through GAP-06 are now **partially covered**, not wholly unexecuted; they are scope groups, not skipped or invented test cases. Assertions after an earlier failure in a compound scenario are not claimed as passed.

## Integrity and records

All **98 production source/config files** hash-identical to initial baseline; production Git diff empty; no new production file. All 33 initial test/project files including 14 Antigravity files retained. Test-only modifications plus .graphifyignore and QA artifacts. [Integrity](reports/summary/backend-integrity.json) and before/after manifests provide evidence. No Git reset/clean/stage/commit.

Case registry has one unique ID per actual TRX invocation, 212 source definitions map to 345 cases; converter verifies counts/outcomes/coverage agreement. Final JUnit retains all failures. Scope, strategy, case catalog, execution history, report and defects are present with real logs. All 15 requested workflow deliverables performed; this does not mean 100% behavior coverage or green product acceptance.

Graphify blocker resolved after explicit user authorization: graphifyy installed locally, AST update successful. Frontend/platform parser/no-symbol and sequential worker warnings are disclosed in execution log; no backend source edits or API cost.

## Reproduce and acceptance

Requirements: .NET SDK 10, Docker Desktop with Linux engine, PostgreSQL 17 image or permission to pull it, package cache/NuGet, Python 3. No live Compose DB, user accounts or physical hardware needed.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testing/run-backend-tests.ps1 -RunName local
python testing/build-test-reports.py --run local
```

Current expected exit code: 1. Developer should correct BE-001 through BE-004 and rerun, then extend residual matrices/transport/startup tests. **PARTIALLY COMPLETED** for all-backend acceptance; installed tools, safe test execution and QA reporting requested in this follow-up are completed.
