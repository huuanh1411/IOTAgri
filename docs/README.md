# Mục lục tài liệu

[← Trang chính](../README.md)

**Xem nhanh:** [Context Diagram](diagrams/context-diagram.md) · [Use Case](use-cases/README.md) · [ERD](data/README.md) · [Tất cả sơ đồ](diagrams/project-diagrams.md)

Đọc theo thứ tự **Context Diagram → SRS → Use Case → ERD → API** để đi từ bối cảnh đến yêu cầu, chức năng và dữ liệu.

| Nhóm | Tài liệu | Mục đích |
| --- | --- | --- |
| Bối cảnh | [Context Diagram](diagrams/context-diagram.md) | Ranh giới IOTAgri, thực thể bên ngoài và luồng dữ liệu |
| Yêu cầu | [SRS](requirements/SRS.md) | Phạm vi, FR/NFR, giới hạn và tiêu chí chấp nhận |
| Nghiệp vụ | [Use Case](use-cases/README.md) | Actor, danh mục UC và luồng chính/ngoại lệ |
| Dữ liệu | [ERD và từ điển dữ liệu](data/README.md) | Schema vật lý, ràng buộc và dữ liệu không lưu DB |
| Sơ đồ | [Thư viện](diagrams/README.md) · [Bản xem đầy đủ](diagrams/project-diagrams.md) | Ảnh SVG để xem/phóng to, nguồn Mermaid và PlantUML để chỉnh sửa |
| Tham chiếu | [API](reference/api-inventory.md) · [Source baseline](reference/source-baseline.md) | Truy vết về source cụ thể, kể cả giới hạn workspace |
| Rà soát | [Đối chiếu Docs cũ](reviews/2026-10-27-docs-comparison.md) | Những gì giữ nguyên, cập nhật, tạo mới và lý do |

## Quy ước

- `UC-xx`: nhóm mục tiêu người sử dụng; `FR-xx`: yêu cầu chức năng; `NFR-xx`: yêu cầu phi chức năng.
- “Có triển khai”: thấy trong source, không đồng nghĩa đã nghiệm thu trên môi trường thật.
- “Cục bộ/mock”: không coi là nghiệp vụ đã đồng bộ PostgreSQL.
- “Đề xuất/chưa xác nhận”: yêu cầu cần thống nhất hoặc kiểm chứng, không phải cam kết hiện hữu.
- Sơ đồ `.mmd` là nguồn Mermaid chuẩn; `.puml` là nguồn UML Use Case. Trang `project-diagrams.md` nhúng SVG Context/Use Case và mã Mermaid ERD từ các nguồn tương ứng.

## Cấu trúc

```text
README.md
docs/
  README.md
  requirements/SRS.md
  use-cases/README.md
  data/README.md
  diagrams/README.md
  diagrams/project-diagrams.md
  diagrams/context-diagram.md
  diagrams/system-context.mmd
  diagrams/use-case-overview.puml
  diagrams/use-case.puml
  diagrams/erd.mmd
  diagrams/rendered/*.svg
  reference/api-inventory.md
  reference/source-baseline.md
  reviews/2026-10-27-docs-comparison.md
  reviews/validation.md
```
