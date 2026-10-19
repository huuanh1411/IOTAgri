# Production Hardening Design

## Goal

Make one IOTAgri API instance safe to deploy publicly with HTTPS, private API/PostgreSQL networking, authenticated TLS MQTT, recoverable PostgreSQL backups, and evidence-based release gates.

## Scope

This design completes all unchecked requirements in `tasks/production-hardening-plan.md`.

### In scope

- Production container runtime hardening and configuration tests.
- Caddy reverse-proxy trust, production CORS/host behavior, disabled production Swagger, and API health checks.
- Mosquitto Dynamic Security device lifecycle, least-privilege API/device roles, and TLS authorization verification.
- One-time device credential claims, compensation after provisioning failure, and re-provisioning.
- ESP32 HTTPS and MQTT TLS with public CA validation and NVS-only device credentials.
- Off-server encrypted backup and documented, repeatable restore evidence.
- Deployment release checklist with VPS-only evidence fields.

### Out of scope

- CI/CD, secret-management platform, horizontal API scaling, broker clustering, MQTT mutual TLS, generic certificate-management platform, and automatic pump enablement.
- Changing development Compose anonymous MQTT on port 1883.

## Constraints

- Run exactly one API replica. `MqttIngestionService`, `PumpScheduleDispatchService`, and migrations execute in-process.
- API and PostgreSQL never publish host ports in production.
- Public host ports are TCP 80, 443, and 8883 only.
- Caddy handles `api.aerogreen.vn` HTTPS. Mosquitto exposes `mqtt.aerogreen.vn:8883` with TLS 1.2 or newer.
- ESP32 trusts a public CA root embedded in firmware. Firmware never calls insecure TLS APIs.
- Device username remains `DeviceKey`; client ID is exactly `iotagr-<hardwareId>`.
- Device password exists only in successful claim response, ESP32 NVS, and broker Dynamic Security state. PostgreSQL never stores it.
- Admin/broker-control credentials remain environment-only. Logs and API responses never expose them.
- Pump scheduling remains disabled in production.

## Architecture

### Runtime boundary

Caddy is the only public HTTP entry point. It proxies to the internal API service. `ForwardedHeadersMiddleware` accepts `X-Forwarded-For` and `X-Forwarded-Proto` only from the Docker bridge network before HTTPS redirection and rate limiting.

The API image runs as an unprivileged user. Production Compose declares health checks for API, PostgreSQL, and Mosquitto, restart policy `unless-stopped`, one API replica, and explicit CPU/memory limits sized for the VPS. PostgreSQL volume ownership matches the database container user.

### MQTT authorization

Mosquitto Dynamic Security is persistent and default-deny. A bootstrap-only `dynsec-admin` client creates roles and the application `api` client. The API owns `IMqttBrokerAdminService`, which speaks only to the broker Dynamic Security control interface with the admin credential supplied through environment configuration.

The service creates one client per device with username `DeviceKey`, generated password, and exact client ID. It supports create, delete, and replacement as operations required by claims and re-provisioning. It never persists client passwords.

Device role permits only these own-topic operations:

- Send readings: `devices/%u/readings`
- Send pump status: `devices/%u/pump-status`
- Send light status: `devices/%u/light-status`
- Subscribe/receive pump commands: `devices/%u/commands/pump`
- Subscribe/receive light commands: `devices/%u/commands/light`

API role permits only wildcard readings/status subscriptions and pump/light command publication.

### Claim lifecycle

1. Claim endpoint validates request and looks up an unused, non-expired, owner-created provisioning code.
2. It derives normalized hardware ID and fixed client ID.
3. Broker service removes any old account for the device, creates a replacement client with random password, and assigns `device` role.
4. Endpoint atomically consumes provisioning code and stores only provisioned timestamp/hardware ID.
5. On database concurrency failure or persistence error, endpoint deletes new broker client. A response never contains credentials after failed claim.
6. Successful response contains device key, MQTT host/port, `useTls: true`, username, password, and client ID once.

A new owner-generated provisioning code is required after a lost response. Credential recovery is not supported.

### Firmware

Firmware replaces plaintext HTTP/MQTT transports with `WiFiClientSecure`. It uses public CA root certificates and server hostnames for both API and broker. It accepts only TLS claims, saves MQTT username/password/client ID with other network setup values in NVS, authenticates every MQTT connection, and only subscribes/publishes own pump/light topics. Existing local pump safety behavior remains unchanged.

### Backup and deployment evidence

The backup service produces custom PostgreSQL dump and globals, encrypts both with age, uploads using least-privilege rclone credentials, then applies destination retention. Temporary files remain local only until successful upload. Restore drill uses a disposable PostgreSQL container, validates `pg_restore --list`, restores database, starts scratch API against restored data, and records result.

`deploy/verify-mqtt-security.sh` runs against production-like Compose or VPS with supplied disposable credentials. It proves allowed operations and expected denials. Deployment runbook records date, commit, Compose validation, public port scan, HTTPS health, broker verifier, backup object, and restore drill result.

## Error Handling

- Broker create/update/delete failures make claims return `503` without consuming a code.
- If broker succeeds but database claim consume fails, service deletes replacement account. Cleanup failure is logged without password or admin secret and returns failure; release procedure manually removes account before retry.
- Re-provisioning replaces/disables old broker account before new credentials return.
- Firmware rejects missing TLS values, certificate validation failure, wrong password, missing claim credential fields, or invalid client ID. It remains in setup mode without storing partial credentials.
- Broker bootstrap and verifier fail closed on missing environment values, TLS validation failure, unexpected public port, or forbidden operation success.
- Backup upload/retention failure fails systemd service and preserves local temporary dump until process exits; restore evidence cannot be marked passed without API health check.

## Public Seams and Tests

| Seam | Required proof |
|---|---|
| Production Compose config | Services have expected ports, health checks, restart policy, user, resource limits, and no API/PostgreSQL host port. |
| API pipeline | Known Caddy network forwarded headers affect scheme/client rate-limit key; external headers do not. Swagger/OpenAPI unavailable in Production. |
| `IMqttBrokerAdminService` | Generated Dynamic Security commands use exact username, client ID, roles, and cleanup behavior; secrets absent from logs. |
| Device claim endpoint | Invalid, concurrent, broker failure, successful claim, persistence failure cleanup, and re-provision flows. |
| Firmware claim/MQTT configuration | TLS-only config, stored credentials/client ID, authenticated connection, no insecure TLS call. Hardware validation remains manual. |
| Broker verifier | Own-topic allowed; cross-device, anonymous, bad-password, plaintext public listener, and hostname/certificate failures denied. |
| Backup restore drill | Encrypted upload succeeds; newest object decrypts, lists, restores, and supports scratch API `/health`. |

## Release Acceptance

Production readiness is achieved only when:

1. Release backend tests/build and production Compose config pass.
2. VPS firewall and external port scan expose only 80, 443, and 8883.
3. HTTP redirects to HTTPS and HTTPS `/health` succeeds.
4. API/PostgreSQL remain unreachable on public VPS IP.
5. MQTT verifier passes every allow/deny case.
6. Mosquitto restart retains Dynamic Security users/roles.
7. Scheduled backup uploads encrypted objects and restore drill passes.
8. Deployment runbook contains release evidence for all gates.
