# Công cụ xuất báo cáo frontend

Hai script này tạo các báo cáo lịch sử đã bàn giao, không cài đặt môi trường hay chạy ứng dụng:

- `create_fe_test_report.py`: đọc JSON events và analyzer log ngày 18/10/2026, xuất registry và báo cáo văn bản vào `docs/testing/2026-10-18-frontend/`. Dùng Python standard library.
- `create_ui_bug_pdf.py`: đọc JSON và screenshot ngày 19/10/2026, tạo PDF trong `docs/testing/2026-10-19-ui/`. Cần Python có ReportLab, Pillow và font Arial của Windows.

Script PDF kiểm tra đúng snapshot 33 ca, 22 PASS và 11 FAIL. Đây là công cụ cho bộ bằng chứng đã lưu, không phải mẫu tổng hợp kết quả bất kỳ. Việc chạy lại sẽ ghi đè các file báo cáo cùng tên; không thay đổi kết quả thực thi trong log gốc.

## Trình bày dữ liệu trên GitHub

`render_github_reports.py` đọc JSON đã công bố và tạo ba trang Markdown: báo cáo UI, thư viện ảnh theo kịch bản/viewport và báo cáo Flutter theo file. Script dùng Python standard library, giữ nguyên JSON, log, ảnh và outcome gốc.

```powershell
python testing/tools/frontend/render_github_reports.py
```
