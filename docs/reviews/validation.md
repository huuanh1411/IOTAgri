# Biên bản kiểm tra tài liệu — 27/10/2026

[← Mục lục](../README.md) · [Đối chiếu tài liệu cũ](2026-10-27-docs-comparison.md)

| Kiểm tra | Kết quả |
| --- | --- |
| Schema ERD với migration snapshot | Đủ 19 bảng; 135 trường hiển thị đều có mapping; Identity được rút gọn có chủ đích |
| API inventory với khai báo route | 62 method/path, không trùng dòng; auth/owner/admin đối chiếu source |
| Mermaid nguồn và bản nhúng | Use Case/ERD đầy đủ khớp project-diagrams; tổng quan Use Case khớp tệp nguồn riêng |
| Link nội bộ và anchor | Đã kiểm tra 148 link/anchor bằng script, không có target thiếu |
| Render Mermaid | CLI 12.0.0 render thành công Use Case tổng quan/đầy đủ, ERD đầy đủ, ERD tổng quan và bối cảnh SRS; có SVG kèm theo |
| Kiểm tra trực quan | Đã mở ảnh Use Case/ERD; sơ đồ đầy đủ dài nên thêm tổng quan và tách trang dữ liệu để đọc nhanh |
| PlantUML | Đối chiếu actor/association recovery với bản Mermaid; chưa render bằng PlantUML engine |
| Whitespace diff | git diff --check không báo lỗi |
| Kiểm thử ứng dụng | Không chạy lại .NET/Flutter, không thay đổi mã ứng dụng |
| Môi trường thật | Không nghiệm thu SMTP, broker production, dữ liệu DB đang chạy hoặc relay/cảm biến vật lý |

Source baseline gồm commit local chưa công bố và các thay đổi workspace. Manifest trong [source baseline](../reference/source-baseline.md) tránh dẫn tới source không có trên nhánh Docs hoặc commit chưa công bố trên GitHub.
