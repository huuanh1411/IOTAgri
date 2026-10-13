"""Convert real TRX/Cobertura artifacts into traceable Markdown and JUnit.

Standard library only. Run from the repository root after run-backend-tests.ps1.
Never executes application code, edits backend files, or invents execution outcomes.
"""
import argparse
import collections
import hashlib
import json
import pathlib
import re
import shutil
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
NS = {"t": "http://microsoft.com/schemas/VisualStudio/TeamTest/2010"}


def write(path, data):
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(data, encoding="utf-8")


def cell(value):
    return str(value).replace("|", "\\|").replace("\n", "<br>").replace("\r", "")


def method_inventory():
    methods = {}
    for path in sorted((ROOT / "backend/tests").glob("*Tests.cs")):
        source = path.read_text(encoding="utf-8-sig")
        cls = re.search(r"public class (\w+)", source).group(1)
        # Mask strings/comments before counting braces; preserve character offsets.
        mask = re.sub(r'""".*?"""|@"(?:""|[^"])*"|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|//[^\n]*|/\*.*?\*/',
                      lambda match: " " * len(match.group()), source, flags=re.S)
        for match in re.finditer(r"public\s+(?:async\s+)?(?:void|Task)\s+(\w+)\s*\(", source):
            start = source.index("{", match.end())
            depth = 1
            end = start + 1
            while depth:
                depth += (mask[end] == "{") - (mask[end] == "}")
                end += 1
            name = match.group(1)
            body = source[start:end]
            assertions = re.findall(r"(?:Assert\.\w+(?:<[^;\n]+>)?|\w+\.Verify)\(.*?;", body, re.S)
            expected = " ".join(re.sub(r"\s+", " ", a).strip() for a in assertions)
            assert expected, (path.name, name, "No meaningful assertions found")
            setup = body[1:body.find("Assert.")].strip()
            line = source[:match.start()].count("\n") + 1
            methods[f"IOTAgriBackend.Tests.{cls}.{name}"] = {
                "class": cls, "method": name, "file": path.relative_to(ROOT).as_posix(),
                "line": line, "expected": expected,
                "setup": setup, "body": body,
            }
    return methods


def classification(cls):
    if cls == "PostgresIntegrationTests":
        return "PostgreSQL persistence/adapters/migrations", "Database integration test", "Fixture owns a loopback-only disposable PostgreSQL container; each case gets a new qa_GUID database; real EF/Npgsql and migration SQL. MQTT adapter tests do not connect a broker."
    if cls == "HttpIntegrationTests":
        return "HTTP/security/validation", "HTTP component integration test", "ASP.NET TestHost with real routes, Identity/JWT and disposable PostgreSQL; fresh request scopes. Pipeline reconstructed from Program.cs without executing production startup/hosted jobs."
    if cls in {"AdminEndpointMappingTests", "TicketEndpointMappingTests", "BackendEndpointMetadataTests"}:
        return "Endpoint/security", "Route metadata component test", "Construct WebApplication without Start/Run; EF provider configured but never connected."
    if cls == "DatabaseModelContractTests":
        return "Data access", "EF metadata component test", "Npgsql model only; no connection, migration, query, or shared database."
    if cls == "EndpointGuardTests":
        return "Endpoint validation", "Handler unit test", "Direct private handler invocation via test-only reflection; downstream dependencies null to detect accidental access."
    if cls == "AuthHandlerTests":
        return "Authentication/profile", "Handler unit test", "Mock UserManager; lockout regression also mocks DbSet/SaveChanges/ITokenService; no database."
    if cls == "SeederBehaviorTests":
        return "Bootstrap/security", "Unit test", "Mock UserManager/RoleManager with disposable DI provider; no Identity store."
    if cls == "BackgroundServiceGuardTests":
        return "MQTT/scheduler", "Unit test", "Strict scope factory; MQTT client constructed but never started/connected; scheduler disabled."
    if cls == "DtoValidationContractTests":
        return "DTO validation", "Unit test", "Validate declared constructor parameter attributes; does not validate automatic HTTP middleware execution."
    if cls == "TokenServiceTests":
        return "JWT/security", "Unit test", "In-memory QA-only signing configuration; local JWT validation; bounded before/after clock for expiry."
    if cls.startswith("Pump"):
        return "Pump control/scheduling", "Unit/serialization test", "Isolated in-memory fixtures; fixed UTC instants for scheduling and history."
    if cls.startswith("Sensor"):
        return "Sensor contracts/series", "Unit/serialization test", "In-memory JSON or bucket dictionary; no ESP32, SQL aggregation, or broker."
    if cls.startswith("DeviceAlert") or cls.startswith("UpdateSystem"):
        return "Alerts", "Unit test", "In-memory thresholds, DTOs, or alert entities; no persisted alert lifecycle."
    if cls.startswith("SupportTicket"):
        return "Support tickets", "Unit test", "Pure status/priority decision rules; no database."
    return "Profile/provisioning/presence/admin", "Unit test", "Isolated inputs in test source; no production configuration or external dependency."


def production_component(cls):
    if cls == "PostgresIntegrationTests":
        return "ApplicationDbContext migrations/constraints, Device/Sensor/Auth/Ticket/Admin/Dashboard/Provisioning handlers, MQTT adapters and scheduler claim; exact component in test body"
    if cls == "HttpIntegrationTests":
        return "Auth/Device/Ticket/Provisioning/Admin routes with real JWT authorization, CORS, rate-limiter and Identity/EF persistence"
    if cls.startswith("PumpMqttMessage"):
        return "PumpCommandMessage JSON contract; PumpStatusMessage.WasSuccessful / NormalizedReason"
    if cls.startswith("SensorMedianBucket"):
        return "SensorMedianBuckets.Complete"
    mapping = {
        "AdminBootstrapSettingsTests": "AdminBootstrapSettings.IsConfigured",
        "AdminEndpointMappingTests": "AdminEndpoints.MapAdminEndpoints",
        "TicketEndpointMappingTests": "TicketEndpoints.MapTicketEndpoints",
        "BackendEndpointMetadataTests": "All seven Endpoint Map* registration methods",
        "DatabaseModelContractTests": "ApplicationDbContext.OnModelCreating",
        "DtoValidationContractTests": "RegisterRequest / ClaimDeviceRequest constructor ValidationAttribute declarations",
        "EndpointGuardTests": "DeviceEndpoints / SensorEndpoints / DashboardEndpoints / AdminEndpoints / TicketEndpoints / AuthEndpoints / DeviceProvisioningEndpoints; handler named in invocation/body",
        "AuthHandlerTests": "AuthEndpoints.LoginAsync / UpdateProfileAsync",
        "SeederBehaviorTests": "AdminBootstrapper.SeedAsync / RoleSeeder.SeedAsync",
        "BackgroundServiceGuardTests": "MqttIngestionService.PublishPumpCommandAsync / ProcessReadingAsync / ProcessPumpStatusAsync; PumpScheduleDispatchService.ExecuteAsync disabled branch",
        "PumpScheduleBoundaryTests": "PumpScheduleRules.GetDueOccurrencesUtc / TryGetDueOccurrenceUtc / Overlaps",
        "PumpSchemaTests": "PumpCommand initial status and identifier generation",
        "RefreshTokenStateTests": "RefreshToken.IsActive",
        "SensorReadingContractTests": "SensorReadingRequest JSON contract",
    }
    return mapping.get(cls, cls.replace("ExtendedTests", "").replace("Tests", ""))


def coverage_summary(source, json_source):
    coverage = ET.parse(source).getroot()
    rows = collections.defaultdict(lambda: [0, 0, 0, 0])
    for cls in coverage.findall(".//class"):
        filename = cls.get("filename").replace("\\", "/")
        for line in cls.findall("lines/line"):
            rows[filename][0] += int(line.get("hits", "0")) > 0
            rows[filename][1] += 1
    # Cobertura omits line-level conditions for some branches with no sequence
    # point. Coverlet JSON retains them; use its exact counters, never estimate.
    raw = json.loads(json_source.read_text(encoding="utf-8"))
    for assembly in raw.values():
        for absolute_path, classes in assembly.items():
            filename = pathlib.Path(absolute_path).relative_to(ROOT / "backend").as_posix()
            for methods in classes.values():
                for method in methods.values():
                    rows[filename][2] += sum(branch["Hits"] > 0 for branch in method["Branches"])
                    rows[filename][3] += len(method["Branches"])
    totals = [sum(row[i] for row in rows.values()) for i in range(4)]
    reported = [int(coverage.get(key)) for key in ("lines-covered", "lines-valid", "branches-covered", "branches-valid")]
    assert totals == reported, (totals, reported, "Coverage aggregation drift")
    return {"totals": dict(zip(("lines_covered", "lines_valid", "branches_covered", "branches_valid"), totals)),
            "files": dict(sorted(rows.items())), "source_attributes": coverage.attrib}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--run", default="final")
    args = parser.parse_args()
    run = ROOT / "testing/reports/coverage" / args.run
    trx_file = run / "backend-tests.trx"
    trx = ET.parse(trx_file).getroot()
    counters = {key: int(value) for key, value in trx.find(".//t:Counters", NS).attrib.items()}
    definitions = {test.get("id"): test.find("t:TestMethod", NS).attrib for test in trx.findall(".//t:UnitTest", NS)}
    results = trx.findall(".//t:UnitTestResult", NS)
    assert len(results) == counters["total"] == counters["executed"]
    methods = method_inventory()
    grouped = collections.defaultdict(list)
    cases = []
    for result in sorted(results, key=lambda r: r.get("testName")):
        definition = definitions[result.get("testId")]
        fqn = definition["className"].split(",")[0] + "." + definition["name"]
        assert fqn in methods, (fqn, "Cannot resolve result to test source")
        status = {"Passed": "PASS", "Failed": "FAIL", "NotExecuted": "NOT EXECUTED"}.get(result.get("outcome"), result.get("outcome"))
        name = result.get("testName")
        tcid = "TC-BE-" + hashlib.sha256(name.encode()).hexdigest()[:10].upper()
        error = result.find("t:Output/t:ErrorInfo/t:Message", NS)
        actual = error.text if error is not None else "All assertions completed successfully."
        defect = ""
        if status == "FAIL":
            if "Locked_user" in fqn: defect = "BE-001"
            elif "All_migrations_can_roll_back" in fqn: defect = "BE-002"
            elif "Ticket_create_reply" in fqn or "Ticket_reply_over_http" in fqn: defect = "BE-003"
            elif "Device_create_over_http_must_reject_blank" in fqn: defect = "BE-004"
            else: defect = "UNCLASSIFIED"
        case = {"id": tcid, "test_name": name, "fqn": fqn, "status": status, "actual": actual, "defect": defect,
                "trx_test_id": result.get("testId"), "trx_execution_id": result.get("executionId"),
                "duration": result.get("duration"), **methods[fqn]}
        cases.append(case)
        grouped[fqn].append(case)
    assert len({c["id"] for c in cases}) == len(cases)
    assert set(grouped) == set(methods), "A written test method has no execution record"
    assert sum(c["status"] == "PASS" for c in cases) == counters["passed"]
    assert sum(c["status"] == "FAIL" for c in cases) == counters["failed"]

    junit = ET.Element("testsuites", tests=str(counters["total"]), failures=str(counters["failed"]), errors="0")
    suites = {}
    for case in cases:
        cls = case["class"]
        if cls not in suites:
            suites[cls] = ET.SubElement(junit, "testsuite", name=cls)
        test = ET.SubElement(suites[cls], "testcase", classname=cls, name=case["test_name"])
        props = ET.SubElement(test, "properties")
        ET.SubElement(props, "property", name="test_case_id", value=case["id"])
        ET.SubElement(props, "property", name="source", value=f"{case['file']}:{case['line']}")
        if case["status"] == "FAIL":
            ET.SubElement(test, "failure", message=case["actual"]).text = case["actual"]
        elif case["status"] != "PASS":
            ET.SubElement(test, "skipped", message=case["status"])
    for cls, suite in suites.items():
        selected = [c for c in cases if c["class"] == cls]
        suite.set("tests", str(len(selected)))
        suite.set("failures", str(sum(c["status"] == "FAIL" for c in selected)))
        suite.set("errors", "0")
    ET.indent(junit)
    write("testing/reports/junit/backend-tests.xml", ET.tostring(junit, encoding="unicode", xml_declaration=True))

    # Use a stable exported path; retain raw original collector artifacts as evidence.
    coverage_file = next(run.rglob("coverage.cobertura.xml"))
    shutil.copyfile(coverage_file, ROOT / "testing/reports/coverage/coverage.cobertura.xml")
    coverage_json = next(run.rglob("coverage.json"))
    shutil.copyfile(coverage_json, ROOT / "testing/reports/coverage/coverage.json")
    summary = coverage_summary(coverage_file, coverage_json)
    summary["test_counters"] = counters
    summary["test_methods"] = len(methods)
    summary["test_files"] = len({m["file"] for m in methods.values()})
    summary["run"] = args.run
    summary["trx_times"] = trx.find("t:Times", NS).attrib
    write("testing/reports/summary/results.json", json.dumps(summary, indent=2))
    write("testing/reports/summary/test-case-registry.json", json.dumps(cases, indent=2, ensure_ascii=False))

    md = ["# Backend test cases", "", "Generated from test source and actual TRX results. No planned/unwritten tests are represented as implemented.", "",
          f"{len(methods)} test methods / {len(cases)} independently executed cases (each InlineData row is one case).",
          "Stable IDs use the SHA-256 prefix of the full executed test name. Registry includes native TRX IDs.", "",
          "All inputs, arrange/act operations and assertions are retained below from the matching test body; see the source link for complete surrounding fixtures.", "",
          "Actual PASS means assertions completed, not that every backend behavior is correct. Metadata tests do not validate middleware enforcement.", ""]
    for fqn in sorted(grouped):
        info = methods[fqn]
        module, test_type, preconditions = classification(info["class"])
        md += [f"## {info['class']}.{info['method']}", "",
               f"- **Module:** {module}", f"- **Component:** {production_component(info['class'])}", f"- **Test identity:** `{fqn}`",
               f"- **Test type:** {test_type}", f"- **Scenario:** {info['method'].replace('_', ' ')}",
               f"- **Preconditions / isolation:** {preconditions}",
               f"- **Test file:** [{info['file']}:{info['line']}](../{info['file']})",
               "- **Test data / steps:** each row's parameters plus the exact Arrange–Act–Assert body below.", "",
               "```csharp", info["body"], "```", "",
               "| Test Case ID | Test Data / invocation | Expected Result | Actual Result | Status | Defect / Log Reference |",
               "| --- | --- | --- | --- | --- | --- |"]
        for case in grouped[fqn]:
            defect = (case["defect"] + "; ") if case["defect"] else ""
            expected = "Assertions in body above, with parameters in this row."
            if case["defect"] == "BE-001":
                expected = "Locked user denied (401); no refresh token generated."
            md.append("| " + " | ".join(cell(v) for v in (case["id"], case["test_name"], expected, case["actual"], case["status"],
                defect + f"[TRX](reports/coverage/{args.run}/backend-tests.trx) testId={case['trx_test_id']}; [log](reports/summary/{args.run}-test.log)")) + " |")
        md.append("")
    write("testing/TEST_CASES.md", "\n".join(md))

    module_rows = collections.defaultdict(lambda: [0, 0, 0, 0])
    for filename, row in summary["files"].items():
        module = filename.split("/")[0] if "/" in filename else "Root/runtime"
        for i, value in enumerate(row):
            module_rows[module][i] += value
    cov = ["# Measured backend coverage", "", "Source: Coverlet collector Cobertura/JSON. Migrations, generated obj files and the test assembly are excluded; Program.cs and all other instrumented backend files remain in the denominator.", "",
           "Line counters aggregate collector class entries (including compiler-generated lambdas/state machines); branch counters come from JSON so branches without a line sequence point are retained. Totals are verified against Cobertura; no manual estimates.", "",
           "Instruction coverage: NOT AVAILABLE (Coverlet does not emit instruction counters).", "",
           "| Module | Lines hit / valid | Line coverage | Branches hit / valid | Branch coverage |", "| --- | --- | --- | --- | --- |"]
    def percentage(a, b):
        return f"{a / b * 100:.2f}%" if b else "N/A (no branches)"
    for module, (lh, lv, bh, bv) in sorted(module_rows.items()):
        cov.append(f"| {module} | {lh}/{lv} | {percentage(lh, lv)} | {bh}/{bv} | {percentage(bh, bv)} |")
    cov += ["", "## By source file", "", "| File | Lines hit / valid | Line coverage | Branches hit / valid | Branch coverage |", "| --- | --- | --- | --- | --- |"]
    for filename, (lh, lv, bh, bv) in summary["files"].items():
        cov.append(f"| [{filename}](../../../backend/{filename}) | {lh}/{lv} | {percentage(lh, lv)} | {bh}/{bv} | {percentage(bh, bv)} |")
    write("testing/reports/coverage/SUMMARY.md", "\n".join(cov) + "\n")
    print(json.dumps({"tests": counters, "methods": len(methods), "coverage": summary["totals"]}, indent=2))


if __name__ == "__main__":
    main()
