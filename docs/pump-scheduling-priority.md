# Pump scheduling: implemented behavior and deployment limits

## Backend and client

- Recurrence is a local weekday/time/date range plus IANA timezone. Flutter sends `HH:mm:ss` and `Asia/Ho_Chi_Minh`, never an offset-bearing instant. Existing .NET `TimeZoneInfo` conversion remains authoritative; no fixed-offset arithmetic.
- Manual ON and OFF return HTTP 409 with `code: SCHEDULE_ACTIVE` in the half-open interval `[occurrenceUtc, occurrenceUtc + durationSeconds)`, including before the scheduler poll and while ACK is pending. Persisted scheduled commands also retain ownership if their schedule is edited, disabled, or deleted. A failed/safety-stopped run still reserves its original interval; manual commands cannot bypass safety by releasing this reservation.
- Future schedules do not block manual commands; manual commands never write schedule data.
- Dispatcher does not wait for a running manual pump. It publishes the scheduled ON command with the scheduled occurrence as `IssuedAt`. Retries retain that same UTC end; expired undispatched commands become Failed/SCHEDULE_EXPIRED and their occurrence is terminal.
- MQTT retains commandId/isOn/durationSeconds and adds `source` (`manual` or `scheduled`), `issuedAtUtc`, and nullable `scheduledEndUtc`. Scheduled history IssuedAt now means occurrence time rather than dispatch wall time. ACK timestamps remain UTC.

## Firmware blocker — not hardware-ready

`firmware/ESP32DeviceSetup/ESP32DeviceSetup.ino` contains provisioning and sensor telemetry only. There is no MQTT command callback/subscription, pump GPIO configuration, relay polarity, pump timer, safety shutoff logic, or clock synchronization. It was deliberately not modified. Backend metadata alone cannot enforce actuator priority.

Before deploying this behavior to a real pump, supply the actual controller firmware and verify:

1. Scheduled ON supersedes manual ownership and cancels the old manual stop timer. Stop at the absolute scheduled UTC end, not receipt time plus duration. Use a synchronized UTC clock and fail closed when time is untrusted.
2. Reject manual ON/OFF during scheduled ownership, regardless of transport order. Retain a command-ID deduplication history and timestamp/watermark so delayed pre-schedule commands cannot restart the pump after the run. Duplicate scheduled commands must not reset the timer.
3. Safety shutdown always wins, physically turns the relay off, and prevents duplicate/delayed scheduled commands from undoing the safety trip. Acknowledge rejection with success=false and a bounded reason.
4. Exact protection from scheduled start, even if the scheduled MQTT packet itself is delayed, requires the controller to know the upcoming schedule/window in advance. This repository currently has no schedule synchronization protocol. The backend polling dispatcher alone cannot guarantee exact on-time execution or offline scheduling.
5. Test manual-running → scheduled-start → old-manual-timeout, delayed manual ON/OFF, duplicated schedule packets, expiry, clock loss/reboot, low-water shutdown, and reconnect delivery on the actual controller.

## Compatibility and rollout

- No EF model/schema migration. Existing recurrence timezones are preserved; no silent conversion of old UTC/Bangkok/etc. rows to Vietnam. Audit legacy rows and explicitly edit those representing the wrong wall clock.
- Stop/drain old pending scheduled commands before rollout: older rows used dispatch time for IssuedAt, so their window semantics differ from new commands. Avoid mixed old/new scheduler instances during rollout.
- Legacy firmware may ignore the new MQTT fields and run for a full duration after delayed delivery. Do not claim priority or fixed-end stopping until compatible firmware is installed and tested. No firmware deployment or hardware tests were performed.
- Scheduler polling/network latency remains; short windows can expire before dispatch. Expired occurrences are deliberately not replayed later.
- HTTP admission is not an atomic distributed transaction with MQTT or concurrent schedule edits. Requests admitted immediately before a boundary can arrive after it; firmware enforcement is required, not optional.
- Flutter ApiService createPumpSchedule now accepts time-only strings. Both in-repository screen callers were updated; external Dart callers supplying ISO datetimes must adapt. HTTP schedule contract is unchanged.
