# Thư viện sơ đồ

[← Mục lục](../README.md)

| Nội dung | Xem trực tiếp | Nguồn chỉnh sửa |
| --- | --- | --- |
| Use Case | [Sơ đồ và luồng chi tiết](../use-cases/README.md) | [Tổng quan PlantUML](use-case-overview.puml) · [Chi tiết PlantUML](use-case.puml) |
| ERD | [Tổng quan và từ điển](../data/README.md) | [Mermaid đầy đủ](erd.mmd) |
| Cả hai sơ đồ trên một trang | [Bản xem đầy đủ](project-diagrams.md) | Đồng bộ từ hai tệp .mmd |

Use Case dùng PlantUML và SVG: mỗi actor là hình người que có tên bên dưới, đứng ngoài khung hành động riêng; các liên kết đến hành động là đoạn thẳng trực tiếp. Các trang Markdown nhúng SVG để hiển thị đúng bố cục. ERD tiếp tục dùng Mermaid. ERD đầy đủ khá rộng, nên bắt đầu bằng bản tổng quan ở trang dữ liệu.

Baseline: **27/10/2026**, xem [nguồn và giới hạn](../reference/source-baseline.md). Các đường dẫn cũ `docs/diagrams/*` được giữ để không làm gãy bookmark; nội dung giải thích được tổ chức lại theo nghiệp vụ, dữ liệu và yêu cầu.


## Bản SVG đã render

[Use Case tổng quan](rendered/use-case-overview.svg) · [Use Case đầy đủ](rendered/use-case.svg) · [ERD đầy đủ](rendered/erd.svg) · [ERD tổng quan](rendered/erd-overview.svg) · [Bối cảnh hệ thống](rendered/system-context.svg)

SVG giữ chữ và đường nét khi phóng to. Hai nguồn PlantUML là nguồn chỉnh sửa Use Case; các bản flowchart Mermaid cũ đã được thay thế để dùng đúng ký hiệu actor. Sau khi sửa nguồn, chạy từ gốc repository:

```sh
python docs/diagrams/render-use-cases.py
```

Script chỉ dùng thư viện chuẩn Python, đọc các khai báo actor/rectangle/usecase và liên kết trong hai tệp PlantUML của dự án, xuất hai ảnh tổng hợp và năm ảnh actor riêng. Các ảnh SVG dùng đoạn thẳng từ tay actor đến từng hình elip, không có điểm trung chuyển. Bố cục khi render bằng PlantUML khác có thể thay đổi theo engine.

Các use case dùng chung được lặp lại theo actor; các khung đều thuộc cùng hệ thống IOTAgri. Màu vàng giữ ý nghĩa chức năng cục bộ/mock. Khi sửa Mermaid ERD, cần render lại SVG ERD tương ứng.
