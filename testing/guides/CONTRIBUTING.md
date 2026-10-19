# Quy ước đóng góp test

## Vị trí và tên file

| Nội dung | Vị trí | Quy ước |
| --- | --- | --- |
| Backend | `backend/tests/` | `<Feature>Tests.cs`; helper dùng chung trong `TestSupport/` |
| Flutter | `frontend/test/` | `<feature>_test.dart` |
| Web E2E | `frontend/e2e/tests/` | `<feature>.spec.cjs`; giữ mã `UI-xx` hiện tại để đối chiếu |
| Script E2E | `frontend/e2e/scripts/` | Setup, runner, đường dẫn và báo cáo |
| Hướng dẫn QA | `testing/guides/` | Markdown, liên kết tương đối từ vị trí tài liệu |
| Bằng chứng | `testing/reports/` | Tách từng phiên, giữ kết quả gốc và exit code |

Các tài liệu `TEST_*.md` và `DEFECTS_AND_BLOCKERS.md` tại `testing/` thuộc bộ hồ sơ backend. Giữ đường dẫn hiện có để liên kết trong báo cáo và công cụ xuất tiếp tục hoạt động.

## Viết và kiểm tra thay đổi

Mỗi test cần thể hiện điều kiện đầu vào, hành động và kết quả mong đợi. Dùng fixture kiểm thử; giữ assertion phản ánh hành vi sản phẩm và ghi rõ giới hạn mô phỏng. Khi thay đổi helper, chạy các test sử dụng helper đó.

Chạy formatter từ gốc checkout có SDK:

```powershell
dotnet format whitespace backend/tests --folder
dart format frontend/test
npx.cmd --yes prettier@3.6.2 --write --single-quote "frontend/e2e/**/*.cjs" "frontend/e2e/package*.json"
```

Kiểm tra lại với `--verify-no-changes` cho .NET, `--output=none --set-exit-if-changed` cho Dart và `--check` thay `--write` cho Prettier. Formatter C# ở chế độ folder không yêu cầu build ứng dụng.

Chạy suite liên quan theo [backend README](../../backend/README.md), [frontend README](../../frontend/README.md) hoặc [E2E README](../../frontend/e2e/README.md). Phân biệt kiểm tra format/cú pháp, discovery và thực thi test trong phần xác minh commit.

## Bàn giao

- Ghi revision ứng dụng và test, môi trường, lệnh chạy, thời gian và exit code.
- Kèm số PASS/FAIL/SKIP cùng liên kết log gốc; không cộng các phiên chạy lại thành tổng ca mới.
- Giữ bằng chứng lịch sử; mô tả rõ kết quả mới thay thế hay bổ sung kết quả nào.
- Kiểm tra `git diff --check` và danh sách file staged trước khi commit; chỉ đưa mã test, công cụ test, tài liệu QA và bằng chứng đã rà soát lên `Test`.
- Cập nhật README khi đổi lệnh chạy, cấu trúc thư mục hoặc vị trí kết quả.
- Bàn giao đầy đủ ảnh, log, JSON/XML, coverage, PDF và trace liên quan đến test; che credential trước khi commit. Dependency, SDK, cấu hình IDE và script cài đặt môi trường nằm ngoài phạm vi bàn giao bằng chứng.
