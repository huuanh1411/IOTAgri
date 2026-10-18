# Firmware MQTT contract

This document records the contract traced from the running backend source as of
the firmware integration branch. It supplements OpenAPI, which only describes
HTTP endpoints.

## Authoritative behavior

The backend owns authorization, command persistence, alert state, and the
schedule dispatcher. PostgreSQL owns persisted commands/readings. The ESP32
owns GPIO output and sensor validity; a pump command is not acknowledged until
the device reports its result. The Flutter client displays the resulting API
state and currently declares lighting unavailable.

| Workflow | FE | BE/API and database | MQTT / firmware |
| --- | --- | --- | --- |
| Provision device | Owner creates a one-time code | `POST /api/devices/{id}/provisioning-code`; one-use, 15 minutes | Captive portal calls `POST /api/device-provisioning/claims` with code and efuse ID |
| Telemetry | Dashboard/history show persisted readings | `MqttIngestionService` saves a reading and updates `IsOnline` / `LastSeenAt` | Publish `devices/{deviceKey}/readings` every 10 seconds |
| Manual pump | Pump controls show pending/acknowledged/failed state | `POST /api/devices/{id}/pump/commands` persists then publishes | Subscribe to `commands/pump`; enforce local safety; publish `pump-status` |
| Scheduled pump | Existing schedule UI | Dispatcher creates the same persisted command lifecycle | Executes the same MQTT command only |
| Alerts | Alert UI reads/resolves persisted alerts | Reading thresholds create/resolve device alerts | Valid temperature/water telemetry drives alerts |
| Connectivity | Device status/last seen | Presence is stale after backend timeout | Any accepted reading is the heartbeat |
| Lighting | Explicitly unavailable | No HTTP/MQTT/database contract | GPIO is held off; no light topic is used |

## MQTT payloads

Telemetry schema is `SensorReadingRequest`: `temperature`,
`solutionTemperature`, `humidity`, `ph`, `tds`, `waterLevel`, and `lux`, each a
JSON number or `null`. `waterLevel` is a percentage. Unknown fields are not part
of the contract and must not be relied on.

Pump command: `{ "commandId": "GUID", "isOn": true, "durationSeconds": 1..600 }`.
Turning off accepts `isOn: false`; no duration is required. Commands are QoS 1
from the backend. The firmware suppresses duplicate command IDs during its
current uptime and rejects duplicate IDs with changed contents.

Pump status: `{ "commandId": "GUID?", "isOn": bool, "success": bool,
"reason": "string?" }`. A status without `commandId` synchronizes device state
only. The backend treats a status with `success: false` as a failed command and
persists its reason.

## Configuration/security status

Development Compose uses plaintext port 1883 and an anonymous local broker;
`DeviceProvisioning:MqttHost` is supplied from `MQTT_PUBLIC_HOST`. Production
Compose advertises TLS. The claim response currently has no CA certificate or
per-device MQTT credentials, so the firmware safely rejects `useTls: true` and
does not disable certificate validation. A production release requires a
certificate-distribution and broker-ACL design; this is a known deployment
blocker, not a firmware workaround.
