# Frontend · Kết quả & bằng chứng

[← Tổng quan QA](../../README.md) · [Flutter](2026-10-18-frontend/README.md) · [Web UI](2026-10-19-ui/README.md) · [Thư viện ảnh](2026-10-19-ui/screenshots/README.md)

## Chọn báo cáo

| Báo cáo                                                                    | Kết quả đã lưu                            | Nội dung xem trực tiếp                                   |
| -------------------------------------------------------------------------- | ----------------------------------------- | -------------------------------------------------------- |
| [Flutter · 18/10/2026](2026-10-18-frontend/README.md)                      | **133 PASS**, gồm **57 placeholder**      | Kết quả theo file, tên từng ca, log và analyzer          |
| [Web UI · 19/10/2026](2026-10-19-ui/README.md)                             | **22 PASS · 10 FAIL · 1 TIMEOUT** / 33 ca | Ma trận 3 viewport, vấn đề, ca chưa đạt và thông báo lỗi |
| [Ảnh giao diện](2026-10-19-ui/screenshots/README.md)                       | **70 ảnh · 11 kịch bản · 3 viewport**     | Thumbnail theo kịch bản; bấm ảnh để xem bản gốc          |
| [PDF lỗi giao diện](2026-10-19-ui/Bao_cao_loi_giao_dien_FE_2026-10-19.pdf) | Báo cáo bàn giao từ phiên UI              | [4 trang xem trước](2026-10-19-ui/pdf-preview/README.md) |

> **Giới hạn:** 57 ca Flutter là placeholder; Flutter Chrome kẹt loading và chưa kiểm chứng. Báo cáo UI gốc ghi 11 ca chưa đạt, bao gồm 1 timeout. Các trang này trình bày dữ liệu lịch sử, không phải lần chạy mới.

## Xem nhanh ảnh

| Đăng nhập                                                                                                                                                   | Tài khoản small-mobile                                                                                                                                                                | Dashboard                                                                                                                                                  |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a href="2026-10-19-ui/screenshots/mobile-UI-01-02.png"><img src="2026-10-19-ui/screenshots/mobile-UI-01-02.png" width="220" alt="Giao diện đăng nhập"></a> | <a href="2026-10-19-ui/screenshots/small-mobile-UI-07-01.png"><img src="2026-10-19-ui/screenshots/small-mobile-UI-07-01.png" width="220" alt="Trang tài khoản trên màn hình nhỏ"></a> | <a href="2026-10-19-ui/screenshots/mobile-UI-11-02.png"><img src="2026-10-19-ui/screenshots/mobile-UI-11-02.png" width="220" alt="Ngôn ngữ dashboard"></a> |

## Dữ liệu để đối chiếu

| Nhu cầu                                   | Dữ liệu                                                                                                       |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Kiểm tra từng ca Flutter                  | [Registry JSON](2026-10-18-frontend/test-cases.json) · [Events JSONL](2026-10-18-frontend/flutter-test.jsonl) |
| Đọc console Web UI                        | [runner.log](2026-10-19-ui/runner.log) · [Exit code](2026-10-19-ui/exit-code.txt)                             |
| Đối chiếu revision và browser             | [Môi trường](2026-10-19-ui/environment.json)                                                                  |
| Phân biệt ca riêng biệt và lượt chạy lại  | [Verification runs](2026-10-19-ui/verification-runs.json)                                                     |
| Tải trace, JSON Playwright và HTML report | [Chỉ mục artifact](../../testing/reports/frontend/e2e/2026-10-19/README.md)                                   |
| Kiểm tra tính toàn vẹn file công bố       | [Manifest SHA-256](../../testing/reports/evidence-manifest.json)                                              |

Báo cáo Web UI hợp nhất 33 ca riêng biệt từ 39 lượt thực thi, gồm các lượt chụp lại/xác minh. Bản công bố đã che mật khẩu/token; outcome và ảnh gốc được giữ nguyên. Markdown và ảnh đọc trực tiếp trên GitHub, HTML cần tải cùng tài nguyên để mở.
