# Danh mục API theo source

[← Mục lục](../README.md) · [SRS](../requirements/SRS.md) · [Nguồn](source-baseline.md)

Trích từ MapGet/MapPost/MapPut/MapDelete trong backend/Endpoints tại baseline. Dấu gạch chéo cuối được chuẩn hóa trong bảng; `{id:guid}` là ràng buộc route .NET. Đây là inventory method/path/quyền, không phải OpenAPI đầy đủ về request/response.

| Method | Path | Quyền / phạm vi | Nguồn |
| --- | --- | --- | --- |
| GET | `/api/admin/users` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/users/{userId}` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| PUT | `/api/admin/users/{userId}/role` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| PUT | `/api/admin/users/{userId}/lock` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/devices` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/devices/{id:guid}` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/devices/{id:guid}/readings` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/devices/{id:guid}/pump-commands` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| PUT | `/api/admin/devices/{id:guid}/owner` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/audit-logs` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/overview` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/reports/summary` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/reports.csv` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/status` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| GET | `/api/admin/settings/alert-defaults` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| PUT | `/api/admin/settings/alert-defaults` | AdminOnly | [AdminEndpoints.cs](source-baseline.md#backend-endpoints-adminendpoints-cs) |
| POST | `/api/auth/register` | Công khai | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| POST | `/api/auth/login` | Công khai | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| POST | `/api/auth/refresh` | Công khai | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| POST | `/api/auth/logout` | JWT | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| POST | `/api/auth/forgot-password` | Công khai | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| POST | `/api/auth/reset-password` | Công khai | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| POST | `/api/auth/change-password` | JWT | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| GET | `/api/auth/profile` | JWT | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| PUT | `/api/auth/profile` | JWT | [AuthEndpoints.cs](source-baseline.md#backend-endpoints-authendpoints-cs) |
| GET | `/api/dashboard/overview` | JWT, theo owner | [DashboardEndpoints.cs](source-baseline.md#backend-endpoints-dashboardendpoints-cs) |
| POST | `/api/devices` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| GET | `/api/devices` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| GET | `/api/devices/{id:guid}` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| PUT | `/api/devices/{id:guid}` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| DELETE | `/api/devices/{id:guid}` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| POST | `/api/devices/{id:guid}/pump/commands` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| GET | `/api/devices/{id:guid}/light-schedules` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| POST | `/api/devices/{id:guid}/light-schedules` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| PUT | `/api/devices/{id:guid}/light-schedules/{scheduleId:guid}` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| DELETE | `/api/devices/{id:guid}/light-schedules/{scheduleId:guid}` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| GET | `/api/devices/{id:guid}/pump-commands` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| POST | `/api/devices/{id:guid}/light/commands` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| GET | `/api/devices/{id:guid}/light/status` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| GET | `/api/devices/{id:guid}/pump-schedules` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| POST | `/api/devices/{id:guid}/pump-schedules` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| PUT | `/api/devices/{id:guid}/pump-schedules/{scheduleId:guid}` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| DELETE | `/api/devices/{id:guid}/pump-schedules/{scheduleId:guid}` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| GET | `/api/devices/{id:guid}/alert-settings` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| PUT | `/api/devices/{id:guid}/alert-settings` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| GET | `/api/devices/{id:guid}/alerts` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| PUT | `/api/devices/{id:guid}/alerts/{alertId:guid}/resolve` | JWT, theo owner | [DeviceEndpoints.cs](source-baseline.md#backend-endpoints-deviceendpoints-cs) |
| POST | `/api/devices/{deviceId:guid}/provisioning-code` | JWT, theo owner | [DeviceProvisioningEndpoints.cs](source-baseline.md#backend-endpoints-deviceprovisioningendpoints-cs) |
| POST | `/api/device-provisioning/claims` | Mã claim, rate limit | [DeviceProvisioningEndpoints.cs](source-baseline.md#backend-endpoints-deviceprovisioningendpoints-cs) |
| GET | `/api/devices/{deviceId:guid}/readings` | JWT, theo owner | [SensorEndpoints.cs](source-baseline.md#backend-endpoints-sensorendpoints-cs) |
| GET | `/api/devices/{deviceId:guid}/readings/aggregated` | JWT, theo owner | [SensorEndpoints.cs](source-baseline.md#backend-endpoints-sensorendpoints-cs) |
| GET | `/api/devices/{deviceId:guid}/readings/medians/hourly` | JWT, theo owner | [SensorEndpoints.cs](source-baseline.md#backend-endpoints-sensorendpoints-cs) |
| GET | `/api/devices/{deviceId:guid}/readings/medians/daily` | JWT, theo owner | [SensorEndpoints.cs](source-baseline.md#backend-endpoints-sensorendpoints-cs) |
| POST | `/api/tickets` | JWT, ticket cá nhân | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |
| GET | `/api/tickets` | JWT, ticket cá nhân | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |
| GET | `/api/tickets/{id:guid}` | JWT, ticket cá nhân | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |
| POST | `/api/tickets/{id:guid}/messages` | JWT, ticket cá nhân | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |
| GET | `/api/admin/tickets` | AdminOnly | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |
| GET | `/api/admin/tickets/{id:guid}` | AdminOnly | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |
| PUT | `/api/admin/tickets/{id:guid}/status` | AdminOnly | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |
| PUT | `/api/admin/tickets/{id:guid}/priority` | AdminOnly | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |
| POST | `/api/admin/tickets/{id:guid}/messages` | AdminOnly | [TicketEndpoints.cs](source-baseline.md#backend-endpoints-ticketendpoints-cs) |

Ngoài nghiệp vụ còn có `GET /health` (kiểm tra DB) và `GET /weatherforecast` (endpoint mẫu, không phải dự báo nông nghiệp). Swagger/OpenAPI chỉ được map trong Development. Endpoint claim và forgot-password có rate limit riêng; xem SRS để phân biệt HTTP 429 và 503.

Không tìm thấy mapping `/api/sensor/latest` dù PlantRepository cũ còn tham chiếu. Không dùng inventory này để khẳng định mọi client cũ đã tích hợp đúng.
