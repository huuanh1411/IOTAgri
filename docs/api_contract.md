# Aerogreen API contract

## Website commerce extension

The `Website` branch adds `/api/store/*` and `/api/admin/store/*` for hardware,
prepaid refill packages and MoMo payments. See [`website/README.md`](../website/README.md)
for request/response shapes, payment verification, configuration and limitations.
The captured OpenAPI snapshot below predates these routes; live Swagger includes them.

`docs/openapi.v1.json` is the generated OpenAPI 3.0 document captured from the
running API on 2026-10-16. This document supplies the response, ownership, and
error conventions which cannot yet be inferred by the Minimal API's `IResult`
signatures.

## Global conventions

- Requests and responses use camelCase JSON.
- IDs are UUID strings. All persisted timestamps are UTC ISO-8601 strings.
- Private routes require `Authorization: Bearer <accessToken>`; `/api/admin/*`
  additionally requires the `Admin` role.
- Page responses are `{ items, page, pageSize, totalCount }`, with one-based
  `page` and `pageSize` in `1..100`.
- The API uses `400 { error }` for rule validation, ASP.NET validation-problem
  payloads for model/Identity validation, `401` for unauthenticated requests,
  `403` for authorization failures, `404` for missing or non-owned resources,
  and `409 { error }` for conflicts. Callers must not fabricate success data.

## Authentication

| Method | Route | Auth | Success | Body |
|---|---|---:|---:|---|
| POST | `/api/auth/register` | no | 201 | `email`, `password` (min 8), `fullName` |
| POST | `/api/auth/login` | no | 200 | `email`, `password` |
| POST | `/api/auth/refresh` | no | 200 | `refreshToken` |
| POST | `/api/auth/logout` | yes | 204 | `refreshToken` |
| POST | `/api/auth/change-password` | yes | 204 | `currentPassword`, `newPassword`, `logoutOtherDevices` |
| GET / PUT | `/api/auth/profile` | yes | 200 | PUT: `fullName`, nullable `phoneNumber` |

Login and refresh return `{ accessToken, refreshToken, expiresAt }`. Refresh
rotates the prior refresh token. A password change validates the current
password through Identity; when `logoutOtherDevices` is true, all active refresh
tokens for that user are revoked because refresh tokens have no device identity.

## Devices, telemetry, commands, and alerts

| Method | Route | Success | Important request/query fields |
|---|---|---:|---|
| GET / POST | `/api/devices` | 200 / 201 | POST: `name` |
| GET / PUT / DELETE | `/api/devices/{id}` | 200 / 200 / 204 | PUT: `name` |
| POST | `/api/devices/{id}/provisioning-code` | 200 | one-time code, owner only |
| POST | `/api/device-provisioning/claims` | 200 | `code`, `hardwareId`; hardware flow, rate-limited |
| GET | `/api/dashboard/overview` | 200 | `DeviceOverview[]` |
| GET | `/api/devices/{id}/readings` | 200 | `take` in `1..500`, default 50 |
| GET | `/api/devices/{id}/readings/aggregated` | 200 | UTC `from`, UTC `to`, `interval`: minute/hour/day/week/month |
| GET | `/api/devices/{id}/readings/medians/hourly` | 200 | `date` (UTC date) |
| GET | `/api/devices/{id}/readings/medians/daily` | 200 | `weekStart` (Monday, UTC date) |
| POST | `/api/devices/{id}/pump/commands` | 201 | UUID `commandId`, `isOn`, nullable `durationSeconds` |
| GET | `/api/devices/{id}/pump-commands` | 200 | UTC `from`, UTC `to`, `page`, `pageSize`; max range 31 days |
| GET / POST | `/api/devices/{id}/pump-schedules` | 200 / 201 | schedule body uses `TimeOnly` strings, `weekdayMask`, `timeZone` |
| PUT / DELETE | `/api/devices/{id}/pump-schedules/{scheduleId}` | 200 / 204 | full valid schedule body for PUT |
| GET / PUT | `/api/devices/{id}/alert-settings` | 200 | nullable finite `highTemperatureC`, `lowWaterLevelPercent` in 0..100 |
| GET | `/api/devices/{id}/alerts` | 200 | `status`: active/resolved/all, pagination |
| PUT | `/api/devices/{id}/alerts/{alertId}/resolve` | 200 | idempotently sets `resolvedAt`, owner only |

`SensorReading` always includes `id`, `deviceId`, telemetry values (nullable),
and `recordedAt`. `DeviceOverview` uses `deviceId`, `latestReading`, and
`activeAlerts`. A `PumpCommand` is only physically confirmed when its status is
`Acknowledged` and its acknowledgement fields reflect the device; `201` only
means the request was persisted and published to MQTT.

## Support tickets

| Method | Route | Auth | Success | Body/query |
|---|---|---:|---:|---|
| GET | `/api/tickets` | owner | 200 | optional `status`, pagination |
| POST | `/api/tickets` | owner | 201 | `subject`, `message`, optional `category`, owner-owned `deviceId` |
| GET | `/api/tickets/{id}` | owner | 200 | owner only |
| POST | `/api/tickets/{id}/messages` | owner | 200 | `message` |
| GET / GET | `/api/admin/tickets`, `/api/admin/tickets/{id}` | admin | 200 | admin list/detail |
| PUT | `/api/admin/tickets/{id}/status` | admin | 200 | status: open/in_progress/closed |
| PUT | `/api/admin/tickets/{id}/priority` | admin | 200 | priority: low/medium/high |
| POST | `/api/admin/tickets/{id}/messages` | admin | 200 | `message` |

Ticket detail responses are `{ ticket, messages }`. Ticket summaries and details
persist `category`, nullable `deviceId`, and nullable `deviceName`; old rows use
the database default `Kỹ thuật`. Message fields are `isAdmin` and `message` at
the transport boundary; Flutter maps them to its UI-oriented `isStaff` and
`body` fields centrally.

## Admin and runtime routes

The generated OpenAPI file covers all admin routes: users and lock/role updates,
devices and owner updates, readings/command history, audit logs, overview,
report summary/CSV, system status, and alert defaults. `/health` is public and
returns `{ status: "ready" }` when PostgreSQL is reachable.

## Provisioning and MQTT safety

Provisioning codes are write-only: an owner may generate a 15-minute, single-use
code, but no active-code read endpoint exists. The claim route does not return a
user `Device`; it returns hardware MQTT configuration. This prevents disclosure
of live provisioning secrets through normal Flutter sessions.

## Firmware MQTT contract

Firmware publishes sensor measurements to `devices/{deviceKey}/readings`.
The JSON payload includes temperature, humidity, soil moisture, and a nullable
`lux` value from the BH1750 light sensor. A missing or unavailable BH1750 is
reported as `null` instead of preventing the remaining readings from being sent.

Pump commands and status use `devices/{deviceKey}/commands/pump` and
`devices/{deviceKey}/pump-status`. Light commands and status use
`devices/{deviceKey}/commands/light` and `devices/{deviceKey}/light-status`.
