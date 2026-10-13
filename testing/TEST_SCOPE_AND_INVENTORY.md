# Test scope and backend inventory

Revision `318fca181741c95e73b56808ebe04a65a3ee0466` plus uncommitted QA changes. All 98 production source/config files retain their initial hashes. The original 14 Antigravity files and all 33 original root test files (32 sources + csproj) are retained.

## Architecture and tools

C# / ASP.NET Core 10 Minimal APIs; handlers use ApplicationDbContext directly. PostgreSQL/Npgsql EF Core and ASP.NET Identity provide persistence; JWT, MQTT ingestion and pump scheduling provide authentication/background behavior. No separate Controller/Repository layer exists.

Existing xUnit 2.9.3, Test SDK 17.14.1 and Visual Studio runner 3.1.4 retained. Test-only additions: Moq 4.20.72, Coverlet collector 6.0.4, Microsoft.AspNetCore.TestHost 10.0.11. No production dependency, runtime configuration or CI edit.

## Review scope and verification limits

All backend directories inventoried. Handwritten endpoint, service, data-model, DTO and Program.cs behavior inspected. Migration Up operations now execute on fresh isolated PostgreSQL; rollback is tested and fails at AddAdminManagement (BE-002). Generated Designer/snapshot files remain inventoried rather than exhaustively reviewed line by line.

Frontend, firmware and physical devices excluded. Production Program.cs is not executed: it migrates/seeds and starts live hosted jobs. HTTP component tests reconstruct its security/CORS/rate-limit setup and use real route mappings, Identity and JWT with fresh request scopes. This does not establish deployment/startup wiring.

No shared Compose service/database/broker is used. PostgresTestFixture creates loopback-only, uniquely named/labelled disposable PostgreSQL containers, a fresh qa_GUID database per case, and verifies name/label before removing only its owned container and anonymous volumes. No externally supplied connection strings, .env, host mounts or persistent volumes.

Plain DTO/entity accessors without behavior are not given artificial coverage tests. Explicit annotation tests validate record constructor attributes; actual blank device name HTTP behavior is tested separately (BE-004).

## Component verification map

| Area | Executed scope | Remaining limitations |
| --- | --- | --- |
| Auth/profile/JWT | Claims/signatures/expiry, profile rules, login lock regression via mock and real Identity HTTP, persisted refresh rotation/reuse and logout | Locked refresh/session policy, exhaustive failed-token branches and production startup |
| Admin/bootstrap | Roles/profile/filter decisions, seed/error behavior, admin HTTP 401/403/200, persisted overview/CSV/defaults/audit | Concurrent admin-demotion/lock races and full report/filter matrix |
| Devices/provisioning | CRUD ownership, required-name regression, real one-use claim and concurrent claim contention | Broader error/ownership matrix and hardware provisioning |
| Sensors/dashboard | JSON/empty series, real PostgreSQL hourly aggregates/median and owner dashboard/latest alert projections | Daily median/filter/extreme ranges not exhaustive |
| Pumps/schedules | Duration/history/JSON/DST/windows, persisted history/serializable schedule CRUD/overlap; claim dedup and disconnected publish pending retry | Connected broker delivery, successful timer/reconnect/retry transport and schedule/admin concurrent mutation races |
| Alerts/MQTT | Threshold/mapper rules, settings/history and filtered unique constraints; persisted MQTT reading alert trigger/resolve and failed acknowledgement adapter | Actual broker connection/reconnect/transport and complete consumer payload matrix |
| Tickets | Rules, create/status/priority/search/audit and reply regressions via direct handler plus fresh HTTP request scope | Reply path fails; later assertions in that failing compound case are not reported as passed |
| Database/migrations | Real PostgreSQL constraints, fresh 14-migration Up chain and pending-model check; attempted full Down regression | Down chain blocked by BE-002; exhaustive constraint/FK/SQL branch matrix and generated-source review |
| HTTP middleware | JWT authorization/invalid token, CORS allowed/unknown preflight and claim rate limiter | Production Program.cs startup, deployment HTTPS, generic exception handling and full middleware matrix |

## Complete protected-file inventory

| Source/config file | Review classification |
| --- | --- |
| [backend/appsettings.Development.json](../backend/appsettings.Development.json) | Read-only runtime/build inventory, unchanged; actual runtime secrets not copied. |
| [backend/appsettings.json](../backend/appsettings.json) | Read-only runtime/build inventory, unchanged; actual runtime secrets not copied. |
| [backend/IOTAgriBackend.csproj](../backend/IOTAgriBackend.csproj) | Read-only runtime/build inventory, unchanged; actual runtime secrets not copied. |
| [backend/IOTAgriBackend.http](../backend/IOTAgriBackend.http) | Read-only runtime/build inventory, unchanged; actual runtime secrets not copied. |
| [backend/Program.cs](../backend/Program.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Data/AdminBootstrapSettings.cs](../backend/Data/AdminBootstrapSettings.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Data/ApplicationDbContext.cs](../backend/Data/ApplicationDbContext.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Data/RoleSeeder.cs](../backend/Data/RoleSeeder.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Admin/AdminAuditLogResponse.cs](../backend/Dtos/Admin/AdminAuditLogResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Admin/AdminDeviceResponse.cs](../backend/Dtos/Admin/AdminDeviceResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Admin/AdminSystemContracts.cs](../backend/Dtos/Admin/AdminSystemContracts.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Admin/AdminUserResponse.cs](../backend/Dtos/Admin/AdminUserResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Admin/UpdateDeviceOwnerRequest.cs](../backend/Dtos/Admin/UpdateDeviceOwnerRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Admin/UpdateUserLockRequest.cs](../backend/Dtos/Admin/UpdateUserLockRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Admin/UpdateUserRoleRequest.cs](../backend/Dtos/Admin/UpdateUserRoleRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Alerts/DeviceAlertContracts.cs](../backend/Dtos/Alerts/DeviceAlertContracts.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Auth/AuthResponse.cs](../backend/Dtos/Auth/AuthResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Auth/LoginRequest.cs](../backend/Dtos/Auth/LoginRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Auth/RefreshRequest.cs](../backend/Dtos/Auth/RefreshRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Auth/RegisterRequest.cs](../backend/Dtos/Auth/RegisterRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Auth/UpdateProfileRequest.cs](../backend/Dtos/Auth/UpdateProfileRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Auth/UserProfileResponse.cs](../backend/Dtos/Auth/UserProfileResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Auth/UserSummaryResponse.cs](../backend/Dtos/Auth/UserSummaryResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Dashboard/AggregatedReadingBucket.cs](../backend/Dtos/Dashboard/AggregatedReadingBucket.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Dashboard/DeviceOverviewResponse.cs](../backend/Dtos/Dashboard/DeviceOverviewResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Devices/ClaimDeviceRequest.cs](../backend/Dtos/Devices/ClaimDeviceRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Devices/ClaimDeviceResponse.cs](../backend/Dtos/Devices/ClaimDeviceResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Devices/CreateDeviceRequest.cs](../backend/Dtos/Devices/CreateDeviceRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Devices/CreateProvisioningCodeResponse.cs](../backend/Dtos/Devices/CreateProvisioningCodeResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Devices/DeviceResponse.cs](../backend/Dtos/Devices/DeviceResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Devices/UpdateDeviceRequest.cs](../backend/Dtos/Devices/UpdateDeviceRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Pumps/PumpCommandHistoryQuery.cs](../backend/Dtos/Pumps/PumpCommandHistoryQuery.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Pumps/PumpCommandHistoryResponse.cs](../backend/Dtos/Pumps/PumpCommandHistoryResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Pumps/PumpCommandRequest.cs](../backend/Dtos/Pumps/PumpCommandRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Pumps/PumpCommandResponse.cs](../backend/Dtos/Pumps/PumpCommandResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Pumps/PumpMqttMessages.cs](../backend/Dtos/Pumps/PumpMqttMessages.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Pumps/PumpScheduleContracts.cs](../backend/Dtos/Pumps/PumpScheduleContracts.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Sensors/SensorMedianBucket.cs](../backend/Dtos/Sensors/SensorMedianBucket.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Sensors/SensorReadingRequest.cs](../backend/Dtos/Sensors/SensorReadingRequest.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Sensors/SensorReadingResponse.cs](../backend/Dtos/Sensors/SensorReadingResponse.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Dtos/Tickets/SupportTicketContracts.cs](../backend/Dtos/Tickets/SupportTicketContracts.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Endpoints/AdminEndpoints.cs](../backend/Endpoints/AdminEndpoints.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Endpoints/AuthEndpoints.cs](../backend/Endpoints/AuthEndpoints.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Endpoints/DashboardEndpoints.cs](../backend/Endpoints/DashboardEndpoints.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Endpoints/DeviceEndpoints.cs](../backend/Endpoints/DeviceEndpoints.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Endpoints/DeviceProvisioningEndpoints.cs](../backend/Endpoints/DeviceProvisioningEndpoints.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Endpoints/SensorEndpoints.cs](../backend/Endpoints/SensorEndpoints.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Endpoints/TicketEndpoints.cs](../backend/Endpoints/TicketEndpoints.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Migrations/20260907134344_InitialIdentity.cs](../backend/Migrations/20260907134344_InitialIdentity.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260907134344_InitialIdentity.Designer.cs](../backend/Migrations/20260907134344_InitialIdentity.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260908130543_AddDevices.cs](../backend/Migrations/20260908130543_AddDevices.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260908130543_AddDevices.Designer.cs](../backend/Migrations/20260908130543_AddDevices.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260908131914_AddSensorReadings.cs](../backend/Migrations/20260908131914_AddSensorReadings.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260908131914_AddSensorReadings.Designer.cs](../backend/Migrations/20260908131914_AddSensorReadings.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260915142536_AddDeviceProvisioning.cs](../backend/Migrations/20260915142536_AddDeviceProvisioning.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260915142536_AddDeviceProvisioning.Designer.cs](../backend/Migrations/20260915142536_AddDeviceProvisioning.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260917105809_AddPumpControl.cs](../backend/Migrations/20260917105809_AddPumpControl.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260917105809_AddPumpControl.Designer.cs](../backend/Migrations/20260917105809_AddPumpControl.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260921104101_AddAdminManagement.cs](../backend/Migrations/20260921104101_AddAdminManagement.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260921104101_AddAdminManagement.Designer.cs](../backend/Migrations/20260921104101_AddAdminManagement.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260922132245_AddDeviceAlerts.cs](../backend/Migrations/20260922132245_AddDeviceAlerts.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260922132245_AddDeviceAlerts.Designer.cs](../backend/Migrations/20260922132245_AddDeviceAlerts.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260923144530_AddPumpSchedules.cs](../backend/Migrations/20260923144530_AddPumpSchedules.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260923144530_AddPumpSchedules.Designer.cs](../backend/Migrations/20260923144530_AddPumpSchedules.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260923150119_AddPumpScheduleOccurrences.cs](../backend/Migrations/20260923150119_AddPumpScheduleOccurrences.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20260923150119_AddPumpScheduleOccurrences.Designer.cs](../backend/Migrations/20260923150119_AddPumpScheduleOccurrences.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261001125009_AddLuxToSensorReadings.cs](../backend/Migrations/20261001125009_AddLuxToSensorReadings.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261001125009_AddLuxToSensorReadings.Designer.cs](../backend/Migrations/20261001125009_AddLuxToSensorReadings.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261006133045_AddSupportTickets.cs](../backend/Migrations/20261006133045_AddSupportTickets.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261006133045_AddSupportTickets.Designer.cs](../backend/Migrations/20261006133045_AddSupportTickets.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261006142630_AddSystemAlertDefaults.cs](../backend/Migrations/20261006142630_AddSystemAlertDefaults.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261006142630_AddSystemAlertDefaults.Designer.cs](../backend/Migrations/20261006142630_AddSystemAlertDefaults.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261007153250_AddPumpScheduleWindow.cs](../backend/Migrations/20261007153250_AddPumpScheduleWindow.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261007153250_AddPumpScheduleWindow.Designer.cs](../backend/Migrations/20261007153250_AddPumpScheduleWindow.Designer.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/20261009120000_AddSolutionTemperatureToSensorReadings.cs](../backend/Migrations/20261009120000_AddSolutionTemperatureToSensorReadings.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Migrations/ApplicationDbContextModelSnapshot.cs](../backend/Migrations/ApplicationDbContextModelSnapshot.cs) | Schema/version inventoried; full Up chain executed; Down chain fails at BE-002; generated Designer/snapshot not exhaustive line review. |
| [backend/Models/AdminAuditLog.cs](../backend/Models/AdminAuditLog.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/ApplicationUser.cs](../backend/Models/ApplicationUser.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/Device.cs](../backend/Models/Device.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/DeviceAlert.cs](../backend/Models/DeviceAlert.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/DevicePresence.cs](../backend/Models/DevicePresence.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/PumpCommand.cs](../backend/Models/PumpCommand.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/PumpSchedule.cs](../backend/Models/PumpSchedule.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/PumpScheduleOccurrence.cs](../backend/Models/PumpScheduleOccurrence.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/RefreshToken.cs](../backend/Models/RefreshToken.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/SensorReading.cs](../backend/Models/SensorReading.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/SupportTicket.cs](../backend/Models/SupportTicket.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Models/SystemAlertDefaults.cs](../backend/Models/SystemAlertDefaults.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Properties/launchSettings.json](../backend/Properties/launchSettings.json) | Read-only runtime/build inventory, unchanged; actual runtime secrets not copied. |
| [backend/Services/AdminRoleRules.cs](../backend/Services/AdminRoleRules.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Services/DeviceAlertRules.cs](../backend/Services/DeviceAlertRules.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Services/MqttIngestionService.cs](../backend/Services/MqttIngestionService.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Services/ProfileRules.cs](../backend/Services/ProfileRules.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Services/ProvisioningCode.cs](../backend/Services/ProvisioningCode.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Services/PumpScheduleDispatchService.cs](../backend/Services/PumpScheduleDispatchService.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Services/PumpScheduleRules.cs](../backend/Services/PumpScheduleRules.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Services/SupportTicketRules.cs](../backend/Services/SupportTicketRules.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |
| [backend/Services/TokenService.cs](../backend/Services/TokenService.cs) | Handwritten behavior/contracts inspected; actual tested portions and gaps mapped above. |

## Original files intentionally updated

- `backend/tests/DeviceAlertResponseTests.cs`: test-only correction/dependency configuration; details in defects/strategy.
- `backend/tests/DevicePresenceExtendedTests.cs`: test-only correction/dependency configuration; details in defects/strategy.
- `backend/tests/IOTAgriBackend.Tests.csproj`: test-only correction/dependency configuration; details in defects/strategy.
- `backend/tests/ProvisioningCodeExtendedTests.cs`: test-only correction/dependency configuration; details in defects/strategy.
- `backend/tests/ProvisioningCodeTests.cs`: test-only correction/dependency configuration; details in defects/strategy.
- `backend/tests/PumpCommandHistoryQueryExtendedTests.cs`: test-only correction/dependency configuration; details in defects/strategy.
- `backend/tests/PumpMqttMessageExtendedTests.cs`: test-only correction/dependency configuration; details in defects/strategy.
- `backend/tests/PumpScheduleRulesExtendedTests.cs`: test-only correction/dependency configuration; details in defects/strategy.

## Executable test inventory

44 source files / 212 definitions / 345 executed cases: 319 original isolated cases plus 26 integration cases.

| Test file | Executed cases |
| --- | --- |
| [backend/tests/AdminBootstrapSettingsTests.cs](../backend/tests/AdminBootstrapSettingsTests.cs) | 4 |
| [backend/tests/AdminEndpointMappingTests.cs](../backend/tests/AdminEndpointMappingTests.cs) | 1 |
| [backend/tests/AdminRoleRulesExtendedTests.cs](../backend/tests/AdminRoleRulesExtendedTests.cs) | 16 |
| [backend/tests/AdminRoleRulesTests.cs](../backend/tests/AdminRoleRulesTests.cs) | 8 |
| [backend/tests/AuthHandlerTests.cs](../backend/tests/AuthHandlerTests.cs) | 5 |
| [backend/tests/BackendEndpointMetadataTests.cs](../backend/tests/BackendEndpointMetadataTests.cs) | 1 |
| [backend/tests/BackgroundServiceGuardTests.cs](../backend/tests/BackgroundServiceGuardTests.cs) | 5 |
| [backend/tests/DatabaseModelContractTests.cs](../backend/tests/DatabaseModelContractTests.cs) | 10 |
| [backend/tests/DeviceAlertHistoryQueryExtendedTests.cs](../backend/tests/DeviceAlertHistoryQueryExtendedTests.cs) | 12 |
| [backend/tests/DeviceAlertHistoryQueryTests.cs](../backend/tests/DeviceAlertHistoryQueryTests.cs) | 3 |
| [backend/tests/DeviceAlertResponseTests.cs](../backend/tests/DeviceAlertResponseTests.cs) | 2 |
| [backend/tests/DeviceAlertRulesExtendedTests.cs](../backend/tests/DeviceAlertRulesExtendedTests.cs) | 13 |
| [backend/tests/DeviceAlertRulesTests.cs](../backend/tests/DeviceAlertRulesTests.cs) | 6 |
| [backend/tests/DeviceAlertSettingsRequestTests.cs](../backend/tests/DeviceAlertSettingsRequestTests.cs) | 2 |
| [backend/tests/DevicePresenceExtendedTests.cs](../backend/tests/DevicePresenceExtendedTests.cs) | 6 |
| [backend/tests/DevicePresenceTests.cs](../backend/tests/DevicePresenceTests.cs) | 1 |
| [backend/tests/DtoValidationContractTests.cs](../backend/tests/DtoValidationContractTests.cs) | 10 |
| [backend/tests/EndpointGuardTests.cs](../backend/tests/EndpointGuardTests.cs) | 43 |
| [backend/tests/HttpIntegrationTests.cs](../backend/tests/HttpIntegrationTests.cs) | 6 |
| [backend/tests/PostgresIntegrationTests.cs](../backend/tests/PostgresIntegrationTests.cs) | 20 |
| [backend/tests/ProfileRulesExtendedTests.cs](../backend/tests/ProfileRulesExtendedTests.cs) | 13 |
| [backend/tests/ProfileRulesTests.cs](../backend/tests/ProfileRulesTests.cs) | 13 |
| [backend/tests/ProvisioningCodeExtendedTests.cs](../backend/tests/ProvisioningCodeExtendedTests.cs) | 7 |
| [backend/tests/ProvisioningCodeTests.cs](../backend/tests/ProvisioningCodeTests.cs) | 2 |
| [backend/tests/PumpCommandHistoryQueryExtendedTests.cs](../backend/tests/PumpCommandHistoryQueryExtendedTests.cs) | 11 |
| [backend/tests/PumpCommandHistoryQueryTests.cs](../backend/tests/PumpCommandHistoryQueryTests.cs) | 2 |
| [backend/tests/PumpCommandRequestExtendedTests.cs](../backend/tests/PumpCommandRequestExtendedTests.cs) | 6 |
| [backend/tests/PumpCommandRequestTests.cs](../backend/tests/PumpCommandRequestTests.cs) | 2 |
| [backend/tests/PumpMqttMessageExtendedTests.cs](../backend/tests/PumpMqttMessageExtendedTests.cs) | 9 |
| [backend/tests/PumpMqttMessageTests.cs](../backend/tests/PumpMqttMessageTests.cs) | 2 |
| [backend/tests/PumpScheduleBoundaryTests.cs](../backend/tests/PumpScheduleBoundaryTests.cs) | 6 |
| [backend/tests/PumpScheduleRulesExtendedTests.cs](../backend/tests/PumpScheduleRulesExtendedTests.cs) | 24 |
| [backend/tests/PumpScheduleRulesTests.cs](../backend/tests/PumpScheduleRulesTests.cs) | 6 |
| [backend/tests/PumpSchemaTests.cs](../backend/tests/PumpSchemaTests.cs) | 1 |
| [backend/tests/RefreshTokenStateTests.cs](../backend/tests/RefreshTokenStateTests.cs) | 4 |
| [backend/tests/SeederBehaviorTests.cs](../backend/tests/SeederBehaviorTests.cs) | 10 |
| [backend/tests/SensorMedianBucketExtendedTests.cs](../backend/tests/SensorMedianBucketExtendedTests.cs) | 4 |
| [backend/tests/SensorMedianBucketTests.cs](../backend/tests/SensorMedianBucketTests.cs) | 2 |
| [backend/tests/SensorReadingContractTests.cs](../backend/tests/SensorReadingContractTests.cs) | 1 |
| [backend/tests/SupportTicketRulesExtendedTests.cs](../backend/tests/SupportTicketRulesExtendedTests.cs) | 19 |
| [backend/tests/SupportTicketRulesTests.cs](../backend/tests/SupportTicketRulesTests.cs) | 8 |
| [backend/tests/TicketEndpointMappingTests.cs](../backend/tests/TicketEndpointMappingTests.cs) | 1 |
| [backend/tests/TokenServiceTests.cs](../backend/tests/TokenServiceTests.cs) | 6 |
| [backend/tests/UpdateSystemAlertDefaultsRequestTests.cs](../backend/tests/UpdateSystemAlertDefaultsRequestTests.cs) | 12 |

Test-only helpers: BackendTestDoubles.cs, PostgresTestFixture.cs, BackendHttpTestHost.cs under backend/tests/TestSupport. Runner/record generation/graph wrapper under testing/.
