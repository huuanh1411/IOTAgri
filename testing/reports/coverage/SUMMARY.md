# Measured backend coverage

Source: Coverlet collector Cobertura/JSON. Migrations, generated obj files and the test assembly are excluded; Program.cs and all other instrumented backend files remain in the denominator.

Line counters aggregate collector class entries (including compiler-generated lambdas/state machines); branch counters come from JSON so branches without a line sequence point are retained. Totals are verified against Cobertura; no manual estimates.

Instruction coverage: NOT AVAILABLE (Coverlet does not emit instruction counters).

| Module | Lines hit / valid | Line coverage | Branches hit / valid | Branch coverage |
| --- | --- | --- | --- | --- |
| Data | 170/171 | 99.42% | 19/20 | 95.00% |
| Dtos | 194/295 | 65.76% | 49/50 | 98.00% |
| Endpoints | 667/976 | 68.34% | 174/392 | 44.39% |
| Models | 106/110 | 96.36% | 5/6 | 83.33% |
| Root/runtime | 0/141 | 0.00% | 0/22 | 0.00% |
| Services | 262/378 | 69.31% | 216/270 | 80.00% |

## By source file

| File | Lines hit / valid | Line coverage | Branches hit / valid | Branch coverage |
| --- | --- | --- | --- | --- |
| [Data/AdminBootstrapSettings.cs](../../../backend/Data/AdminBootstrapSettings.cs) | 25/25 | 100.00% | 15/16 | 93.75% |
| [Data/ApplicationDbContext.cs](../../../backend/Data/ApplicationDbContext.cs) | 137/138 | 99.28% | 0/0 | N/A (no branches) |
| [Data/RoleSeeder.cs](../../../backend/Data/RoleSeeder.cs) | 8/8 | 100.00% | 4/4 | 100.00% |
| [Dtos/Admin/AdminAuditLogResponse.cs](../../../backend/Dtos/Admin/AdminAuditLogResponse.cs) | 10/20 | 50.00% | 0/0 | N/A (no branches) |
| [Dtos/Admin/AdminDeviceResponse.cs](../../../backend/Dtos/Admin/AdminDeviceResponse.cs) | 0/14 | 0.00% | 0/0 | N/A (no branches) |
| [Dtos/Admin/AdminSystemContracts.cs](../../../backend/Dtos/Admin/AdminSystemContracts.cs) | 5/13 | 38.46% | 6/6 | 100.00% |
| [Dtos/Admin/AdminUserResponse.cs](../../../backend/Dtos/Admin/AdminUserResponse.cs) | 0/3 | 0.00% | 0/0 | N/A (no branches) |
| [Dtos/Admin/UpdateDeviceOwnerRequest.cs](../../../backend/Dtos/Admin/UpdateDeviceOwnerRequest.cs) | 0/1 | 0.00% | 0/0 | N/A (no branches) |
| [Dtos/Admin/UpdateUserLockRequest.cs](../../../backend/Dtos/Admin/UpdateUserLockRequest.cs) | 0/1 | 0.00% | 0/0 | N/A (no branches) |
| [Dtos/Admin/UpdateUserRoleRequest.cs](../../../backend/Dtos/Admin/UpdateUserRoleRequest.cs) | 0/1 | 0.00% | 0/0 | N/A (no branches) |
| [Dtos/Alerts/DeviceAlertContracts.cs](../../../backend/Dtos/Alerts/DeviceAlertContracts.cs) | 23/23 | 100.00% | 21/22 | 95.45% |
| [Dtos/Auth/AuthResponse.cs](../../../backend/Dtos/Auth/AuthResponse.cs) | 5/5 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Auth/LoginRequest.cs](../../../backend/Dtos/Auth/LoginRequest.cs) | 4/4 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Auth/RefreshRequest.cs](../../../backend/Dtos/Auth/RefreshRequest.cs) | 3/3 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Auth/RegisterRequest.cs](../../../backend/Dtos/Auth/RegisterRequest.cs) | 5/5 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Auth/UpdateProfileRequest.cs](../../../backend/Dtos/Auth/UpdateProfileRequest.cs) | 4/4 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Auth/UserProfileResponse.cs](../../../backend/Dtos/Auth/UserProfileResponse.cs) | 5/7 | 71.43% | 0/0 | N/A (no branches) |
| [Dtos/Auth/UserSummaryResponse.cs](../../../backend/Dtos/Auth/UserSummaryResponse.cs) | 5/5 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Dashboard/AggregatedReadingBucket.cs](../../../backend/Dtos/Dashboard/AggregatedReadingBucket.cs) | 8/25 | 32.00% | 0/0 | N/A (no branches) |
| [Dtos/Dashboard/DeviceOverviewResponse.cs](../../../backend/Dtos/Dashboard/DeviceOverviewResponse.cs) | 5/8 | 62.50% | 0/0 | N/A (no branches) |
| [Dtos/Devices/ClaimDeviceRequest.cs](../../../backend/Dtos/Devices/ClaimDeviceRequest.cs) | 4/4 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Devices/ClaimDeviceResponse.cs](../../../backend/Dtos/Devices/ClaimDeviceResponse.cs) | 3/6 | 50.00% | 0/0 | N/A (no branches) |
| [Dtos/Devices/CreateDeviceRequest.cs](../../../backend/Dtos/Devices/CreateDeviceRequest.cs) | 3/3 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Devices/CreateProvisioningCodeResponse.cs](../../../backend/Dtos/Devices/CreateProvisioningCodeResponse.cs) | 1/1 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Devices/DeviceResponse.cs](../../../backend/Dtos/Devices/DeviceResponse.cs) | 3/7 | 42.86% | 0/0 | N/A (no branches) |
| [Dtos/Devices/UpdateDeviceRequest.cs](../../../backend/Dtos/Devices/UpdateDeviceRequest.cs) | 3/3 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Pumps/PumpCommandHistoryQuery.cs](../../../backend/Dtos/Pumps/PumpCommandHistoryQuery.cs) | 9/9 | 100.00% | 8/8 | 100.00% |
| [Dtos/Pumps/PumpCommandHistoryResponse.cs](../../../backend/Dtos/Pumps/PumpCommandHistoryResponse.cs) | 8/17 | 47.06% | 0/0 | N/A (no branches) |
| [Dtos/Pumps/PumpCommandRequest.cs](../../../backend/Dtos/Pumps/PumpCommandRequest.cs) | 5/5 | 100.00% | 8/8 | 100.00% |
| [Dtos/Pumps/PumpCommandResponse.cs](../../../backend/Dtos/Pumps/PumpCommandResponse.cs) | 0/9 | 0.00% | 0/0 | N/A (no branches) |
| [Dtos/Pumps/PumpMqttMessages.cs](../../../backend/Dtos/Pumps/PumpMqttMessages.cs) | 10/10 | 100.00% | 4/4 | 100.00% |
| [Dtos/Pumps/PumpScheduleContracts.cs](../../../backend/Dtos/Pumps/PumpScheduleContracts.cs) | 12/20 | 60.00% | 0/0 | N/A (no branches) |
| [Dtos/Sensors/SensorMedianBucket.cs](../../../backend/Dtos/Sensors/SensorMedianBucket.cs) | 20/20 | 100.00% | 2/2 | 100.00% |
| [Dtos/Sensors/SensorReadingRequest.cs](../../../backend/Dtos/Sensors/SensorReadingRequest.cs) | 9/9 | 100.00% | 0/0 | N/A (no branches) |
| [Dtos/Sensors/SensorReadingResponse.cs](../../../backend/Dtos/Sensors/SensorReadingResponse.cs) | 3/11 | 27.27% | 0/0 | N/A (no branches) |
| [Dtos/Tickets/SupportTicketContracts.cs](../../../backend/Dtos/Tickets/SupportTicketContracts.cs) | 19/19 | 100.00% | 0/0 | N/A (no branches) |
| [Endpoints/AdminEndpoints.cs](../../../backend/Endpoints/AdminEndpoints.cs) | 96/289 | 33.22% | 16/144 | 11.11% |
| [Endpoints/AuthEndpoints.cs](../../../backend/Endpoints/AuthEndpoints.cs) | 93/105 | 88.57% | 32/40 | 80.00% |
| [Endpoints/DashboardEndpoints.cs](../../../backend/Endpoints/DashboardEndpoints.cs) | 37/37 | 100.00% | 3/4 | 75.00% |
| [Endpoints/DeviceEndpoints.cs](../../../backend/Endpoints/DeviceEndpoints.cs) | 213/287 | 74.22% | 50/94 | 53.19% |
| [Endpoints/DeviceProvisioningEndpoints.cs](../../../backend/Endpoints/DeviceProvisioningEndpoints.cs) | 45/46 | 97.83% | 14/16 | 87.50% |
| [Endpoints/SensorEndpoints.cs](../../../backend/Endpoints/SensorEndpoints.cs) | 82/104 | 78.85% | 14/24 | 58.33% |
| [Endpoints/TicketEndpoints.cs](../../../backend/Endpoints/TicketEndpoints.cs) | 101/108 | 93.52% | 45/70 | 64.29% |
| [Models/AdminAuditLog.cs](../../../backend/Models/AdminAuditLog.cs) | 8/8 | 100.00% | 0/0 | N/A (no branches) |
| [Models/ApplicationUser.cs](../../../backend/Models/ApplicationUser.cs) | 2/2 | 100.00% | 0/0 | N/A (no branches) |
| [Models/Device.cs](../../../backend/Models/Device.cs) | 20/20 | 100.00% | 0/0 | N/A (no branches) |
| [Models/DeviceAlert.cs](../../../backend/Models/DeviceAlert.cs) | 7/8 | 87.50% | 0/0 | N/A (no branches) |
| [Models/DevicePresence.cs](../../../backend/Models/DevicePresence.cs) | 2/2 | 100.00% | 3/4 | 75.00% |
| [Models/PumpCommand.cs](../../../backend/Models/PumpCommand.cs) | 10/11 | 90.91% | 0/0 | N/A (no branches) |
| [Models/PumpSchedule.cs](../../../backend/Models/PumpSchedule.cs) | 13/13 | 100.00% | 0/0 | N/A (no branches) |
| [Models/PumpScheduleOccurrence.cs](../../../backend/Models/PumpScheduleOccurrence.cs) | 6/6 | 100.00% | 0/0 | N/A (no branches) |
| [Models/RefreshToken.cs](../../../backend/Models/RefreshToken.cs) | 9/9 | 100.00% | 2/2 | 100.00% |
| [Models/SensorReading.cs](../../../backend/Models/SensorReading.cs) | 10/11 | 90.91% | 0/0 | N/A (no branches) |
| [Models/SupportTicket.cs](../../../backend/Models/SupportTicket.cs) | 15/16 | 93.75% | 0/0 | N/A (no branches) |
| [Models/SystemAlertDefaults.cs](../../../backend/Models/SystemAlertDefaults.cs) | 4/4 | 100.00% | 0/0 | N/A (no branches) |
| [Program.cs](../../../backend/Program.cs) | 0/141 | 0.00% | 0/22 | 0.00% |
| [Services/AdminRoleRules.cs](../../../backend/Services/AdminRoleRules.cs) | 9/9 | 100.00% | 30/30 | 100.00% |
| [Services/DeviceAlertRules.cs](../../../backend/Services/DeviceAlertRules.cs) | 7/7 | 100.00% | 12/12 | 100.00% |
| [Services/MqttIngestionService.cs](../../../backend/Services/MqttIngestionService.cs) | 95/175 | 54.29% | 33/72 | 45.83% |
| [Services/ProfileRules.cs](../../../backend/Services/ProfileRules.cs) | 10/10 | 100.00% | 30/30 | 100.00% |
| [Services/ProvisioningCode.cs](../../../backend/Services/ProvisioningCode.cs) | 4/4 | 100.00% | 0/0 | N/A (no branches) |
| [Services/PumpScheduleDispatchService.cs](../../../backend/Services/PumpScheduleDispatchService.cs) | 54/89 | 60.67% | 7/20 | 35.00% |
| [Services/PumpScheduleRules.cs](../../../backend/Services/PumpScheduleRules.cs) | 51/52 | 98.08% | 76/78 | 97.44% |
| [Services/SupportTicketRules.cs](../../../backend/Services/SupportTicketRules.cs) | 3/3 | 100.00% | 24/24 | 100.00% |
| [Services/TokenService.cs](../../../backend/Services/TokenService.cs) | 29/29 | 100.00% | 4/4 | 100.00% |
