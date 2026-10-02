# Production Compose and MQTT Hardening Plan

## Outcome

Run the API behind HTTPS, keep API and PostgreSQL private, restart core containers, take tested off-server PostgreSQL backups, and expose MQTT only as authenticated TLS on port 8883. Development Compose and its anonymous port 1883 remain local-development only.

## Decisions

- Use a separate production Compose file. Do not weaken local `compose.yaml`.
- Caddy owns public API HTTPS. Public API ports are 80 and 443 only.
- Mosquitto uses a separate public `mqtt.<domain>:8883` TLS listener. No production port 1883 mapping.
- Use Mosquitto Dynamic Security. It is built into Mosquitto 2, supports live client/role/ACL changes, and avoids managing an ACL file per device.
- Device MQTT username equals existing random `DeviceKey`. Fixed client id is `iotagr-<hardwareId>`. This lets one role use `%u` ACL patterns while keeping current topic names.
- Device role may publish `devices/%u/readings` and `devices/%u/pump-status`, and subscribe only to `devices/%u/commands/pump`. API gets a separate least-privilege broker client. Dynamic-security admin is bootstrap/recovery only.
- Device password is random, returned once by successful claim, stored only in ESP32 NVS and Mosquitto Dynamic Security state. Lost response requires a new owner-issued provisioning code; do not store recoverable device passwords in PostgreSQL.
- TLS certificate ownership for `mqtt.<domain>` must be chosen before implementation. Caddy certificate storage is not a Mosquitto certificate-management interface.
- Keep one API/scheduler instance. This plan does not add CD, horizontal scaling, MQTT client certificates, or automatic pump enablement.

## Prerequisites

- `api.<domain>` and `mqtt.<domain>` A/AAAA records point to VPS.
- VPS firewall permits only TCP 80, 443, and 8883; SSH is restricted separately.
- Backup target, encryption, retention, and restoration owner are chosen. Credentials stay on VPS or backup provider, never in Git.
- MQTT certificate issuer and renewal method support reload/restart of Mosquitto before certificate expiry.

## Task 1: Production Compose boundary

**Description:** Add production-only Compose, Caddy, and production environment template.

**Acceptance criteria:**
- [ ] Only Caddy publishes 80/443; only Mosquitto publishes 8883.
- [ ] API and PostgreSQL have no host port. All long-running services use `restart: unless-stopped` and healthchecks.
- [ ] Production uses `ASPNETCORE_ENVIRONMENT=Production`, production CORS origin, strong secrets, and `PumpScheduling__Enabled=false`.

**Verification:** `docker compose -f compose.production.yaml config`; VPS port scan shows 80, 443, and 8883 only.

**Dependencies:** Prerequisites.

**Files likely touched:** `compose.production.yaml`, `deploy/Caddyfile`, `.env.production.example`.

**Estimated scope:** Medium.

## Task 2: Trusted reverse-proxy handling

**Description:** Configure ASP.NET Core to accept forwarded scheme/client headers only from Caddy's production network, before HTTPS redirection and rate limiting.

**Acceptance criteria:**
- [ ] `X-Forwarded-Proto` makes HTTPS requests reach API without redirect loop.
- [ ] Forwarded headers from non-Caddy networks are not trusted.
- [ ] Allowed host and CORS use production domain, not development localhost origins.

**Verification:** focused API test plus `curl -I http://api.<domain>/health` redirect and `curl https://api.<domain>/health` success.

**Dependencies:** Task 1.

**Files likely touched:** `backend/Program.cs`, `backend/appsettings.json`, `backend/tests/ProxyConfigurationTests.cs`.

**Estimated scope:** Small.

## Task 3: Off-server PostgreSQL backup and restore

**Description:** Add a host-timed backup command that makes a custom-format database dump plus globals, encrypts/transfers it to the selected off-server target, and reports failure.

**Acceptance criteria:**
- [ ] Backup process has least-privilege target credentials and never commits them.
- [ ] Retention is enforced at destination; local temporary dump is removed only after successful upload.
- [ ] Restore drill creates a disposable PostgreSQL instance and passes `pg_restore --list` plus API health check.

**Verification:** run backup once; restore latest object; record timestamp, object version, and result in deployment runbook.

**Dependencies:** Task 1 and selected backup target.

**Files likely touched:** `deploy/backup-postgres.sh`, `deploy/iotagri-backup.service`, `deploy/iotagri-backup.timer`, `deploy/README.md`.

**Estimated scope:** Medium.

## Checkpoint: Web and recovery

- [ ] Release API tests and build pass.
- [ ] External HTTPS health check passes.
- [ ] API/PostgreSQL are unreachable from VPS public IP.
- [ ] Restore drill passes before production data is trusted to this stack.

## Task 4: Mosquitto TLS and Dynamic Security bootstrap

**Description:** Add isolated production broker configuration, persistent Dynamic Security state, API broker account, and minimal roles. Bootstrap admin remains outside application runtime.

**Acceptance criteria:**
- [ ] `allow_anonymous false`; public listener is TLS on 8883; internal API listener is not published.
- [ ] Dynamic Security defaults deny publish, receive, subscribe, and unsubscribe unless a role permits them.
- [ ] Certificate renewal reloads or restarts Mosquitto and validates hostname without insecure client mode.

**Verification:** TLS handshake validates `mqtt.<domain>`; anonymous connection fails; broker survives restart with users and roles intact.

**Dependencies:** Task 1 and MQTT certificate lifecycle decision.

**Files likely touched:** `mosquitto/mosquitto.production.conf`, `deploy/bootstrap-mqtt-dynsec.sh`, `compose.production.yaml`, `deploy/README.md`.

**Estimated scope:** Medium.

## Task 5: Broker-account provisioning service

**Description:** Add one backend service that uses the broker Dynamic Security control API to create, rotate, disable, and remove device accounts. Keep broker-admin credentials out of database and API responses.

**Acceptance criteria:**
- [ ] Device account has username `DeviceKey`, random password, and exact hardware-derived client id.
- [ ] API client subscribes only to readings/status and publishes only pump commands.
- [ ] Provisioning failure leaves no usable orphan account; deletion/re-provisioning disables old account.

**Verification:** unit tests cover generated credentials, command payloads, failed provisioning cleanup, and no secrets in logs.

**Dependencies:** Task 4.

**Files likely touched:** `backend/Services/MqttBrokerAdminService.cs`, `backend/Services/MqttIngestionService.cs`, `backend/Program.cs`, `backend/tests/MqttBrokerAdminServiceTests.cs`.

**Estimated scope:** Medium.

## Task 6: One-time credential claim

**Description:** Extend claim response and claim flow to issue broker credentials after owner code validation, without changing `devices/{deviceKey}/...` topics.

**Acceptance criteria:**
- [ ] Claim response includes MQTT username, password, TLS host/port, and fixed client id only on successful claim.
- [ ] Existing atomic one-use-code behavior remains; a lost response requires owner re-provisioning rather than credential recovery.
- [ ] API does not persist plaintext password or return broker-admin credentials.

**Verification:** focused endpoint tests cover invalid, concurrent, broker-failure, successful, and re-provision cases.

**Dependencies:** Task 5.

**Files likely touched:** `backend/Endpoints/DeviceProvisioningEndpoints.cs`, `backend/Dtos/Devices/ClaimDeviceResponse.cs`, `backend/tests/DeviceProvisioningTests.cs`.

**Estimated scope:** Medium.

## Task 7: ESP32 HTTPS and MQTT TLS

**Description:** Replace plaintext network client with `WiFiClientSecure`, validate API and broker certificates, persist device credentials, and subscribe to pump commands.

**Acceptance criteria:**
- [ ] Firmware accepts only `useTls=true`; it never calls insecure TLS mode.
- [ ] Firmware authenticates with claimed username/password and fixed client id.
- [ ] Firmware publishes readings/status only to own topic and receives only own pump-command topic.

**Verification:** device connects to TLS broker, publishes reading, receives command, rejects wrong password and untrusted certificate.

**Dependencies:** Tasks 4-6.

**Files likely touched:** `firmware/ESP32DeviceSetup/ESP32DeviceSetup.ino`, firmware dependency manifest if required, `README.md`.

**Estimated scope:** Small.

## Task 8: Production MQTT authorization proof

**Description:** Add a disposable Compose verification script that proves permitted and forbidden broker operations using separate device/API credentials.

**Acceptance criteria:**
- [ ] Device A cannot publish, subscribe, or receive Device B topics.
- [ ] Device can publish own reading/status and receive own command; API can ingest/publish required wildcard topics.
- [ ] Anonymous, invalid-password, plaintext-public-port, and expired-certificate paths fail.

**Verification:** run authorization script against production-like Compose; retain results with release evidence.

**Dependencies:** Tasks 4-7.

**Files likely touched:** `deploy/verify-mqtt-security.sh`, `compose.production.yaml`, `deploy/README.md`.

**Estimated scope:** Small.

## Checkpoint: Production readiness

- [ ] `dotnet test backend/tests/IOTAgriBackend.Tests.csproj --configuration Release` passes.
- [ ] `dotnet build backend/IOTAgriBackend.csproj --configuration Release --no-restore` passes.
- [ ] `docker compose -f compose.production.yaml config` passes.
- [ ] HTTPS, MQTT authorization, restart, backup, and restore checks pass.
- [ ] README states production hardening is implemented only after these checks pass.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| MQTT certificate renewal breaks devices | Test automatic renewal/reload and hostname validation before go-live. |
| Broker/API state diverges | Broker service compensates failed claims; re-provision creates new credentials and disables old client. |
| MQTT credentials exposed | Return once over HTTPS, store only device NVS and broker hash, redact logs. |
| Backup exists but cannot restore | Require recurring restore drill, not upload success alone. |
| Public plaintext MQTT survives deployment | Production Compose contains no 1883 port mapping; firewall check is release gate. |

## Explicitly deferred

- CI/CD deployment and VPS credentials in GitHub.
- Mutual TLS/client certificates, broker clustering, horizontal API scaling, and generic secret-management platform.
- Enabling pump scheduling or automatic pump control.
