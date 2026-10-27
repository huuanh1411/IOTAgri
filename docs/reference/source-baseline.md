# Source baseline và phương pháp đối chiếu

[← Mục lục](../README.md)

- Ngày tài liệu: **27/10/2026** (Asia/Saigon).
- Source đã commit: `ac9fc42b0b619af5bff8b4961971207321d3f966` (commit local), nhánh `main` tại workspace.
- Tài liệu cũ: [`99d9422`](https://github.com/huuanh1411/IOTAgri/tree/99d9422), `origin/Docs`, ngày 24/10/2026. Đã fetch trước khi cập nhật.
- Nhánh Docs chỉ có tài liệu. Sau khi fetch main, origin/main vẫn ở `2a48d70781154aa1b565f8d00a523320c41adc5b`; baseline local có 10 commit mới hơn và chưa nằm trong remote refs đã kiểm tra. Vì vậy tài liệu dùng liên kết đến manifest đường dẫn/hash bên dưới thay cho URL GitHub đến commit chưa được công bố. Không đẩy main trong công việc này.
- Source hiện tại bao gồm thay đổi workspace chưa commit. Không commit/chuyển nhánh/ghi đè các thay đổi source đó trong công việc tài liệu.

## Phương pháp

Đã thử `graphify query`; CLI không có trong PATH và Python mặc định thiếu NetworkX. Đã đọc graph.json có sẵn bằng Python chuẩn, mở rộng từ khóa theo vocabulary và duyệt BFS bằng adjacency map (167 node trong phạm vi truy vấn). Graph chỉ dùng định hướng; endpoint/model/snapshot/firmware hiện tại là bằng chứng quyết định. Không rebuild graph hoặc sửa code trong đợt tài liệu này.

Sau đó kiểm tra khai báo route, RequireAuthorization, OwnerId, model và OnModelCreating, migration snapshot, xử lý lệnh/ACK, scheduler, khôi phục mật khẩu và dữ liệu mock/cục bộ trên Flutter. Đây là phân tích tĩnh; chưa đọc schema DB đang chạy, kiểm thử tải, gửi email thực hoặc điều khiển relay thật.

## Nguồn chính

Manifest ghi đường dẫn và SHA-256 của tệp workspace đã khảo sát. Đây là tham chiếu truy vết cục bộ, không phải link tải source. Hash giúp phát hiện sai khác khi đối chiếu trên máy có source. Nếu công bố baseline source sau này, có thể đổi sang URL commit tương ứng.

<a id="backend-program-cs"></a>

- `backend/Program.cs` — SHA-256 `6376b8a01ddb107462de0bccc29d26e565eb27c56aa11759da54125e562d936f`
<a id="backend-data-applicationdbcontext-cs"></a>

- `backend/Data/ApplicationDbContext.cs` — SHA-256 `53d4a02ee59fe9966fe11646ac8462351fadad514d8321a4c5fb5388f3496a84`
<a id="backend-migrations-applicationdbcontextmodelsnapshot-cs"></a>

- `backend/Migrations/ApplicationDbContextModelSnapshot.cs` — SHA-256 `03e56697d4e0d1112dec10b4be38cab8ea8d49324e4a3b2d4817b3b1931da859`
<a id="backend-endpoints-adminendpoints-cs"></a>

- `backend/Endpoints/AdminEndpoints.cs` — SHA-256 `4287c05438569f53b37b372978a1a6fa69d701402fc4e01430a7280faf2f0ab0`
<a id="backend-endpoints-authendpoints-cs"></a>

- `backend/Endpoints/AuthEndpoints.cs` — SHA-256 `81423f47fd096ca22c88ba0dedefb3d931dd272357025fb86145cc9fc813da2e`
<a id="backend-endpoints-dashboardendpoints-cs"></a>

- `backend/Endpoints/DashboardEndpoints.cs` — SHA-256 `2d63faa1f86a2db5514e2b0447a20004ab728d50771ac911fc049f5676532f80`
<a id="backend-endpoints-deviceendpoints-cs"></a>

- `backend/Endpoints/DeviceEndpoints.cs` — SHA-256 `d43674f7a296bb4ab9f5e90f11089de8e6c5ff9f245a28238d47d5384f412c4f`
<a id="backend-endpoints-deviceprovisioningendpoints-cs"></a>

- `backend/Endpoints/DeviceProvisioningEndpoints.cs` — SHA-256 `4ae91e0127fe61720b36c8b564d1713141579298219f4ae2ba3c67db29eb29a9`
<a id="backend-endpoints-sensorendpoints-cs"></a>

- `backend/Endpoints/SensorEndpoints.cs` — SHA-256 `e8858204022d4ac03d91967233b19286216902f63322954b2350a746cab395aa`
<a id="backend-endpoints-ticketendpoints-cs"></a>

- `backend/Endpoints/TicketEndpoints.cs` — SHA-256 `345e59716bd74e927afc6dcea7099ebb36e0a1cc2d426613541f8bbd2b01f8d1`
<a id="backend-services-tokenservice-cs"></a>

- `backend/Services/TokenService.cs` — SHA-256 `030cde918f8bfc693bf16c139c91a37acc0dff26a108e7ac698fe6c21ea6e52d`
<a id="backend-services-devicealertrules-cs"></a>

- `backend/Services/DeviceAlertRules.cs` — SHA-256 `2516d1e8944750b27ff729f8814405f84b029e84936f05e913a58278f3424baa`
<a id="backend-services-pumpschedulerules-cs"></a>

- `backend/Services/PumpScheduleRules.cs` — SHA-256 `77d538c9f9b9a9d69316bc4b849c7ac593c4f4d87cc0596099e423a26c4285df`
<a id="backend-services-pumpscheduledispatchservice-cs"></a>

- `backend/Services/PumpScheduleDispatchService.cs` — SHA-256 `c89abaf468a64a4e1a50f8a80acbe7819e27126c0df4f57d80702a472972ebb2`
<a id="backend-services-lightschedulerules-cs"></a>

- `backend/Services/LightScheduleRules.cs` — SHA-256 `daaa3cef506d644ed3126570df5cdd5a4fb4e53ce2cea9e81ff05cbac6f927fb`
<a id="backend-services-lightscheduledispatchservice-cs"></a>

- `backend/Services/LightScheduleDispatchService.cs` — SHA-256 `2580a352f16e118f851d9b81f35b27e55560c9fc10055b30c49cd6d2d51f87c9`
<a id="backend-services-mqttingestionservice-cs"></a>

- `backend/Services/MqttIngestionService.cs` — SHA-256 `c3dc5b32bea79b5e67f9359e018f3520b80a28edc70e7ccafde14f48114f95f5`
<a id="backend-services-mqttbrokeradminservice-cs"></a>

- `backend/Services/MqttBrokerAdminService.cs` — SHA-256 `87270b28115224b254443275ceaadc35ab3872e8329bacf85545ca2064f255a9`
<a id="backend-services-passwordresetnotificationsender-cs"></a>

- `backend/Services/PasswordResetNotificationSender.cs` — SHA-256 `c70e84dc21eeffee326164ac36077040242abcaa754af5fe1d947cb7341dd0e8`
<a id="backend-services-webapplicationsecurityextensions-cs"></a>

- `backend/Services/WebApplicationSecurityExtensions.cs` — SHA-256 `6b01619b5546d9b1f787119c2c18535d5146cd4ad41962606b2ae3fd20f1d094`
<a id="backend-services-dataprotectionextensions-cs"></a>

- `backend/Services/DataProtectionExtensions.cs` — SHA-256 `c8b65049e92a308a54e298c592f6a462d6f97453070388a2c4de5f0ce905111b`
<a id="backend-services-adminrolerules-cs"></a>

- `backend/Services/AdminRoleRules.cs` — SHA-256 `30d241cfd57e6f93cf740fd08563368ce66b4b50540b93bf8e41cfcf25583209`
<a id="backend-services-supportticketrules-cs"></a>

- `backend/Services/SupportTicketRules.cs` — SHA-256 `3ddbb873cb61032f36dbacee3a5ff4ae61faec12b1762dd56ff199558d255119`
<a id="backend-models-devicepresence-cs"></a>

- `backend/Models/DevicePresence.cs` — SHA-256 `35fda3f469f900ac7d757427a68ac2f35cbf50565ef960e5ef03fdea4493dfcf`
<a id="backend-appsettings-json"></a>

- `backend/appsettings.json` — SHA-256 `6f41a6a877858236c5f15ca308bad4f3edb6db25ddbf69af154c75d2e3000eb0`
<a id="frontend-lib-providers-data-providers-dart"></a>

- `frontend/lib/providers/data_providers.dart` — SHA-256 `4279a656f3a17f30f9c9f785908d0eca6f7530932222188e098ade3181ce1c1a`
<a id="frontend-lib-repositories-plant-repository-dart"></a>

- `frontend/lib/repositories/plant_repository.dart` — SHA-256 `5e5a5e3a212aad05c0969d266954dad6070eb6cad57e2a01a010da54811c1710`
<a id="frontend-lib-screens-harvest-screen-dart"></a>

- `frontend/lib/screens/harvest_screen.dart` — SHA-256 `ac96cfe0593a2bfdb0e43d10e9ced6ea09f14b9f528d6d8e31fcf777ef9c6de1`
<a id="frontend-lib-data-mock-data-dart"></a>

- `frontend/lib/data/mock_data.dart` — SHA-256 `acdfd203a79564043bc948c53e1ebf0421d1511c54733c847250a41dcb0663a5`
<a id="frontend-lib-services-notification-service-dart"></a>

- `frontend/lib/services/notification_service.dart` — SHA-256 `274cb4b98438126fb28131655f88fb6400fe02e6c2cfc9bcad5fab301ee25efa`
<a id="firmware-esp32devicesetup-esp32devicesetup-ino"></a>

- `firmware/ESP32DeviceSetup/ESP32DeviceSetup.ino` — SHA-256 `20a5b116914357153c4bbb4f03a3660478a39db3c8fe6ffd32f200d4aa9cf74a`
<a id="compose-production-yaml"></a>

- `compose.production.yaml` — SHA-256 `c974058fc4de98f1abc05b5ce57b07d2971d37684a6d35bfaf3c6be41b5aae62`

## Thay đổi workspace ảnh hưởng cách diễn giải

Các tệp dưới đây được đọc tại workspace; hash SHA-256 ghi lại phiên bản byte thực tế đã khảo sát. Commit local ở trên không chứa các dòng đang sửa; hash giúp phân biệt hai phiên bản.

| Tệp | SHA-256 của bản workspace | Ảnh hưởng tài liệu |
| --- | --- | --- |
| `frontend/lib/providers/data_providers.dart` | `4279a656f3a17f30f9c9f785908d0eca6f7530932222188e098ade3181ce1c1a` | selectedDeviceId/activeDevice; dashboard polling 10 giây; cục bộ cây |
| `frontend/lib/screens/home_screen.dart` | `61ac5450faaee6d32a6ae4aef346e3fdbc09f45eb16e9dcebb20610c22c47078` | Dashboard theo dữ liệu thiết bị hiện tại |
| `frontend/lib/screens/sensor_detail_screen.dart` | `097d2ff16cc9fcf4efd8efe2cfcac702bcb01053496a51d107e154f418c2380d` | Đồng bộ thiết bị khi xem chi tiết |
| `frontend/lib/router.dart` | `a0586e641e12df02945587266ba3d1caaf0ca7741c466ea4751ee66dea3efd66` | Tham số điều hướng chi tiết cảm biến |
| `frontend/lib/cupertino/devices/cupertino_devices_screen.dart` | `d9d9ef937b87079814ac4625029a512e71b368dbd0823546ed35074dca63b21f` | Luồng mở thiết bị trên giao diện Cupertino |
| `tools/device-simulator.sh` | `50d2ea49370626bb38c802b026cd5728be78018ba6d19ee9e65c7cdd7daf258b` | Simulator chỉ là công cụ kiểm thử, không thay thế firmware thật |

Các thay đổi bản dịch, test và tệp demo chưa commit khác không được đưa vào nhánh Docs. SRS ghi rõ tính chất workspace của hành vi UI; nếu source thay đổi tiếp cần kiểm tra lại các hash và cập nhật baseline.

## Quy tắc bảo trì

1. Chốt commit nguồn mới và xác định thay đổi workspace nếu có.
2. Đọc route/model/migration và hành vi thực tế trước khi thay yêu cầu hoặc ERD.
3. Cập nhật FR/UC và báo cáo đối chiếu cùng nhau; tránh mô tả chức năng dự kiến như đã có.
4. Khi chỉnh `.mmd`, đồng bộ block trong project-diagrams.md và Use Case; kiểm tra link và sơ đồ.
5. Khi thay đổi code, chạy `graphify update .` theo AGENTS.md; sửa tài liệu thuần túy không tạo migration và không cần cập nhật graph code.
