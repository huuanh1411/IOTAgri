# Aerogreen IoT System - API Contract Specification

This document defines the formal API contract between the **Aerogreen Frontend Client (Flutter Mobile & Web)**, the **Backend Minimal API (.NET 9)**, and the **ESP32 Firmware via Mosquitto MQTT Broker**.

---

## 1. Authentication & Security

All private endpoints require an `Authorization: Bearer <access_token>` header.

### 1.1 Token Lifecycles
- **Access Token**: Short-lived JWT (15 minutes). Contains claims:
  - `sub`: User unique identifier (UUID)
  - `email`: User email address
  - `role`: Role string or array (`["User"]` or `["Admin", "User"]`)
- **Refresh Token**: Long-lived secure token (7 days). Stored in secure storage on client and `RefreshTokens` table in DB.

---

## 2. REST API Endpoints

### 2.1 Authentication & Profile (`/api/auth`)

| Method | Endpoint | Description | Request Body | Response (200/201) |
|---|---|---|---|---|
| `POST` | `/api/auth/register` | Register new user | `{ email, password, fullName }` | `{ id, email, fullName }` (201) |
| `POST` | `/api/auth/login` | Login with credentials | `{ email, password }` | `{ accessToken, refreshToken, expiresAt }` |
| `POST` | `/api/auth/refresh` | Refresh access token | `{ refreshToken }` | `{ accessToken, refreshToken, expiresAt }` |
| `POST` | `/api/auth/logout` | Revoke session | `{ refreshToken }` | `204 No Content` |
| `GET` | `/api/auth/profile` | Current user profile | None | `{ id, email, fullName, phoneNumber, roles }` |
| `PUT` | `/api/auth/profile` | Update profile | `{ fullName, phoneNumber }` | `{ id, email, fullName, phoneNumber, roles }` |
| `POST` | `/api/auth/change-password` | Change password | `{ currentPassword, newPassword, logoutOtherDevices }` | `200 OK` |

---

### 2.2 Devices & Provisioning (`/api/devices`)

| Method | Endpoint | Description | Request Body | Response |
|---|---|---|---|---|
| `GET` | `/api/devices` | List claimed devices | None | `Device[]` |
| `GET` | `/api/devices/{id}` | Device detail | None | `Device` |
| `POST` | `/api/devices` | Create new device entity | `{ name }` | `Device` (201) |
| `PUT` | `/api/devices/{id}` | Rename device | `{ name }` | `Device` |
| `DELETE` | `/api/devices/{id}` | Unclaim / remove device | None | `204 No Content` |
| `POST` | `/api/devices/{id}/provisioning-code` | Generate one-use claim code | None | `{ code, expiresAt }` |
| `POST` | `/api/device-provisioning/claims` | Firmware claims a device | `{ code, hardwareId }` | `{ deviceKey, mqttHost, mqttPort, useTls }` |

---

### 2.3 Dashboard & Telemetry (`/api/dashboard`, `/api/devices/{id}`)

| Method | Endpoint | Description | Query Params | Response |
|---|---|---|---|---|
| `GET` | `/api/dashboard/overview` | All claimed devices summary | None | `DeviceOverview[]` |
| `GET` | `/api/devices/{id}/readings` | Recent sensor readings | `limit` (int, default 1) | `SensorReading[]` |
| `GET` | `/api/devices/{id}/aggregated-readings` | Historical buckets | `range` (`24h`,`7d`,`30d`), `interval` | `AggregatedReadingBucket[]` |

#### SensorReading Payload Format
```json
{
  "id": "reading-123456",
  "deviceId": "device-uuid",
  "temperature": 26.5,
  "solutionTemperature": 24.2,
  "humidity": 68.0,
  "ph": 6.2,
  "tds": 540.0,
  "waterLevel": 85.0,
  "recordedAt": "2026-10-09T12:00:00Z"
}
```

---

### 2.4 Pump Actuator & Schedules (`/api/devices/{id}`)

| Method | Endpoint | Description | Request Body | Response |
|---|---|---|---|---|
| `POST` | `/api/devices/{id}/pump/commands` | Issue manual command | `{ commandId, isOn, durationSeconds }` | `PumpCommand` (201) |
| `POST` | `/api/devices/{id}/light/commands` | Issue manual light command | `{ commandId, isOn }` | `{ commandId, isOn, status }` (202) |
| `GET` | `/api/devices/{id}/pump-commands` | Command audit log | `page`, `pageSize`, `rangeHours` | `{ items: PumpCommand[], totalCount }` |
| `GET` | `/api/devices/{id}/pump-schedules` | List recurring schedules | None | `PumpSchedule[]` |
| `POST` | `/api/devices/{id}/pump-schedules` | Create recurring schedule | `{ isEnabled, weekdayMask, startTime, durationSeconds, timeZone }` | `PumpSchedule` (201) |
| `PUT` | `/api/devices/{id}/pump-schedules/{sid}` | Update schedule | `{ isEnabled, weekdayMask, startTime, durationSeconds, timeZone }` | `PumpSchedule` |
| `DELETE` | `/api/devices/{id}/pump-schedules/{sid}` | Delete schedule | None | `204 No Content` |

---

### 2.5 Alerts & Thresholds (`/api/devices/{id}`)

| Method | Endpoint | Description | Request Body | Response |
|---|---|---|---|---|
| `GET` | `/api/devices/{id}/alerts` | List device alerts | `status` (`all`,`unresolved`), `page`, `pageSize` | `{ items: DeviceAlert[], totalCount }` |
| `PUT` | `/api/devices/{id}/alerts/{aid}/resolve` | Mark alert resolved | None | `204 No Content` |
| `GET` | `/api/devices/{id}/alert-settings` | Current thresholds | None | `{ highTemperatureC, lowWaterLevelPercent }` |
| `PUT` | `/api/devices/{id}/alert-settings` | Update thresholds | `{ highTemperatureC, lowWaterLevelPercent }` | `{ highTemperatureC, lowWaterLevelPercent }` |

---

### 2.6 Support Tickets (`/api/tickets`, `/api/admin/tickets`)

| Method | Endpoint | Description | Request Body | Response |
|---|---|---|---|---|
| `GET` | `/api/tickets` | List user's tickets | `status` (`open`,`in_progress`,`resolved`) | `SupportTicket[]` |
| `POST` | `/api/tickets` | Submit new ticket | `{ subject, message }` | `SupportTicketDetail` (201) |
| `GET` | `/api/tickets/{id}` | Ticket details with thread | None | `SupportTicketDetail` |
| `POST` | `/api/tickets/{id}/messages` | Reply to ticket thread | `{ message }` | `SupportTicketMessage` (200) |

---

## 3. MQTT Broker Specification

Broker: Eclipse Mosquitto on port `1883` (TCP) / `9001` (WebSocket SSL).

### 3.1 Topic Hierarchy

```
devices/{deviceKey}/
  ├── readings              (Telemetry: ESP32 -> Backend)
  ├── commands/pump         (Command:   Backend -> ESP32)
  ├── pump-status           (ACK/State: ESP32 -> Backend)
  ├── commands/light        (Extension: MQTT client -> ESP32)
  └── light-status          (Extension: ESP32 -> MQTT clients)
```

The backend publishes both actuator command topics and consumes telemetry plus both status topics. Light state is stored on the device and is also refreshed from the telemetry `lightState` field.

### 3.2 Telemetry Message: `devices/{deviceKey}/readings`
- **Direction**: ESP32 Firmware -> Mosquitto -> Ingestion Service
- **QoS**: 0 from the current `PubSubClient` firmware
- **Retain**: false
- **Payload**:
```json
{
  "temperature": 26.5,
  "solutionTemperature": 24.2,
  "humidity": 68.0,
  "ph": null,
  "tds": 540,
  "waterLevel": 85.0,
  "lux": null,
  "waterDistanceCm": 4.5,
  "waterLevelCm": 25.5,
  "waterLevelValid": true,
  "lowWater": false,
  "pumpState": false,
  "lightState": true,
  "wifiRssi": -55
}
```

`temperature`, `solutionTemperature`, `humidity`, `ph`, `tds`, `waterLevel`, and `lux` are persisted as sensor readings. `lightState` updates the device actuator state. The remaining fields are forward-compatible diagnostics currently ignored by .NET JSON deserialization. Invalid sensor values are sent as JSON `null`, never as a fabricated zero.

### 3.3 Pump Actuator Command: `devices/{deviceKey}/commands/pump`
- **Direction**: Backend Service -> Mosquitto -> ESP32
- **QoS**: 1
- **Retain**: false
- **Payload**:
```json
{
  "commandId": "ad2ff566-68e4-4e96-a799-9bb617c0e491",
  "isOn": true,
  "durationSeconds": 60
}
```

### 3.4 Pump Status & Acknowledgement: `devices/{deviceKey}/pump-status`
- **Direction**: ESP32 Firmware -> Mosquitto -> Backend & Mobile
- **QoS**: 0 from the current `PubSubClient` firmware
- **Retain**: true
- **Payload**:
```json
{
  "commandId": "ad2ff566-68e4-4e96-a799-9bb617c0e491",
  "isOn": true,
  "success": true,
  "remainingSeconds": 59
}
```

On a safety rejection, firmware responds with `isOn:false`, `success:false`, and `reason:"LOW_WATER"` or `reason:"WATER_LEVEL_SENSOR_INVALID"`. State-only transitions (timer completion, local safety, boot/reconnect synchronization) may omit `commandId`.

### 3.5 Light Control: `commands/light` and `light-status`

Command payload:

```json
{
  "commandId": "87e946f2-4701-48f3-8843-5823662c15f1",
  "isOn": true
}
```

Status payload uses the same `{ commandId?, isOn, success, reason? }` shape as pump status. The backend subscribes to `light-status`, persists `isOn`, and exposes the current state in device responses.

---

## 4. Error Responses

Standard problem details format:
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Bad Request",
  "status": 400,
  "error": "mist length must be less than interval."
}
```
Common status codes:
- `400 Bad Request`: Validation failure.
- `401 Unauthorized`: Token missing, expired, or invalid.
- `403 Forbidden`: Insufficient role permissions.
- `404 Not Found`: Device or resource does not exist.
- `409 Conflict`: Duplicate entry or schedule overlap.
