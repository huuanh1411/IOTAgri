# Đối chiếu tài liệu nhánh Docs — 27/10/2026

[← Mục lục](../README.md) · [Source baseline](../reference/source-baseline.md)

## Đối tượng so sánh

Bản trước là `origin/Docs` commit `99d9422` ngày 24/10/2026, gồm đúng 5 tệp: `docs/diagrams/README.md`, `project-diagrams.md`, `erd.mmd`, `use-case.mmd`, `use-case.puml`. Nhánh này chưa có SRS và chưa có trang chủ/mục lục ở root.

So với source main tại commit `ac9fc42` và các thay đổi workspace được ghi ở baseline, phần lớn mô hình ERD cũ vẫn đúng. Lần cập nhật này không dựng lại schema theo giả định và không đưa code ứng dụng vào nhánh tài liệu.

## Kết quả và xử lý

| Hạng mục | Tài liệu cũ | Kết quả đối chiếu | Xử lý hiện tại |
| --- | --- | --- | --- |
| SRS | Chưa có | Thiếu phạm vi, FR/NFR, tiêu chí chấp nhận và truy vết | Tạo requirements/SRS.md với FR-01–18, NFR-01–08, BR-01–10 và giới hạn |
| Use Case khôi phục mật khẩu | Chưa có actor SMTP và use case recovery | AuthEndpoints đã có forgot-password/reset-password, sender SMTP và rate limit | Bổ sung cả Mermaid và PlantUML; đặc tả UC-03 |
| Use Case chi tiết | Chỉ sơ đồ nhóm | Chưa có ID, tiền/hậu điều kiện và ngoại lệ để nghiệm thu | Tạo 18 UC, liên kết FR, nêu lỗi và điều kiện |
| ERD quan hệ nghiệp vụ | Có 19 bảng và các FK chính | Khớp DbContext/snapshot; CommandId occurrence và DeviceId ticket là tham chiếu logic | Giữ cấu trúc; bổ sung PhoneNumber và nullable của một số trường Identity; không vẽ thêm FK |
| ERD và persistence ngoài DB | Có giải thích trạng thái đèn/mock cây | Vẫn đúng; cần từ điển bảng và ràng buộc dễ tra cứu | Tạo data/README.md, ERD tổng quan và bảng delete behavior |
| Độ bền lệnh đèn | Sơ đồ nhóm có light control | Không có LightCommands table; trạng thái ở bộ nhớ backend | SRS/UC-11 nói rõ 202 Pending và restart mất trạng thái |
| Điều khiển bơm và lịch | Chỉ biểu diễn nhóm trên sơ đồ | Có kiểm tra nước/telemetry, quyền lịch, occurrence và expiry | Bổ sung UC-09/10, BR-03–06 và tiêu chí lỗi; không hứa exactly-once vật lý |
| Firmware | ESP32 có actuation trên Use Case | Source hiện có subscription, GPIO, timer, clock/nước và ACK; tài liệu pump-priority trên main còn mô tả firmware chưa có actuation | Giữ use case actuation, đặc tả UC-18 theo source và nêu phần ưu tiên/replay/offline chưa được chứng minh |
| Production/security | Không có SRS tương ứng | Source có compose production, MQTT TLS/dynsec, Data Protection và validation SMTP | NFR ghi nhận triển khai trong source; không khẳng định đã rollout/kiểm thử production |
| Dashboard và dữ liệu giả | Có ghi mock cây/harvest | Workspace có đồng bộ thiết bị đang chọn; provider cũ vẫn có đường `/api/sensor/latest` không được backend map | Ghi khác biệt workspace; phân biệt dashboard thực với provider cũ/fallback |
| Link source | Đường dẫn `../../backend/...` trên nhánh chỉ có docs | Không trỏ tới file có thật trên Docs | Dẫn đến manifest đường dẫn/hash nguồn trong Docs; ghi rõ baseline local chưa công bố, tránh tạo URL GitHub có thể gãy |
| Trình bày | README diagrams và project-diagrams lặp phần giải thích; tiêu đề cũ có ký tự `?` | Khó tìm tài liệu khi vào nhánh | Tạo README root/docs, tách requirements/use-cases/data/reference/reviews, giữ đường dẫn diagram cũ |

## Cấu trúc sau hiệu chỉnh

- [Trang chủ](../../README.md) dẫn theo nhu cầu đọc.
- [SRS](../requirements/SRS.md) là điểm bắt đầu về yêu cầu và giới hạn.
- [Use Case](../use-cases/README.md) chứa sơ đồ và các luồng nghiệp vụ.
- [Dữ liệu](../data/README.md) chứa ERD tổng quan, dictionary và constraints.
- [Thư viện sơ đồ](../diagrams/README.md) giữ các source Mermaid/PlantUML cũ, có bản xem Markdown đầy đủ.
- [API inventory](../reference/api-inventory.md) và [baseline](../reference/source-baseline.md) giúp đối chiếu lần sau.

## Mức xác minh

Đã đối chiếu tĩnh với endpoint, OnModelCreating, snapshot, model, service và firmware; kiểm tra tính nhất quán giữa bản nhúng Mermaid và tệp nguồn, link nội bộ, số bảng và route inventory. Không coi việc đọc test source là chạy test. Kết quả cụ thể xem [biên bản kiểm tra](validation.md); không có tuyên bố nghiệm thu phần cứng hay production trong tài liệu này.
