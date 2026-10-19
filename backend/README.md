# Backend testing

Suite xUnit kiểm tra hợp đồng dữ liệu, quy tắc nghiệp vụ, handler, endpoint HTTP và tích hợp PostgreSQL. Mã test nằm trong [`tests/`](tests/); fixture và host hỗ trợ nằm trong [`tests/TestSupport/`](tests/TestSupport/).

## Môi trường

- Checkout ứng dụng có `backend/IOTAgriBackend.csproj`, đi kèm các file từ nhánh `Test`.
- .NET SDK 10 và NuGet/package cache; Python 3 để tạo báo cáo.
- Docker Desktop chạy Linux containers, image `postgres:17-alpine` cho test PostgreSQL/HTTP.

Fixture tạo database và container kiểm thử riêng, sau đó dọn tài nguyên của nó. Suite không yêu cầu broker MQTT hay phần cứng thật. HTTP host được dựng riêng cho test và không thực thi startup đầy đủ trong `Program.cs`.

## Chạy và xuất báo cáo

Chạy từ gốc checkout ứng dụng, dùng tên phiên mới:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testing/run-backend-tests.ps1 -RunName local-review
python testing/build-test-reports.py --run local-review
```

Lệnh thứ hai vẫn cần chạy khi test trả exit code 1 nhưng đã có TRX/coverage. Nếu restore/build thất bại và chưa sinh kết quả, xử lý log trước khi xuất báo cáo.

| Dữ liệu | Đường dẫn từ gốc repo |
| --- | --- |
| TRX và collector gốc | `testing/reports/coverage/<RunName>/` |
| Console và exit code | `testing/reports/summary/<RunName>-test.log*` |
| Tổng hợp, registry | `testing/reports/summary/` |
| Coverage đã xuất | `testing/reports/coverage/SUMMARY.md` |

Converter cập nhật các bản tổng hợp ở đường dẫn ổn định; giữ kết quả phiên gốc để đối chiếu. `finalize-qa-records.py` còn kiểm tra manifest integrity của phiên QA gốc, nên cần đúng checkout và manifest tương ứng; đây không phải bước bắt buộc cho mọi lần chạy local.

## Hiểu kết quả

Phiên backend đã lưu `followup-final` chạy trên revision `318fca181741c95e73b56808ebe04a65a3ee0466`: 345 ca, 339 PASS, 6 FAIL. Đây là bằng chứng lịch sử, không phải kết quả của revision hiện tại.

Đọc [chiến lược và giới hạn](../testing/TEST_STRATEGY.md), [lỗi đã xác nhận](../testing/DEFECTS_AND_BLOCKERS.md) và [hướng dẫn đọc dữ liệu](../testing/guides/RESULTS_GUIDE.md).
