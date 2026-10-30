# E2E toàn hệ thống

Suite này chạy ứng dụng qua Flutter Web, API .NET, PostgreSQL,
Mosquitto và SMTP Mailpit thật. Playwright điều khiển Chromium; simulator đóng vai
thiết bị và nhận lệnh/trả ACK qua broker thật. Không cần Flutter/.NET SDK cài trên máy.

## Chạy trên Windows

Cần Git, Node.js 22 và Docker Desktop đang chạy **Linux containers**. Lần đầu cần mạng
để tải image và package; dành đủ dung lượng cho image Flutter và trình duyệt.

Sau khi pull nhánh `Test`, chạy từ gốc repository (không cần `npm ci` trên máy):

```powershell
git pull --ff-only origin Test
node testing/e2e/scripts/run.cjs
```

Lệnh `node` dùng được trên Windows/macOS/Linux. Runner tự build ứng dụng, chờ healthcheck,
tạo tài khoản, xác minh email qua Mailpit, chạy test, lưu bằng chứng rồi dọn stack.
Không cần bật backend/frontend hay simulator thủ công.

Nhánh `Test` không chứa mã ứng dụng. Runner tự tải revision cố định trong
[`application-source.json`](application-source.json) vào `.app/<revision>/` được
gitignore rồi build tại đó. Bản hiện tại dùng `bb2900380f2c2d15decdbc4b458584b6a57e66fb`
của `origin/main`; backend/frontend khớp source của báo cáo ngày 30/10.
Không checkout/reset nhánh của bạn, không sửa source cache để làm test PASS.
Mỗi lần chạy ghi cả revision nhánh test và revision ứng dụng vào `run.json`.

Nếu bộ test nằm trong checkout đã có đủ backend/frontend, runner dùng source
checkout đó. Có thể chỉ định một checkout ứng dụng khác bằng biến `E2E_APP_DIR`.
Để cập nhật ứng dụng cần test, đổi SHA đầy đủ trong `application-source.json`,
kiểm tra lại rồi commit thay đổi này. Chạy lại không tự trôi sang main mới hơn.

Các lệnh tiện ích dưới đây cần cài package local một lần:

```powershell
cd testing/e2e
npm.cmd ci
```


```powershell
# Chỉ liệt kê test: không dựng Docker hay tạo dữ liệu
npm.cmd run test:list

# Chỉ kiểm tra API / DB / MQTT
npm.cmd test -- --project=system

# Chỉ chạy giao diện desktop hoặc chọn ca
npm.cmd test -- --project=desktop
npm.cmd test -- --grep WEB-04

# Xem báo cáo của lần chạy gần nhất
npm.cmd run report
```

Mỗi `npm test` tạo stack mới, vì vậy các lần chạy riêng không cộng dồn tài khoản
hay giới hạn rate limit. Không dùng `test:direct` để chạy lại trên database cũ:
chỉ dành cho chẩn đoán bên trong runner đã cấu hình.

## Phạm vi

| Nhóm | Ca tự động |
|---|---|
| Xác thực | Đăng ký trên UI → SMTP → mã xác minh → DB → đăng nhập; refresh rotation/replay, logout; từ chối Google token giả |
| Phân quyền | Anonymous, user/admin; hai user không đọc/điều khiển/xóa thiết bị của nhau |
| Dữ liệu | MQTT telemetry → PostgreSQL → readings/aggregation → dashboard; hiển thị trên UI |
| Bơm | UI → API → MQTT → ACK → DB; bật/tắt, tự dừng, idempotency, thiết bị từ chối, thiếu ACK rồi khôi phục |
| Đèn | UI/API → MQTT → trạng thái bật/tắt; lịch tự động bật rồi tắt |
| Lịch bơm | Tới giờ thật → scheduler → MQTT → ACK; kiểm tra occurrence và lịch chồng nhau |
| Cảnh báo | Vượt ngưỡng nhiệt độ/mực nước → tạo cảnh báo; giá trị an toàn → resolve |
| Presence | Không còn telemetry → offline sau thời gian thực; gửi lại → online |
| Hỗ trợ | User tạo ticket → admin trả lời → user đọc; user khác không truy cập được |
| Trình duyệt | Đăng nhập, reload, đăng xuất, admin routing, lỗi đăng nhập/mạng; 3 viewport |

Suite hiện có **32 ca**: 17 ca `SYS-*` và 5 luồng `WEB-*` × 3 viewport.
`system` chạy một lượt; các ca `WEB-*` chạy ở desktop 1280×900, mobile 390×844,
small-mobile 320×568. Đây là web responsive, không phải Android/iOS native.
Một ca lỗi mạng trên browser dùng fault injection (`route.abort`); các luồng chính
không mock API, DB hoặc broker. Simulator và SMTP là các điểm thay thế phần cứng
và nhà cung cấp email. Lịch và presence chạy với thời gian thật, không sửa đồng hồ DB.

Các kiểm tra bổ sung cần môi trường riêng: ESP32 thật/Wi-Fi provisioning và broker
dynamic-security ACL, Google OAuth thành công với client ID/tài khoản thật,
Android/iOS native, hiệu năng/tải, restart broker/API và khôi phục sau crash.
Các mục này chưa được xác nhận chỉ bằng suite simulator.

## Dữ liệu và bằng chứng

- Không dùng `.env` của ứng dụng. Toàn bộ credential trong Compose là **test-only**.
- Mỗi phiên có Compose project `iotagri-e2e-<timestamp>-<random>` và volume DB riêng.
- Không publish cổng DB/MQTT/API ra host, không kết nối thiết bị hay email thật.
- Sau khi chạy (kể cả FAIL), runner lấy log rồi `down --volumes` đúng project vừa tạo.
- Nếu tiến trình bị kill/mất điện, xem `run.json`/tên project trong log và dọn bằng
  `docker compose --env-file empty.env -p <project> -f compose.yaml down --volumes`.
- Kết quả ở `artifacts/<timestamp>-<random>/`: HTML report, `results.json`, JUnit,
  ảnh/trace/video khi lỗi, MQTT command ledger, log service, trạng thái container,
  revision Git và exit code. `artifacts/latest-run.txt` chỉ tới phiên gần nhất.
- Artifact có dữ liệu và token **của tài khoản test** trong trace; không đưa tài khoản
  production vào suite. Kết quả local được gitignore. CI lưu artifact 14 ngày.
- Test FAIL, lỗi setup/build và lỗi cleanup trả exit code khác 0; không chuyển lỗi
  thành skip hoặc coi việc discovery thành kết quả PASS.

## Cấu trúc

`compose.yaml` và Dockerfile dựng môi trường; `support/setup.cjs` chuẩn bị tài khoản
qua API/SMTP; `support/device.cjs` là simulator MQTT; `system.spec.cjs` kiểm tra các
chuỗi API/DB/MQTT; `browser.spec.cjs` kiểm tra UI với Flutter semantics.
Helper nhập liệu dùng sự kiện bàn phím, và helper cuộn đưa các control dưới màn
hình vào semantics tree trước khi tương tác. Không thay đổi source ứng dụng để
làm test PASS. Lỗi hoặc giới hạn thao tác UI được giữ trong báo cáo để xem xét.

Workflow `.github/workflows/e2e.yml` chạy khi push cập nhật suite vào nhánh `Test`,
trên pull request liên quan và khi chạy thủ công. FAIL vẫn xuất artifact và giữ
exit code khác 0. Xem [báo cáo đã công bố](../reports/system-e2e/2026-10-30/README.md).

Tham khảo: [Mailpit SMTP](https://mailpit.axllent.org/docs/configuration/smtp/),
[Playwright Docker](https://playwright.dev/docs/docker). Phiên bản Playwright trong
image runner và package npm phải trùng nhau.
