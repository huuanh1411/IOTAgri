# Báo cáo E2E trên code nguyên bản — 30/10/2026

[Bản bằng chứng đã công bố trên nhánh Test](../reports/system-e2e/2026-10-30/README.md)
gồm HTML, JSON, JUnit, ảnh, log, trace/video và manifest SHA-256 đã che credential.

Revision ứng dụng: `accd272a6b40af39776275fc1461487daa7b9529`.
Phiên: `1793358159401-35b398`. Chạy qua `node testing/e2e/scripts/run.cjs`.
Kết quả: **32 ca, 30 PASS, 2 FAIL, không skip**. Exit code test: **1**;
cleanup Docker: **0**. Không thay đổi source ứng dụng để làm test PASS.

| Nhóm | PASS | FAIL |
|---|---:|---:|
| API / PostgreSQL / MQTT / SMTP | 16 | 1 |
| Desktop 1280×900 | 5 | 0 |
| Mobile 390×844 | 4 | 1 |
| Small mobile 320×568 | 5 | 0 |

## Các ca chưa đạt

### SYS-13 — lịch bơm không phát lệnh trong thời gian kiểm tra

Test tạo lịch bắt đầu sau khoảng 10 giây, thời lượng chạy 3 giây, timezone
`Etc/UTC`; môi trường test poll lịch mỗi 5 giây. Mong đợi simulator nhận một
lệnh `source=scheduled` và trả ACK. Thực tế: không nhận lệnh sau 30 giây.

Cần đối chiếu cửa sổ lịch ngắn với chu kỳ poll. Source hiện có nhánh đánh dấu
`SCHEDULE_EXPIRED` khi thời điểm kết thúc đã qua; đây là giả thuyết cần xác minh,
chưa có bằng chứng DB của lệnh trong phiên để khẳng định nguyên nhân cuối cùng.
Không chỉnh scheduler, fixture thời lượng, assertion hoặc bỏ ca này để đổi kết quả.

### WEB-04 / mobile — automation chưa mở được hộp chọn thời gian bơm

Sau đăng nhập, chọn thiết bị và chuyển sang thủ công, test không tìm thấy lựa
chọn `30 giây`; cũng không ghi nhận response gửi lệnh bơm trong 15 giây.
Ảnh chụp vẫn hiển thị nút `BẬT BƠM`. Semantics gộp tiêu đề/trạng thái/nút thành
một target. Các lượt khác của luồng này đã PASS, nên có dấu hiệu không ổn định
ở thao tác automation. **Chưa kết luận chức năng bơm thực tế bị lỗi.**

Giữ nguyên ca FAIL và bằng chứng; không thay đổi ứng dụng để hỗ trợ locator.

## Bằng chứng local

Thư mục `artifacts/1793358159401-35b398/` chứa:

- `playwright-report/index.html`: báo cáo tương tác.
- `results.json`, `junit.xml`, `runner.log`: kết quả đầy đủ.
- `test-results/`: screenshot, trace, video, error context và MQTT ledger.
- `services.log`, `services-status.txt`: log và trạng thái dịch vụ trước khi dọn.
- `run.json`, `exit-code.txt`: revision, thời gian, exit code và cleanup.

Artifact được gitignore; báo cáo này tham chiếu kết quả local, không phải một
lượt GitHub Actions đã chạy. `git diff --exit-code -- backend frontend README.md
.dockerignore` trả 0 sau khi hoàn tác các thay đổi ứng dụng.

Phạm vi dùng simulator MQTT và SMTP Mailpit. ESP32 thật, Wi-Fi provisioning,
Google OAuth thành công, Android/iOS native và kiểm tra tải chưa được xác nhận.
Xem [hướng dẫn chạy lại](README.md).
