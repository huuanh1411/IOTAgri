# Flutter · Báo cáo kiểm thử

[← Tổng quan frontend](../README.md) · [Báo cáo văn bản gốc](BAO_CAO_TEST_FE.txt) · [JSON events](flutter-test.jsonl)

**Phiên đã lưu ngày 18/10/2026 · 133 PASS · 0 FAIL · 0 SKIP · exit code 0**

| Phạm vi | Kết quả | Cách hiểu |
| --- | --- | --- |
| Ca có assertion dữ liệu/hành vi | 76 PASS | Có kiểm tra dữ liệu hoặc hành vi trong suite hiện có |
| Placeholder | 57 PASS | Chưa chứng minh luồng QR/BLE, Wi-Fi hoặc điều khiển bơm hoạt động |
| Flutter Chrome | ⏸ CHƯA KIỂM CHỨNG | Kẹt loading khoảng 3 phút, chủ động dừng; chưa có assertion nghiệp vụ |
| Dart analyzer | ⚠ 1 warning, 0 error | `unused_local_variable` trong `api_service.dart` |

> Số PASS gồm cả placeholder. Đây không phải tỷ lệ code coverage hoặc xác nhận đầy đủ chức năng ứng dụng.

## Kết quả theo file

| File test | PASS | Có assertion | Placeholder |
| --- | ---: | ---: | ---: |
| [active_plant_controller_test.dart](../../../frontend/test/active_plant_controller_test.dart) | 3 | 3 | 0 |
| [add_device_test.dart](../../../frontend/test/add_device_test.dart) | 35 | 0 | 35 |
| [alert_center_provider_test.dart](../../../frontend/test/alert_center_provider_test.dart) | 6 | 6 | 0 |
| [api_contract_models_test.dart](../../../frontend/test/api_contract_models_test.dart) | 2 | 2 | 0 |
| [app_motion_test.dart](../../../frontend/test/app_motion_test.dart) | 3 | 3 | 0 |
| [device_settings_test.dart](../../../frontend/test/device_settings_test.dart) | 5 | 5 | 0 |
| [dio_repositories_test.dart](../../../frontend/test/dio_repositories_test.dart) | 4 | 4 | 0 |
| [history_flow_test.dart](../../../frontend/test/history_flow_test.dart) | 5 | 5 | 0 |
| [live_sensor_contract_test.dart](../../../frontend/test/live_sensor_contract_test.dart) | 1 | 1 | 0 |
| [phase11_account_support_test.dart](../../../frontend/test/phase11_account_support_test.dart) | 6 | 6 | 0 |
| [phase12_global_states_a11y_test.dart](../../../frontend/test/phase12_global_states_a11y_test.dart) | 6 | 6 | 0 |
| [phase13_integration_flow_test.dart](../../../frontend/test/phase13_integration_flow_test.dart) | 1 | 1 | 0 |
| [phase13_widget_variants_test.dart](../../../frontend/test/phase13_widget_variants_test.dart) | 11 | 11 | 0 |
| [pump_control_test.dart](../../../frontend/test/pump_control_test.dart) | 22 | 0 | 22 |
| [water_pump_control_panel_test.dart](../../../frontend/test/water_pump_control_panel_test.dart) | 3 | 3 | 0 |
| [widget_test.dart](../../../frontend/test/widget_test.dart) | 20 | 20 | 0 |

## Danh sách từng ca

Mở từng file để đọc tên ca và phân biệt placeholder.

<details>
<summary><strong>active_plant_controller_test.dart</strong> · 3 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| each plant replaces the active cycle with configured data | ✅ PASS | Có assertion |
| restores the persisted plant and original growing date | ✅ PASS | Có assertion |
| growth progress is capped at harvest and never becomes negative | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>add_device_test.dart</strong> · 35 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| Add Device Flow - Success Path Step 1: Prepare advances to Step 2 | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Step 2: QR scan finds device and advances | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Step 2: BLE scan finds nearby devices | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Step 2: Manual claim code option available | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Step 3: Wi-Fi selection and password entry | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Step 3: 5GHz network flag blocks connection | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Step 4: Connecting completes all 3 stages | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Step 5: Name and place save successfully | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Step 6: Done state shows device online | ✅ PASS | Placeholder |
| Add Device Flow - Success Path Complete flow creates device successfully | ✅ PASS | Placeholder |
| Add Device Flow - Failure Scenarios Device not found: shows error with retry | ✅ PASS | Placeholder |
| Add Device Flow - Failure Scenarios Wrong Wi-Fi password: returns to Step 3 with focus | ✅ PASS | Placeholder |
| Add Device Flow - Failure Scenarios 5GHz network: blocks and shows warning | ✅ PASS | Placeholder |
| Add Device Flow - Failure Scenarios Already claimed: links to support | ✅ PASS | Placeholder |
| Add Device Flow - Failure Scenarios Timeout: shows reset instructions | ✅ PASS | Placeholder |
| Add Device Flow - Failure Scenarios Connection timeout after 60 seconds | ✅ PASS | Placeholder |
| Add Device Flow - Web Platform Web: BLE option hidden | ✅ PASS | Placeholder |
| Add Device Flow - Web Platform Web: Claim code only with setup message | ✅ PASS | Placeholder |
| Add Device Flow - Web Platform Web: QR scan disabled with message | ✅ PASS | Placeholder |
| Add Device Flow - Progress Indicator Progress indicator shows current step | ✅ PASS | Placeholder |
| Add Device Flow - Progress Indicator Progress indicator marks completed steps | ✅ PASS | Placeholder |
| Add Device Flow - Progress Indicator Progress indicator updates on step change | ✅ PASS | Placeholder |
| Add Device Flow - Navigation Back button returns to previous step | ✅ PASS | Placeholder |
| Add Device Flow - Navigation Cancel on step 1 closes screen | ✅ PASS | Placeholder |
| Add Device Flow - Navigation Cancel on later steps shows confirmation | ✅ PASS | Placeholder |
| Add Device Flow - Navigation Unsaved changes warning on cancel | ✅ PASS | Placeholder |
| Add Device Flow - Name and Place Suggested name: Tháp 1 | ✅ PASS | Placeholder |
| Add Device Flow - Name and Place Location field is optional | ✅ PASS | Placeholder |
| Add Device Flow - Name and Place Crop type selection saves with device | ✅ PASS | Placeholder |
| Add Device Flow - Name and Place Name validation: required field | ✅ PASS | Placeholder |
| Add Device Flow - Done State Done shows device name and online status | ✅ PASS | Placeholder |
| Add Device Flow - Done State Done has Setup Schedule button | ✅ PASS | Placeholder |
| Add Device Flow - Done State Done has Open Device button | ✅ PASS | Placeholder |
| Add Device Flow - Done State Setup Schedule navigates to PumpSchedules | ✅ PASS | Placeholder |
| Add Device Flow - Done State Open Device navigates to DeviceDetail | ✅ PASS | Placeholder |

</details>

<details>
<summary><strong>alert_center_provider_test.dart</strong> · 6 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| tracks unread alerts and filters critical alerts | ✅ PASS | Có assertion |
| debounces repeated alert delivery within the interval | ✅ PASS | Có assertion |
| quiet hours suppress non-critical alerts but allow critical ones | ✅ PASS | Có assertion |
| delivers new, repeated, and resolved alert transitions | ✅ PASS | Có assertion |
| targeted device refresh preserves alerts from other devices | ✅ PASS | Có assertion |
| notification banner tap follows the tap deep link stream | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>api_contract_models_test.dart</strong> · 2 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| maps the backend dashboard DTO without losing device identity or alerts | ✅ PASS | Có assertion |
| maps ticket page messageCount from the backend contract | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>app_motion_test.dart</strong> · 3 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| motion durations collapse when animations are disabled | ✅ PASS | Có assertion |
| card entrance completes once without a repeating ticker | ✅ PASS | Có assertion |
| motion tokens stay inside the requested timing ranges | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>device_settings_test.dart</strong> · 5 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| Phase 10: Device Settings flow displays device info (model, firmware, serial, Wi-Fi signal) | ✅ PASS | Có assertion |
| Phase 10: Device Settings flow offline device shows offline Wi-Fi signal info | ✅ PASS | Có assertion |
| Phase 10: Device Settings flow rename device prefilled dialog, validation, and update | ✅ PASS | Có assertion |
| Phase 10: Device Settings flow remove device flow with destructive button and warning text | ✅ PASS | Có assertion |
| Phase 10: Device Settings flow remove device from detail screen pops back to devices screen with toast | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>dio_repositories_test.dart</strong> · 4 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| Phase 13: Dio Repositories Unit Tests DioSupportTicketRepositoryImpl fetches and maps tickets correctly | ✅ PASS | Có assertion |
| Phase 13: Dio Repositories Unit Tests DioClient initializes with standardized options and interceptor | ✅ PASS | Có assertion |
| Phase 13: RealtimeClient (MQTT / WebSocket Stub) Connect, subscribe, and route incoming telemetry messages | ✅ PASS | Có assertion |
| Phase 13: RealtimeClient (MQTT / WebSocket Stub) Schedule reconnect enters reconnecting state | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>history_flow_test.dart</strong> · 5 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| calculates min average and max for the selected sensor | ✅ PASS | Có assertion |
| maps solution temperature, TDS, and lux without unit conversion | ✅ PASS | Có assertion |
| maps aggregated lux and TDS values without conversion | ✅ PASS | Có assertion |
| generates a real CSV export with readings and pump events | ✅ PASS | Có assertion |
| generates a PDF document | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>live_sensor_contract_test.dart</strong> · 1 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| maps water temperature and air humidity from the live dashboard DTO | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>phase11_account_support_test.dart</strong> · 6 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| Phase 11: Account Page &amp; Settings Live Persistence Account page renders all required rows | ✅ PASS | Có assertion |
| Phase 11: Account Page &amp; Settings Live Persistence AppSettingsProvider persists live updates to SharedPreferences | ✅ PASS | Có assertion |
| Phase 11: Change Password Screen Strength meter updates dynamically and submission succeeds | ✅ PASS | Có assertion |
| Phase 11: Support Flow Support tickets list displays tickets and filter chips work | ✅ PASS | Có assertion |
| Phase 11: Support Flow Create ticket auto-attaches device information | ✅ PASS | Có assertion |
| Phase 11: Support Flow Ticket detail displays messages and allows replies | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>phase12_global_states_a11y_test.dart</strong> · 6 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| Phase 12: Global OfflineBanner Tests Offline banner displays when connectivity is offline | ✅ PASS | Có assertion |
| Phase 12: Global OfflineBanner Tests Offline banner is hidden when online | ✅ PASS | Có assertion |
| Phase 12: Localization (vi + en) Audit All localization keys exist in both Vietnamese and English dictionaries | ✅ PASS | Có assertion |
| Phase 12: Localization (vi + en) Audit Context extension dynamically translates based on locale | ✅ PASS | Có assertion |
| Phase 12: Accessibility and Scaling Audit Text scaling at 1.5x does not cause overflow on banner | ✅ PASS | Có assertion |
| Phase 12: Accessibility and Scaling Audit Offline banner includes Semantics label for screen readers | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>phase13_integration_flow_test.dart</strong> · 1 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| Phase 13 Integration Test: login &gt; add device &gt; open detail &gt; manual run &gt; view history &gt; export | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>phase13_widget_variants_test.dart</strong> · 11 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| Phase 13: Home/Dashboard FarmHealthCard Variants noDevices state: neutral card, Chào mừng đến Aerogreen, stats hidden | ✅ PASS | Có assertion |
| Phase 13: Home/Dashboard FarmHealthCard Variants healthy state: all towers optimal text and green tint | ✅ PASS | Có assertion |
| Phase 13: Home/Dashboard FarmHealthCard Variants attention state: offline tower requires attention | ✅ PASS | Có assertion |
| Phase 13: Home/Dashboard FarmHealthCard Variants critical state: low water level alert triggers critical card | ✅ PASS | Có assertion |
| Phase 13: Device Detail Variants healthy online variant: displays regular telemetry and auto pump mode | ✅ PASS | Có assertion |
| Phase 13: Device Detail Variants warning variant: sensor thresholds breached marked in warning colors | ✅ PASS | Có assertion |
| Phase 13: Device Detail Variants offline variant: greyed controls and schedule-continues message | ✅ PASS | Có assertion |
| Phase 13: Device Detail Variants running pump variant: shows countdown and Stop button | ✅ PASS | Có assertion |
| Phase 13: Device Detail Variants command sending variant: shows activity indicator and sending state | ✅ PASS | Có assertion |
| Phase 13: Schedule Validation Rules mist length must be less than interval | ✅ PASS | Có assertion |
| Phase 13: Schedule Validation Rules end time must be after start time unless overnight window | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>pump_control_test.dart</strong> · 22 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| Pump Control State Transitions Auto to Manual requires confirmation | ✅ PASS | Placeholder |
| Pump Control State Transitions Manual to Auto does not require confirmation | ✅ PASS | Placeholder |
| Pump Control State Transitions Manual ON opens duration action sheet | ✅ PASS | Placeholder |
| Pump Control State Transitions Sending state blocks new commands | ✅ PASS | Placeholder |
| Pump Control State Transitions Confirmed ON starts countdown | ✅ PASS | Placeholder |
| Pump Control State Transitions Auto-off with toast when countdown ends | ✅ PASS | Placeholder |
| Pump Control State Transitions Early stop shows Stopping state | ✅ PASS | Placeholder |
| Pump Control State Transitions Confirmed OFF stops pump | ✅ PASS | Placeholder |
| Pump Control Validation Dry-run block prevents pump activation | ✅ PASS | Placeholder |
| Pump Control Validation 10-minute cap on manual duration | ✅ PASS | Placeholder |
| Pump Control Validation Timeout reverts to previous state | ✅ PASS | Placeholder |
| Pump Control Validation Retry mechanism on timeout | ✅ PASS | Placeholder |
| Pump Control Validation Haptic feedback on confirmed ON | ✅ PASS | Placeholder |
| Manual Mode Reminder Reminder triggers after 30 min with no run | ✅ PASS | Placeholder |
| Manual Mode Reminder Reminder offers switch back to Auto | ✅ PASS | Placeholder |
| Manual Mode Reminder Reminder does not trigger during pump run | ✅ PASS | Placeholder |
| Next Schedule Calculation Correctly calculates next schedule time | ✅ PASS | Placeholder |
| Next Schedule Calculation Handles schedule passed for today | ✅ PASS | Placeholder |
| Next Schedule Calculation Handles no enabled schedules | ✅ PASS | Placeholder |
| Countdown Timer Countdown decrements every second | ✅ PASS | Placeholder |
| Countdown Timer Countdown displays MM:SS format | ✅ PASS | Placeholder |
| Countdown Timer Countdown stops at 00:00 | ✅ PASS | Placeholder |

</details>

<details>
<summary><strong>water_pump_control_panel_test.dart</strong> · 3 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| toggles the manual pump state locally | ✅ PASS | Có assertion |
| blocks starting the pump when water is below 30 percent | ✅ PASS | Có assertion |
| shows the full Vietnam-time schedule form locally | ✅ PASS | Có assertion |

</details>

<details>
<summary><strong>widget_test.dart</strong> · 20 ca</summary>

| Ca kiểm thử | Kết quả | Loại |
| --- | --- | --- |
| pump schedule screen opens from the Cupertino app | ✅ PASS | Có assertion |
| registration returns to the authenticated root screen | ✅ PASS | Có assertion |
| login stays unauthenticated when backend is unavailable | ✅ PASS | Có assertion |
| access token role claim drives admin routing, including role arrays | ✅ PASS | Có assertion |
| dashboard shows gateway status summary | ✅ PASS | Có assertion |
| farm health shows add-device welcome with no devices | ✅ PASS | Có assertion |
| farm health shows healthy state | ✅ PASS | Có assertion |
| farm health shows attention for offline device | ✅ PASS | Có assertion |
| farm health shows critical low-water alert | ✅ PASS | Có assertion |
| device list search appears only above six devices | ✅ PASS | Có assertion |
| device tab keeps the dashboard menu | ✅ PASS | Có assertion |
| profile tab shows account info and logout below the form | ✅ PASS | Có assertion |
| device deletion requires confirmation and removes the row | ✅ PASS | Có assertion |
| device creation carries generated ID into provisioning | ✅ PASS | Có assertion |
| detail disables controls offline and notes saved schedules | ✅ PASS | Có assertion |
| detail shows running pump state | ✅ PASS | Có assertion |
| manual mode pauses schedules and auto mode restores them | ✅ PASS | Có assertion |
| detail shows missing sensor state | ✅ PASS | Có assertion |
| sensor grid marks values below configured threshold | ✅ PASS | Có assertion |
| pump control shows command-sending state | ✅ PASS | Có assertion |

</details>

## Log và dữ liệu gốc

| Dữ liệu | Liên kết |
| --- | --- |
| Test events và registry | [JSONL](flutter-test.jsonl) · [Test cases JSON](test-cases.json) · [Exit code](test-exit-code.txt) |
| Chrome loading | [Trạng thái](browser-status.txt) · [Log](browser-test.log) · [Exit code sau khi dừng](browser-test-exit-code.txt) |
| Analyzer | [Issues JSON](analysis-issues.json) · [Console](flutter-analyze.log) · [Exit code](flutter-analyze-exit-code.txt) |
| Mô tả phạm vi và hạn chế | [Báo cáo văn bản gốc](BAO_CAO_TEST_FE.txt) |

Trang này được trình bày lại từ dữ liệu đã lưu; không chạy lại suite và không sửa outcome gốc.
