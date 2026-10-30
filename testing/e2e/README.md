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
tạo tài khoản theo hợp đồng xác thực đã chọn, chạy test, lưu bằng chứng rồi dọn stack.
Không cần bật backend/frontend hay simulator thủ công.

Suite chỉ chạy thủ công trên máy của người test; nhánh `Test` không còn workflow
GitHub Actions tự chạy khi push/pull request.

Nếu đang ở checkout ứng dụng trên `main`, lấy riêng bộ test rồi chạy trên source
đang có, không cần chuyển nhánh:

```powershell
git fetch origin
git restore --source=origin/Test -- testing/e2e
node testing/e2e/scripts/run.cjs
```

Lệnh `node` vừa dựng/cài môi trường trong Docker vừa chạy test ngay, không chỉ
cài dependency. Các lệnh này không sửa source backend/frontend.

Nhánh `Test` không chứa mã ứng dụng. Mỗi lần chạy, runner fetch `refs/heads/main`
trong [`application-source.json`](application-source.json), chốt SHA rồi build từ cache
`.app/<SHA>/`. Main có commit mới thì lần chạy tiếp theo lấy commit mới; `run.json`
ghi ref, SHA và chế độ xác thực để truy lại kết quả. Fetch lỗi sẽ dừng, không dùng cache cũ.
Muốn tái lập một phiên, đặt `$env:E2E_APP_REV='<SHA đầy đủ>'` trước khi chạy trên nhánh Test.

Nếu bộ test nằm trong checkout có backend/frontend, runner kiểm tra chính code hiện có,
bao gồm sửa đổi chưa commit. Runner không tự pull/reset checkout đó; `run.json` ghi SHA
và trạng thái local. Có thể chọn checkout khác bằng biến `E2E_APP_DIR`.
`E2E_APP_REV` chỉ áp dụng khi tải source từ remote; không thay đổi checkout ứng dụng.

## Chọn đúng hợp đồng xác thực

Không suy đoán chế độ từ HTTP nhận được và không chấp nhận cả 201/202 để làm test PASS.
Chọn yêu cầu nghiệp vụ trước khi chạy:

| Chế độ | Hành vi phải đạt | Phiên bản tham chiếu |
|---|---|---|
| `verified-v1` (mặc định) | Đăng ký 202, chưa xác minh không đăng nhập được (403), SMTP gửi mã, xác minh 204, đăng nhập 200; Google token giả 401 | main tại `a3dc75761cba97f71b9fe3cc80d49773ff89295b` |
| `direct-v1` | Đăng ký 201, đăng nhập 200 ngay; UI đăng ký vào home và giữ phiên sau reload; endpoint Google chưa có (404) | `202ffb8e7cc01440cae2ebd93f96df634b19a831` |

Với checkout của bạn đang ở commit `202ffb8...`, lấy bộ test mới rồi chọn luồng trực tiếp:

```powershell
git fetch origin
git restore --source=origin/Test -- testing/e2e
$env:E2E_AUTH_CONTRACT='direct-v1'
node testing/e2e/scripts/run.cjs
Remove-Item Env:E2E_AUTH_CONTRACT
```

Với main mới có xác thực email hoặc chạy riêng nhánh Test:

```powershell
$env:E2E_AUTH_CONTRACT='verified-v1'
node testing/e2e/scripts/run.cjs
```

Hai chế độ không thay thế nhau khi có regression. Nếu yêu cầu là xác thực email nhưng
ứng dụng trả 201, giữ `verified-v1` để báo lỗi; không chuyển chế độ để che lỗi.
Không tự sửa ứng dụng, không retry tự động, không bỏ qua assertion lỗi.
Các luồng chưa tương thích khác vẫn báo FAIL để người phụ trách phân loại và xử lý.
Suite không đảm bảo tương thích với mọi thay đổi nghiệp vụ trong tương lai.
`direct-v1` không bao phủ SMTP/xác thực email hay Google OAuth.

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
| Xác thực (`verified-v1`) | Đăng ký trên UI → SMTP → mã xác minh → DB → đăng nhập; refresh rotation/replay, logout; từ chối Google token giả |
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
  production vào suite. Kết quả local được gitignore và được giữ trên máy cho
  đến khi người dùng tự dọn; không có bước upload artifact lên GitHub Actions.
- Test FAIL, lỗi setup/build và lỗi cleanup trả exit code khác 0; không chuyển lỗi
  thành skip hoặc coi việc discovery thành kết quả PASS.

## Cấu trúc

`compose.yaml` và Dockerfile dựng môi trường; `support/setup.cjs` chuẩn bị tài khoản
qua API/SMTP; `support/device.cjs` là simulator MQTT; `system.spec.cjs` kiểm tra các
chuỗi API/DB/MQTT; `browser.spec.cjs` kiểm tra UI với Flutter semantics.
Helper nhập liệu dùng sự kiện bàn phím, và helper cuộn đưa các control dưới màn
hình vào semantics tree trước khi tương tác. Không thay đổi source ứng dụng để
làm test PASS. Lỗi hoặc giới hạn thao tác UI được giữ trong báo cáo để xem xét.

Lượt kiểm chứng mới nhất từ clone sạch: **31 PASS / 1 FAIL / 0 skipped**.
Ca chưa đạt là `WEB-04 / mobile`; không sửa ứng dụng hoặc bỏ assertion để đổi
kết quả. FAIL vẫn xuất artifact local và giữ exit code khác 0.
Xem [báo cáo và các phiên độc lập](../reports/system-e2e/2026-10-30/README.md).

Tham khảo: [Mailpit SMTP](https://mailpit.axllent.org/docs/configuration/smtp/),
[Playwright Docker](https://playwright.dev/docs/docker). Phiên bản Playwright trong
image runner và package npm phải trùng nhau.
