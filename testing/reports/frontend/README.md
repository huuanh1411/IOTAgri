# Kết quả kiểm thử frontend

Thư mục này quy định vị trí cho bằng chứng frontend mới. Hiện nhánh chưa lưu kết quả thực thi Flutter/E2E; không suy ra PASS từ việc có file test hoặc discovery thành công.

| Vị trí | Dữ liệu |
| --- | --- |
| `e2e/<run>/` | Runner Playwright tự tạo HTML, văn bản, JSON, screenshot, console log và exit code |
| `flutter/<run>/` | Vị trí đề xuất khi lưu Flutter JSON/console log, coverage và exit code |

Các thư mục phiên được gitignore theo mặc định. Mỗi phiên cần ghi revision ứng dụng, revision test, thời gian, SDK/browser, câu lệnh và exit code. Báo cáo E2E hiện chưa tự ghi toàn bộ metadata này; bổ sung khi bàn giao.

Giữ nguyên ca FAIL/SKIP và log lỗi. Rà soát credential, token, dữ liệu tài khoản và ảnh trước khi chọn bằng chứng để commit. Dữ liệu backend cũ vẫn ở các thư mục `../coverage/`, `../junit/` và `../summary/`.
