# Kết quả kiểm thử frontend

Thư mục này chứa artifact kiểm thử frontend. Báo cáo dễ đọc, ảnh và PDF nằm trong [docs/testing](../../../docs/testing/README.md).

Phiên Flutter ngày 18/10/2026: 133 PASS (57 placeholder); Chrome test bị kẹt loading, chưa kiểm chứng. Phiên UI ngày 19/10/2026: 33 ca, 22 PASS, 11 FAIL. Đây là dữ liệu đã lưu, không phải lần chạy mới.

| Vị trí | Dữ liệu |
| --- | --- |
| `e2e/<run>/` | Runner Playwright tự tạo HTML, văn bản, JSON, screenshot, console log và exit code |
| `flutter/<run>/` | Vị trí đề xuất khi lưu Flutter JSON/console log, coverage và exit code |
| [e2e/2026-10-19/raw/](e2e/2026-10-19/raw/) | Test results, trace, visual/language checks, ma trận JSON và Playwright HTML report đã che credential |

Các bản kết quả đã rà soát được commit cùng test. Mỗi phiên cần ghi revision ứng dụng, revision test, thời gian, SDK/browser, câu lệnh và exit code. Báo cáo E2E hiện chưa tự ghi toàn bộ metadata này; xem metadata gốc trong `docs/testing/2026-10-19-ui/environment.json`.

Giữ nguyên ca FAIL/SKIP và log lỗi. Rà soát credential, token, dữ liệu tài khoản và ảnh trước khi chọn bằng chứng để commit. Dữ liệu backend cũ vẫn ở các thư mục `../coverage/`, `../junit/` và `../summary/`.
