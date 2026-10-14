# Test execution log

Git revision `318fca181741c95e73b56808ebe04a65a3ee0466` plus uncommitted tests/QA. Windows x64; .NET SDK 10.0.401/runtime 10.0.12. Timezone: Asia/Saigon (+07:00).

Initial build-only attempts preserved: baseline.log (NU1900, sandbox compile interrupted; no fake completion code), baseline-retry.log (missing System imports), reviewed-existing.log (remaining missing imports), iteration.log (nested content-copy MSB3030). Test-only fixes recorded in DEFECTS_AND_BLOCKERS.md.

## Actual complete-suite history

| Run folder | TRX start time | Executed | PASS | FAIL |
| --- | --- | --- | --- | --- |
| run | 2026-10-14T01:11:48.524495+07:00 | 315 | 306 | 9 |
| verified | 2026-10-14T01:12:51.722396+07:00 | 319 | 318 | 1 |
| acceptance | 2026-10-14T01:17:19.417000+07:00 | 319 | 318 | 1 |
| final | 2026-10-14T01:18:33.839548+07:00 | 319 | 318 | 1 |
| postgres-followup | 2026-10-14T01:36:01.113651+07:00 | 329 | 328 | 1 |
| postgres-expanded | 2026-10-14T01:38:39.896879+07:00 | 337 | 334 | 3 |
| http-followup | 2026-10-14T01:40:45.537804+07:00 | 342 | 337 | 5 |
| followup-final | 2026-10-14T01:42:13.706771+07:00 | 345 | 339 | 6 |

Counts are per-run and are not summed. Initial coverage/run has 8 DTO test-helper failures plus BE-001; helper corrected without changing expectations. Follow-up fails are product regressions, not disabled tests.

## Exact follow-up commands

```powershell
python -m pip install --target .run/graphify-tools graphifyy
& ./testing/run-backend-tests.ps1 -RunName postgres-followup
& ./testing/run-backend-tests.ps1 -RunName postgres-expanded
& ./testing/run-backend-tests.ps1 -RunName http-followup
& ./testing/run-backend-tests.ps1 -RunName followup-final
python testing/build-test-reports.py --run followup-final
python testing/finalize-qa-records.py
& ./testing/update-graph.ps1
```

Runner executes `dotnet restore backend/tests/IOTAgriBackend.Tests.csproj -p:NuGetAudit=false` then:

```powershell
dotnet test backend/tests/IOTAgriBackend.Tests.csproj --configuration Release --no-restore -p:UseSharedCompilation=false --settings testing/coverage.runsettings --collect "XPlat Code Coverage" --logger "trx;LogFileName=backend-tests.trx" --results-directory testing/reports/coverage/followup-final
```

Final output: [console](reports/summary/followup-final-test.log), native [TRX](reports/coverage/followup-final/backend-tests.trx), [JUnit](reports/junit/backend-tests.xml), exit code 1 in reports/summary/followup-final-test.log.exitcode. Collector raw artifacts under coverage/followup-final/<id>/; stable Cobertura/JSON exports under reports/coverage/.

345 executed; 339 PASS, 6 FAIL; skipped/error/aborted/notExecuted 0. No written test blocked. Fixture removed owned QA containers after execution, including failed cases.

## Final failing cases

| Defect | Case ID | Test |
| --- | --- | --- |
| BE-001 | TC-BE-F21073B388 | `IOTAgriBackend.Tests.AuthHandlerTests.Locked_user_with_correct_password_must_not_receive_tokens` |
| BE-004 | TC-BE-68FB64C3A3 | `IOTAgriBackend.Tests.HttpIntegrationTests.Device_create_over_http_must_reject_blank_required_name` |
| BE-001 | TC-BE-3DD8720D40 | `IOTAgriBackend.Tests.HttpIntegrationTests.Locked_user_login_over_http_must_be_denied` |
| BE-003 | TC-BE-AC1A30D175 | `IOTAgriBackend.Tests.HttpIntegrationTests.Ticket_reply_over_http_with_fresh_request_scope_must_persist_new_message` |
| BE-002 | TC-BE-90FC4CE0BC | `IOTAgriBackend.Tests.PostgresIntegrationTests.All_migrations_can_roll_back_on_empty_disposable_database` |
| BE-003 | TC-BE-7D9CE29880 | `IOTAgriBackend.Tests.PostgresIntegrationTests.Ticket_create_reply_transition_and_search_persist_messages_and_audit` |

## Graphify follow-up

User explicitly authorized installing missing tools. graphifyy 0.9.89 installed under .run/graphify-tools; real pip output .run/graphify-install.log. testing/update-graph.ps1 sets local PYTHONPATH and invokes python -m graphify update . (AST-only, no model/API cost). Scope excludes SDK/tools/generated artifacts using .graphifyignore. CLI succeeds; graph output stays ignored by Git. Warnings: frontend/linux/runner/my_application.h parse error, some platform files produce no symbols; sequential fallback if sandbox denies worker processes. These warnings are disclosed, not hidden or interpreted as backend failures.
