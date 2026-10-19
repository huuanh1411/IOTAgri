# Frontend testing

Frontend có hai lớp kiểm thử: Flutter trong [`test/`](test/) và trình duyệt Playwright trong [`e2e/`](e2e/). Cả hai cần được chạy cùng mã nguồn ứng dụng tương ứng; nhánh `Test` chỉ lưu phần kiểm thử.

## Flutter

Dùng Flutter SDK có Dart tương thích với `environment.sdk` trong `frontend/pubspec.yaml` của checkout ứng dụng. Từ gốc repo:

```powershell
cd frontend
flutter pub get
flutter test
```

Chạy một file khi cần khoanh vùng:

```powershell
flutter test test/api_contract_models_test.dart
```

Một số test nhắm riêng nền tảng web. Khi chạy ca web, dùng Chrome và kiểm tra cấu hình của test:

```powershell
flutter test --platform chrome test/add_device_web_test.dart
```

## Danh mục

| Nhóm | File tiêu biểu trong `test/` |
| --- | --- |
| Model và API contract | `api_contract_models_test.dart`, `live_sensor_contract_test.dart` |
| Repository và provider | `dio_repositories_test.dart`, `alert_center_provider_test.dart`, `active_plant_controller_test.dart` |
| Thiết bị và bơm | `add_device_test.dart`, `device_settings_test.dart`, `pump_control_test.dart` |
| Luồng và widget | `history_flow_test.dart`, `widget_test.dart`, `phase13_integration_flow_test.dart` |
| Trạng thái, accessibility, chuyển động | `phase12_global_states_a11y_test.dart`, `phase13_widget_variants_test.dart`, `app_motion_test.dart` |

Danh mục này nhóm theo mục đích để tra cứu, không phải số lượng ca đã PASS. Giữ tên file hiện tại để bảo toàn import và lệnh chạy từng test.

## Web E2E và bằng chứng

Xem [hướng dẫn Playwright](e2e/README.md) để cài dependencies, chuẩn bị FE/BE và chạy 33 ca trên ba viewport.

Nhánh hiện chưa lưu báo cáo thực thi Flutter/E2E. Quy ước lưu kết quả mới nằm trong [`testing/reports/frontend/`](../testing/reports/frontend/README.md).
