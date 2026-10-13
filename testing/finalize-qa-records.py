"""Finalize QA records from real latest results; assert protected source integrity."""
import collections
import datetime as dt
import hashlib
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[1]
SUMMARY = ROOT / 'testing/reports/summary'
TZ = dt.timezone(dt.timedelta(hours=7))

def load(name):
    return json.loads((SUMMARY / name).read_text(encoding='utf-8-sig'))

def write(name, text):
    (ROOT / 'testing' / name).write_text(text, encoding='utf-8')

def main():
    before = load('backend-source-before.json')
    after = [{'path': item['path'], 'sha256': hashlib.sha256((ROOT / item['path']).read_bytes()).hexdigest().upper()} for item in before]
    current = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'backend').rglob('*') if p.is_file() and not any(part in {'tests','bin','obj'} for part in p.relative_to(ROOT / 'backend').parts)}
    diff = subprocess.run(['git','diff','--','backend',':!backend/tests'], cwd=ROOT, capture_output=True, text=True, check=True).stdout
    originals = load('tests-before.json')
    missing = [x['path'] for x in originals if not (ROOT/'backend/tests'/x['path']).exists()]
    changed_tests = [x['path'] for x in originals if x['path'] not in missing and hashlib.sha256((ROOT/'backend/tests'/x['path']).read_bytes()).hexdigest().upper() != x['sha256']]
    integrity = {'production_files_compared':len(before),'changed_or_removed':[a['path'] for a,b in zip(after,before) if a!=b], 'new_production_files': sorted(current - {x['path'] for x in before}), 'production_git_diff_empty':not diff.strip(), 'original_test_files_retained':len(originals)-len(missing), 'missing_original_test_files':missing, 'original_test_files_intentionally_updated':changed_tests, 'checked_at':dt.datetime.now(TZ).isoformat()}
    (SUMMARY/'backend-source-after.json').write_text(json.dumps(after,indent=2),encoding='utf-8')
    (SUMMARY/'backend-integrity.json').write_text(json.dumps(integrity,indent=2),encoding='utf-8')
    assert before==after and not diff.strip() and not missing and not integrity['new_production_files'], integrity
    result = load('results.json')
    cases = load('test-case-registry.json')
    run = result['run']; counts = result['test_counters']; totals=result['totals']
    failures = [c for c in cases if c['status']=='FAIL']
    assert all(c['defect'] and c['defect']!='UNCLASSIFIED' for c in failures)
    sha=subprocess.run(['git','rev-parse','HEAD'],cwd=ROOT,capture_output=True,text=True,check=True).stdout.strip()
    cov_line=100*totals['lines_covered']/totals['lines_valid']; cov_branch=100*totals['branches_covered']/totals['branches_valid']
    methods=result['test_methods']; files=result['test_files']
    integration=sum(c['class'] in {'PostgresIntegrationTests','HttpIntegrationTests'} for c in cases)
    scope=['# Test scope and backend inventory','',f'Revision `{sha}` plus uncommitted QA changes. All 98 production source/config files retain their initial hashes. The original 14 Antigravity files and all 33 original root test files (32 sources + csproj) are retained.','',
    '## Architecture and tools','',
    'C# / ASP.NET Core 10 Minimal APIs; handlers use ApplicationDbContext directly. PostgreSQL/Npgsql EF Core and ASP.NET Identity provide persistence; JWT, MQTT ingestion and pump scheduling provide authentication/background behavior. No separate Controller/Repository layer exists.','',
    'Existing xUnit 2.9.3, Test SDK 17.14.1 and Visual Studio runner 3.1.4 retained. Test-only additions: Moq 4.20.72, Coverlet collector 6.0.4, Microsoft.AspNetCore.TestHost 10.0.11. No production dependency, runtime configuration or CI edit.','',
    '## Review scope and verification limits','',
    'All backend directories inventoried. Handwritten endpoint, service, data-model, DTO and Program.cs behavior inspected. Migration Up operations now execute on fresh isolated PostgreSQL; rollback is tested and fails at AddAdminManagement (BE-002). Generated Designer/snapshot files remain inventoried rather than exhaustively reviewed line by line.','',
    'Frontend, firmware and physical devices excluded. Production Program.cs is not executed: it migrates/seeds and starts live hosted jobs. HTTP component tests reconstruct its security/CORS/rate-limit setup and use real route mappings, Identity and JWT with fresh request scopes. This does not establish deployment/startup wiring.','',
    'No shared Compose service/database/broker is used. PostgresTestFixture creates loopback-only, uniquely named/labelled disposable PostgreSQL containers, a fresh qa_GUID database per case, and verifies name/label before removing only its owned container and anonymous volumes. No externally supplied connection strings, .env, host mounts or persistent volumes.','',
    'Plain DTO/entity accessors without behavior are not given artificial coverage tests. Explicit annotation tests validate record constructor attributes; actual blank device name HTTP behavior is tested separately (BE-004).','',
    '## Component verification map','',
    '| Area | Executed scope | Remaining limitations |','| --- | --- | --- |',
    '| Auth/profile/JWT | Claims/signatures/expiry, profile rules, login lock regression via mock and real Identity HTTP, persisted refresh rotation/reuse and logout | Locked refresh/session policy, exhaustive failed-token branches and production startup |',
    '| Admin/bootstrap | Roles/profile/filter decisions, seed/error behavior, admin HTTP 401/403/200, persisted overview/CSV/defaults/audit | Concurrent admin-demotion/lock races and full report/filter matrix |',
    '| Devices/provisioning | CRUD ownership, required-name regression, real one-use claim and concurrent claim contention | Broader error/ownership matrix and hardware provisioning |',
    '| Sensors/dashboard | JSON/empty series, real PostgreSQL hourly aggregates/median and owner dashboard/latest alert projections | Daily median/filter/extreme ranges not exhaustive |',
    '| Pumps/schedules | Duration/history/JSON/DST/windows, persisted history/serializable schedule CRUD/overlap; claim dedup and disconnected publish pending retry | Connected broker delivery, successful timer/reconnect/retry transport and schedule/admin concurrent mutation races |',
    '| Alerts/MQTT | Threshold/mapper rules, settings/history and filtered unique constraints; persisted MQTT reading alert trigger/resolve and failed acknowledgement adapter | Actual broker connection/reconnect/transport and complete consumer payload matrix |',
    '| Tickets | Rules, create/status/priority/search/audit and reply regressions via direct handler plus fresh HTTP request scope | Reply path fails; later assertions in that failing compound case are not reported as passed |',
    '| Database/migrations | Real PostgreSQL constraints, fresh 14-migration Up chain and pending-model check; attempted full Down regression | Down chain blocked by BE-002; exhaustive constraint/FK/SQL branch matrix and generated-source review |',
    '| HTTP middleware | JWT authorization/invalid token, CORS allowed/unknown preflight and claim rate limiter | Production Program.cs startup, deployment HTTPS, generic exception handling and full middleware matrix |','',
    '## Complete protected-file inventory','', '| Source/config file | Review classification |','| --- | --- |']
    for item in before:
        p=item['path']; note='Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above.'
        if '/Migrations/' in p: note='Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review.'
        elif not p.endswith('.cs'): note='Read-only runtime/build inventory, unchanged; actual runtime secrets not copied.'
        scope.append(f'| [{p}](../{p}) | {note} |')
    scope+=['','## Original files intentionally updated','']+[f'- `backend/tests/{name}`: test-only correction/dependency configuration; details in defects/strategy.' for name in changed_tests]
    scope+=['','## Executable test inventory','',f'{files} source files / {methods} definitions / {counts["total"]} executed cases: {counts["total"]-integration} original isolated cases plus {integration} integration cases.','', '| Test file | Executed cases |','| --- | --- |']
    for cls,n in sorted(collections.Counter(c['class'] for c in cases).items()): scope.append(f'| [backend/tests/{cls}.cs](../backend/tests/{cls}.cs) | {n} |')
    scope+=['','Test-only helpers: BackendTestDoubles.cs, PostgresTestFixture.cs, BackendHttpTestHost.cs under backend/tests/TestSupport. Runner/record generation/graph wrapper under testing/.']
    write('TEST_SCOPE_AND_INVENTORY.md','\n'.join(scope)+'\n')
    history=[]
    for folder in (ROOT/'testing/reports/coverage').iterdir():
        trx=folder/'backend-tests.trx'
        if trx.exists():
            import xml.etree.ElementTree as ET
            xml=ET.parse(trx); ns={'t':'http://microsoft.com/schemas/VisualStudio/TeamTest/2010'}
            c=xml.find('.//t:Counters',ns).attrib; time=xml.find('.//t:Times',ns).get('start')
            history.append((time,folder.name,c))
    execution=['# Test execution log','',f'Git revision `{sha}` plus uncommitted tests/QA. Windows x64; .NET SDK 10.0.401/runtime 10.0.12. Timezone: Asia/Saigon (+07:00).','',
    'Initial build-only attempts preserved: baseline.log (NU1900, sandbox compile interrupted; no fake completion code), baseline-retry.log (missing System imports), reviewed-existing.log (remaining missing imports), iteration.log (nested content-copy MSB3030). Test-only fixes recorded in DEFECTS_AND_BLOCKERS.md.','',
    '## Actual complete-suite history','', '| Run folder | TRX start time | Executed | PASS | FAIL |','| --- | --- | --- | --- | --- |']
    for time,name,c in sorted(history): execution.append(f'| {name} | {dt.datetime.fromisoformat(time).astimezone(TZ).isoformat()} | {c["executed"]} | {c["passed"]} | {c["failed"]} |')
    execution+=['','Counts are per-run and are not summed. Initial coverage/run has 8 DTO test-helper failures plus BE-001; helper corrected without changing expectations. Follow-up fails are product regressions, not disabled tests.','',
    '## Exact follow-up commands','', '```powershell',
    'python -m pip install --target .run/graphify-tools graphifyy',
    '& ./testing/run-backend-tests.ps1 -RunName postgres-followup',
    '& ./testing/run-backend-tests.ps1 -RunName postgres-expanded',
    '& ./testing/run-backend-tests.ps1 -RunName http-followup',
    '& ./testing/run-backend-tests.ps1 -RunName followup-final',
    'python testing/build-test-reports.py --run followup-final',
    'python testing/finalize-qa-records.py',
    '& ./testing/update-graph.ps1','```','',
    'Runner executes `dotnet restore backend/tests/IOTAgriBackend.Tests.csproj -p:NuGetAudit=false` then:', '', '```powershell',
    f'dotnet test backend/tests/IOTAgriBackend.Tests.csproj --configuration Release --no-restore -p:UseSharedCompilation=false --settings testing/coverage.runsettings --collect "XPlat Code Coverage" --logger "trx;LogFileName=backend-tests.trx" --results-directory testing/reports/coverage/{run}',
    '```','',
    f'Final output: [console](reports/summary/{run}-test.log), native [TRX](reports/coverage/{run}/backend-tests.trx), [JUnit](reports/junit/backend-tests.xml), exit code 1 in reports/summary/{run}-test.log.exitcode. Collector raw artifacts under coverage/{run}/<id>/; stable Cobertura/JSON exports under reports/coverage/.','',
    f'{counts["executed"]} executed; {counts["passed"]} PASS, {counts["failed"]} FAIL; skipped/error/aborted/notExecuted 0. No written test blocked. Fixture removed owned QA containers after execution, including failed cases.','',
    '## Final failing cases','', '| Defect | Case ID | Test |','| --- | --- | --- |']
    execution += [f'| {c["defect"]} | {c["id"]} | `{c["fqn"]}` |' for c in failures]
    execution+=['','## Graphify follow-up','',
    'User explicitly authorized installing missing tools. graphifyy 0.9.89 installed under .run/graphify-tools; real pip output .run/graphify-install.log. testing/update-graph.ps1 sets local PYTHONPATH and invokes python -m graphify update . (AST-only, no model/API cost). Scope excludes SDK/tools/generated artifacts using .graphifyignore. CLI succeeds; graph output stays ignored by Git. Warnings: frontend/linux/runner/my_application.h parse error, some platform files produce no symbols; sequential fallback if sandbox denies worker processes. These warnings are disclosed, not hidden or interpreted as backend failures.']
    write('TEST_EXECUTION_LOG.md','\n'.join(execution)+'\n')
    report=f'''# Backend QA final report

## Executive summary

The authorized follow-up installed missing tooling and executed {integration} additional PostgreSQL/HTTP integration cases. Latest suite: **{counts['total']} executed, {counts['passed']} PASS, {counts['failed']} FAIL**, representing **{len(set(c['defect'] for c in failures))} confirmed defect categories**. Broad backend acceptance remains **PARTIALLY COMPLETED** because defects and explicitly documented residual coverage gaps remain. Execution and records are complete for every implemented case.

## Scope and architecture

ASP.NET Core 10 Minimal APIs / EF Core Npgsql PostgreSQL / Identity / JWT / MQTT / schedules / provisioning / tickets. All 98 production source/config files inventoried; handwritten behavior inspected. Generated migration Designer/snapshot not exhaustively line-reviewed. Fourteen migration Up operations now run on new test databases; Down rollback is attempted and fails at BE-002.

xUnit/Moq/Coverlet retained, Microsoft.AspNetCore.TestHost 10.0.11 added privately to tests. PostgreSQL fixture owns separate loopback-only containers and qa_GUID databases, removed after testing. HTTP component host uses real endpoint mapping and security with fresh scopes, but reconstructs startup wiring and does not run Program.cs. MQTT persistence adapters tested directly without connecting a broker. No production/FE/firmware/shared database modifications.

## Measured results

| Measure | Actual |
| --- | --- |
| Cases designed / implemented / executed | {counts['total']} / {counts['total']} / {counts['executed']} |
| Test definitions / source files | {methods} / {files} |
| Original isolated cases / added integration cases | {counts['total']-integration} / {integration} |
| PASS / FAIL | {counts['passed']} / {counts['failed']} |
| SKIPPED / BLOCKED written / NOT EXECUTED written | 0 / 0 / 0 |
| Pass rate | {counts['passed']/counts['executed']*100:.2f}% = {counts['passed']}/{counts['executed']} executed, not a product-quality score |
| Line coverage | {cov_line:.2f}% = {totals['lines_covered']}/{totals['lines_valid']} |
| Branch coverage | {cov_branch:.2f}% = {totals['branches_covered']}/{totals['branches_valid']} |
| Instruction coverage | NOT AVAILABLE: Coverlet emits no instruction counters |
| Exit code | 1, retained product regressions |

Coverage includes passing and failing tests and all instrumented handwritten backend source including unexecuted Program.cs. Only migration sources, generated obj sources and tests excluded. JSON branches reconcile exactly with Cobertura root; no estimates. Migration execution is verified by integration tests even though migration source is excluded from percentage denominators.

[Module/file coverage](reports/coverage/SUMMARY.md), [Cobertura](reports/coverage/coverage.cobertura.xml), [JSON](reports/coverage/coverage.json), [TRX](reports/coverage/{run}/backend-tests.trx), [JUnit](reports/junit/backend-tests.xml), [log](reports/summary/{run}-test.log), [machine totals](reports/summary/results.json), [registry](reports/summary/test-case-registry.json).

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

Case registry has one unique ID per actual TRX invocation, {methods} source definitions map to {counts['total']} cases; converter verifies counts/outcomes/coverage agreement. Final JUnit retains all failures. Scope, strategy, case catalog, execution history, report and defects are present with real logs. All 15 requested workflow deliverables performed; this does not mean 100% behavior coverage or green product acceptance.

Graphify blocker resolved after explicit user authorization: graphifyy installed locally, AST update successful. Frontend/platform parser/no-symbol and sequential worker warnings are disclosed in execution log; no backend source edits or API cost.

## Reproduce and acceptance

Requirements: .NET SDK 10, Docker Desktop with Linux engine, PostgreSQL 17 image or permission to pull it, package cache/NuGet, Python 3. No live Compose DB, user accounts or physical hardware needed.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testing/run-backend-tests.ps1 -RunName local
python testing/build-test-reports.py --run local
```

Current expected exit code: 1. Developer should correct BE-001 through BE-004 and rerun, then extend residual matrices/transport/startup tests. **PARTIALLY COMPLETED** for all-backend acceptance; installed tools, safe test execution and QA reporting requested in this follow-up are completed.
'''
    write('TEST_REPORT.md',report)
    print(json.dumps(integrity,indent=2))

if __name__ == '__main__':
    main()
