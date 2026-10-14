# Backend QA handoff

This folder continues the 14 unfinished Antigravity test files. Only test code,
test-specific configuration, and QA artifacts were edited. Application source,
runtime configuration, frontend, firmware, and live services were left untouched.

The latest run is **345 executed: 339 PASS, 6 FAIL, 0 skipped**. The six failures
represent four confirmed categories: locked-account login, migration rollback,
ticket reply and required device name validation. The suite currently returns
exit code **1**; do not filter out these product regressions.

## Read first

- [Scope and source inventory](TEST_SCOPE_AND_INVENTORY.md)
- [Test strategy and limitations](TEST_STRATEGY.md)
- [All executed test cases](TEST_CASES.md)
- [Execution history and exact commands](TEST_EXECUTION_LOG.md)
- [Final report](TEST_REPORT.md)
- [Defects and blockers](DEFECTS_AND_BLOCKERS.md)
- [Measured coverage by module/file](reports/coverage/SUMMARY.md)

## Reproduce

Requirements: .NET SDK 10; NuGet access or restored package cache; Python 3 for
report conversion; Docker Desktop with Linux engine and `postgres:17-alpine`
available (or permission to pull it). The fixture creates separate loopback-only
containers and fresh databases, then removes its owned containers/anonymous volumes.
It never uses the shared Compose database, application .env or real accounts.
Mosquitto transport, Flutter and hardware are not needed.

From the repository root in PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testing/run-backend-tests.ps1 -RunName local
python testing/build-test-reports.py --run local
```

Run the report command even when the test command returns 1: a failing test still
produces valid TRX and coverage. Use a fresh RunName to preserve prior artifacts.
The report converter checks source/result traceability, case-ID uniqueness,
execution counts, and Cobertura/JSON counter agreement. It never runs the app.

NuGet advisory retrieval is disabled **only for the runner's restore command** to
make test execution independent of that feed. This is not a security audit; the
initial NU1900 warning is preserved in the execution history. No runtime or CI
configuration is edited.

## Artifacts

- `reports/coverage/followup-final/backend-tests.trx`: latest native results.
- `reports/summary/followup-final-test.log`: real console output; exit code in `.log.exitcode`.
- `reports/junit/backend-tests.xml`: lossless outcome conversion from final TRX;
  a custom converter is used rather than introducing a second test framework.
- `reports/coverage/coverage.cobertura.xml` and `coverage.json`: stable exports of
  actual latest collector output; originals remain under `reports/coverage/followup-final/`.
- `reports/summary/results.json`: measured totals, source-file counts and timestamps.
- `reports/summary/test-case-registry.json`: stable case IDs, source, assertions,
  native TRX IDs, actual outcomes and errors.
- `reports/summary/backend-source-before.json` and `backend-integrity.json`:
  source/config SHA-256 evidence before/after.

This branch contains only tests and QA artifacts. To execute the suite, combine these files with the application source from main at commit 318fca181741c95e73b56808ebe04a65a3ee0466.
Historical attempts are clearly separated from the final run; their counts must
not be added together to inflate the reported number of tests.
