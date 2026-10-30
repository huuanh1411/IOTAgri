# Bằng chứng kiểm thử

Phiên cập nhật hợp đồng xác thực: **main a3dc757 — 30 PASS / 2 FAIL**. [Xem báo cáo](system-e2e/2026-10-30-contract-update/README.md). Chỉ sửa test, giữ nguyên lỗi ứng dụng.

Các phiên bên dưới là lịch sử riêng biệt.

[← Tổng quan QA](../../README.md) · [Báo cáo frontend](../../docs/testing/README.md) · [Hồ sơ backend](../README.md)

## Chọn đúng nguồn dữ liệu

| Phạm vi | Phiên                         | Kết quả                              | Mở dữ liệu                                                                                                                                  |
| ------- | ----------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| System E2E mới nhất | 30/10/2026 · clone sạch · 32 ca | 31 PASS / 1 FAIL / 0 skipped | [Metadata phiên mới nhất](system-e2e/2026-10-30/clean-checkout-validation.json) · [Báo cáo](system-e2e/2026-10-30/README.md) |
| System E2E trước đó | 30/10/2026 · 32 ca | 30 PASS / 2 FAIL / 0 skipped | [Báo cáo, ảnh, log và trace](system-e2e/2026-10-30/README.md) |
| Backend | `followup-final` · 14/10/2026 | 339 PASS / 6 FAIL                    | [TRX gốc](coverage/followup-final/backend-tests.trx) · [Console](summary/followup-final-test.log)                                           |
| Flutter | 18/10/2026                    | 133 PASS, gồm 57 placeholder         | [Báo cáo theo file](../../docs/testing/2026-10-18-frontend/README.md) · [Events](../../docs/testing/2026-10-18-frontend/flutter-test.jsonl) |
| Web UI  | 19/10/2026                    | 22 PASS / 10 FAIL / 1 TIMEOUT        | [Báo cáo & ảnh](../../docs/testing/2026-10-19-ui/README.md) · [Artifact](frontend/e2e/2026-10-19/README.md)                                 |
| Archive | 13/10/2026                    | Các lượt chạy trước phiên tham chiếu | [Log, TRX và coverage cũ](archive/2026-10-13/)                                                                                              |

## Backend · Dữ liệu tổng hợp

| Tôi muốn kiểm tra…                     | File                                                                              |
| -------------------------------------- | --------------------------------------------------------------------------------- |
| Phiên và bộ đếm kết quả                | [summary/results.json](summary/results.json)                                      |
| ID ca, test source, assertion, outcome | [summary/test-case-registry.json](summary/test-case-registry.json)                |
| Coverage theo module/file              | [coverage/SUMMARY.md](coverage/SUMMARY.md)                                        |
| Coverage dùng cho công cụ              | [Cobertura XML](coverage/coverage.cobertura.xml) · [JSON](coverage/coverage.json) |
| Kết quả chuyển đổi sang JUnit          | [junit/backend-tests.xml](junit/backend-tests.xml)                                |
| Integrity của phiên QA gốc             | [summary/backend-integrity.json](summary/backend-integrity.json)                  |

## Cách xem

- **Markdown / ảnh:** đọc trực tiếp trên GitHub; bấm thumbnail để mở ảnh gốc.
- **Log / JSON / XML:** mở file; với file lớn, chọn **Raw** hoặc tải xuống.
- **HTML:** tải cả thư mục tài nguyên rồi mở bằng trình xem phù hợp.
- **Trace ZIP:** tải file rồi mở bằng Playwright Trace Viewer.

[Manifest công bố](evidence-manifest.json) ghi 207 artifact cùng SHA-256 và cờ đã che credential. Các README bổ sung là lớp điều hướng, không thay thế file kết quả gốc. Không cộng số ca giữa các phiên chạy lại; xem [hướng dẫn đọc dữ liệu](../guides/RESULTS_GUIDE.md).
