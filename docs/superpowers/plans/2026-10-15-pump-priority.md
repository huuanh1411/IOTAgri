# Pump Scheduling Implementation Plan

**Goal:** Vietnam wall-clock recurrence, UTC execution/history, schedule priority over manual requests.
**Architecture:** Reuse PumpScheduleRules and dispatch service. Evaluate recurrence before manual writes, and retain ownership from persisted scheduled commands even if a schedule is disabled/deleted. Scheduled command IssuedAt is occurrence UTC; duration defines exclusive end. MQTT carries source and UTC validity boundaries.
**Tech Stack:** .NET 10/EF PostgreSQL/xUnit; Flutter.
**Spec:** User-approved requirements in current task.

## Constraints
- Preserve existing light endpoint, MQTT light publishing, migration test changes, and lockfile changes.
- No commits. No schema migration or reinterpretation of existing schedules.
- Firmware sketch has no pump controller. Do not invent GPIO wiring or claim hardware enforcement.

## Steps
- [ ] Add backend regressions: Vietnam midnight rollover; manual ON/OFF conflict before dispatch, pending ACK and acknowledged; future schedules allow manual and remain unchanged; expiry does not retry indefinitely; MQTT source and UTC boundaries.
- [ ] Implement schedule ownership guard in DeviceEndpoints and reuse timezone occurrence conversion. Preserve persisted run ownership independently of mutable schedule configuration.
- [ ] Bound scheduler retries to occurrence duration, keep occurrence UTC in scheduled command, expose source/start/end in MQTT without removing legacy fields.
- [ ] Add Flutter wall-clock serialization tests; send HH:mm:ss from Material/Cupertino screens and label device timezone. No phone-timezone recurrence conversion.
- [ ] Run backend tests, Flutter tests/analyze, hot reload discovery; refresh graph; inspect diffs. Document firmware blockers and compatibility risks.

## Progress / verification results
- Backend admission, UTC MQTT contract, bounded retry implementation and focused regressions written.
- Backend suite: 109 passed, 0 failed. Initial six priority regressions failed with 503 instead of 409 before implementation.
- Flutter suite: 128 passed. Two new wall-clock regressions failed before implementation and passed afterward. Final analyze: no issues.
- Graph refreshed; diff whitespace check passed; existing light changes and lockfile preserved.
- DTD discovered/connected, but no running app registered. Hot reload attempted and unavailable.
- Firmware remains blocked: no pump controller exists in supplied sketch. No hardware priority/safety claim. See docs/pump-scheduling-priority.md for rollout requirements.

## Verification
Use existing xUnit/VSTest project and disposable PostgreSQL fixture. Test expected failure before production changes. Flutter tests use MockClient to inspect actual HTTP bodies. Firmware behavior is not testable end-to-end because relay/command handling is absent; document required rejection, timer ownership, duplicate suppression, stale-command and safety semantics instead of pretending implementation exists.
