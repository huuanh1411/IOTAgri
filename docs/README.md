# Mục lục tài liệu

[← Trang chính](../README.md)

| Nhóm | Tài liệu | Mục đích |
| --- | --- | --- |
| Yêu cầu | [SRS](requirements/SRS.md) | Phạm vi, FR/NFR, giới hạn và tiêu chí chấp nhận |
| Nghiệp vụ | [Use Case](use-cases/README.md) | Actor, danh mục UC và luồng chính/ngoại lệ |
| Dữ liệu | [ERD và từ điển dữ liệu](data/README.md) | Schema vật lý, ràng buộc và dữ liệu không lưu DB |
| Sơ đồ | [Thư viện](diagrams/README.md) · [Bản xem đầy đủ](diagrams/project-diagrams.md) | Mermaid hiển thị trực tiếp trên GitHub, PlantUML để biên tập UML |
| Tham chiếu | [API](reference/api-inventory.md) · [Source baseline](reference/source-baseline.md) | Truy vết về source cụ thể, kể cả giới hạn workspace |
| Rà soát | [Đối chiếu Docs cũ](reviews/2026-10-27-docs-comparison.md) | Những gì giữ nguyên, cập nhật, tạo mới và lý do |

## Quy ước

- `UC-xx`: nhóm mục tiêu người sử dụng; `FR-xx`: yêu cầu chức năng; `NFR-xx`: yêu cầu phi chức năng.
- “Có triển khai”: thấy trong source, không đồng nghĩa đã nghiệm thu trên môi trường thật.
- “Cục bộ/mock”: không coi là nghiệp vụ đã đồng bộ PostgreSQL.
- “Đề xuất/chưa xác nhận”: yêu cầu cần thống nhất hoặc kiểm chứng, không phải cam kết hiện hữu.
- Sơ đồ `.mmd` là nguồn Mermaid chuẩn. Bản nhúng trong `project-diagrams.md` được đồng bộ từ các tệp này.

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
  diagrams/use-case-overview.mmd
  diagrams/use-case.mmd
  diagrams/use-case.puml
  diagrams/erd.mmd
  diagrams/rendered/*.svg
  reference/api-inventory.md
  reference/source-baseline.md
  reviews/2026-10-27-docs-comparison.md
  reviews/validation.md
```
