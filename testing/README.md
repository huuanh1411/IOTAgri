# QA documentation & evidence

Điểm tra cứu tài liệu kiểm thử, bằng chứng backend đã lưu và quy ước kết quả frontend.
Xem [README tổng quan](../README.md) để chuẩn bị checkout và chọn suite.

## Tài liệu backend

| Tài liệu | Nội dung |
| --- | --- |
| [TEST_REPORT.md](TEST_REPORT.md) | Kết luận của phiên QA backend đã lưu |
| [DEFECTS_AND_BLOCKERS.md](DEFECTS_AND_BLOCKERS.md) | Lỗi xác nhận, bước tái hiện và giới hạn |
| [TEST_CASES.md](TEST_CASES.md) | Ca thực thi, dữ liệu, assertion, ID và kết quả |
| [TEST_EXECUTION_LOG.md](TEST_EXECUTION_LOG.md) | Lịch sử phiên, môi trường và câu lệnh |
| [TEST_SCOPE_AND_INVENTORY.md](TEST_SCOPE_AND_INVENTORY.md) | Phạm vi khảo sát và inventory backend |
| [TEST_STRATEGY.md](TEST_STRATEGY.md) | Chiến lược, fixture và giới hạn đo lường |
| [Hướng dẫn đọc kết quả](guides/RESULTS_GUIDE.md) | Cách tra cứu TRX, JSON registry và coverage |
| [Quy ước đóng góp](guides/CONTRIBUTING.md) | Vị trí file, formatter và bàn giao |

## Trạng thái đã ghi nhận

Phiên backend `followup-final` bắt đầu ngày **14/10/2026 (UTC+07:00)** trên revision `318fca181741c95e73b56808ebe04a65a3ee0466`: **345 ca, 339 PASS, 6 FAIL, 0 skipped**, exit code **1**. Sáu ca thất bại thuộc bốn nhóm: đăng nhập tài khoản bị khóa, rollback migration, trả lời ticket và validate tên thiết bị.

Line coverage: **1399/2071 (~67,55%)**; branch coverage: **463/760 (~60,92%)**. Coverage không phải tỷ lệ test PASS. Số liệu này thuộc lần chạy lịch sử; việc sắp xếp lại nhánh không tạo ra kết quả kiểm thử mới.

## Bằng chứng

| Vị trí | Mục đích |
| --- | --- |
| [reports/summary/results.json](reports/summary/results.json) | Phiên, thời gian và bộ đếm tổng hợp |
| [reports/summary/test-case-registry.json](reports/summary/test-case-registry.json) | ID từng ca, test source, assertion, actual và TRX IDs |
| [reports/coverage/followup-final/backend-tests.trx](reports/coverage/followup-final/backend-tests.trx) | Kết quả native của phiên backend tham chiếu |
| [reports/summary/followup-final-test.log](reports/summary/followup-final-test.log) | Console gốc, kèm file exit code |
| [reports/coverage/SUMMARY.md](reports/coverage/SUMMARY.md) | Coverage theo module và file |
| [reports/junit/backend-tests.xml](reports/junit/backend-tests.xml) | JUnit chuyển đổi từ TRX |
| [reports/summary/backend-integrity.json](reports/summary/backend-integrity.json) | Bằng chứng so sánh source/config của phiên QA gốc |
| [reports/frontend/README.md](reports/frontend/README.md) | Quy ước lưu kết quả Flutter/E2E mới |

Các phiên cũ trong `reports/coverage/` là lịch sử chạy lại; không cộng dồn số ca giữa các phiên. Dùng trường `run` trong `results.json` để xác định nguồn dữ liệu của bản tổng hợp. [Bằng chứng frontend](../docs/testing/README.md) đã có ảnh, log và PDF; [artifact gốc đã che credential](reports/frontend/e2e/2026-10-19/raw/) gồm trace và báo cáo Playwright. [Archive ngày 13/10](reports/archive/2026-10-13/) giữ các log và coverage cũ, không cộng vào phiên tham chiếu.

## Công cụ backend

Các script giữ ở vị trí hiện tại để lệnh chạy và liên kết lịch sử tiếp tục hoạt động:

| File | Vai trò |
| --- | --- |
| [run-backend-tests.ps1](run-backend-tests.ps1) | Restore/test, lưu TRX, coverage, console và exit code |
| [coverage.runsettings](coverage.runsettings) | Phạm vi đo coverage |
| [build-test-reports.py](build-test-reports.py) | Chuyển kết quả thực thành Markdown, registry và JUnit |
| [finalize-qa-records.py](finalize-qa-records.py) | Hoàn thiện hồ sơ backend cùng kiểm tra manifest integrity của phiên gốc |

Cần checkout có mã ứng dụng để chạy các script. Xem [hướng dẫn backend](../backend/README.md). Kết quả test FAIL vẫn có thể sinh báo cáo hợp lệ; không thay đổi kết quả để làm báo cáo xanh.
