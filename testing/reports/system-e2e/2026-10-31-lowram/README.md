# Kiểm tra chế độ ít RAM — 31/10/2026

Chỉ cập nhật hạ tầng test và tách fixture trình duyệt; không sửa code ứng dụng.
Chế độ này kiểm tra **17 ca hệ thống**, không chọn 15 ca UI. Không được diễn giải
kết quả của chế độ này thành kết quả toàn bộ 32 ca E2E.

```powershell
node testing/e2e/scripts/run.cjs --low-ram
```

## Kết quả thực tế

- Ứng dụng `a3dc75761cba97f71b9fe3cc80d49773ff89295b` từ main, cache source sạch.
- Hợp đồng `verified-v1`; run ID `1793409739804-7da1d9`.
- **17 PASS / 0 FAIL / 0 skipped / 0 flaky**; test exit `0`, cleanup exit `0`.
- [Kết quả từng ca](results-summary.json) và [kiểm tra giới hạn Docker thực tế](resource-validation.json).
- Xác nhận runner không có executable Chromium nhưng chạy được cả 17 ca API.
- Một mẫu lúc test: API 120.2 MiB, PostgreSQL 60.72 MiB, MQTT 6.949 MiB,
  Mailpit 25.27 MiB, runner 227.6 MiB — khoảng 441 MiB tổng container tại thời điểm đó,
  không phải mức đỉnh và chưa gồm Docker VM/Windows.
- Discovery vẫn đủ 32 ca; fixture diagnostics browser được đối chiếu nguyên vẹn.
  Không chạy lại 15 ca UI trong phiên này, không tuyên bố UI PASS.
- SYS-13 PASS trong phiên này không chứng minh lỗi timing ở phiên trước đã được sửa.
  Không thay assertion hoặc code scheduler. Bằng chứng phiên trước giữ riêng.
- Builder và toàn bộ container/network/volume của phiên được dọn xong.

## Thay đổi cấu hình

- Không build Flutter/nginx frontend; không tải hoặc chạy Chromium trong runner Node.
- Playwright vẫn dùng API client, PostgreSQL/MQTT/SMTP là dịch vụ thật.
- Tách auto fixture diagnostics có phụ thuộc `page` khỏi test hệ thống. Nội dung
  diagnostics của browser được giữ nguyên, chỉ chuyển sang `browser-fixtures.cjs`.
- Giữ nguyên assertion và timeout của test hệ thống; một worker, không tự retry.
- Builder riêng: giới hạn 1536 MiB/1 CPU, build tuần tự, không thêm swap; xóa trước pha test.
- Container API 640 MiB, PostgreSQL 256 MiB, MQTT 64 MiB, Mailpit 128 MiB,
  runner 512 MiB. Tổng trần 1600 MiB; không thêm swap ngoài giới hạn RAM container.
- Không sửa builder mặc định, Docker Desktop/WSL hay dữ liệu ứng dụng trên máy người dùng.
- File `run.json` và report Playwright ghi chế độ; terminal in phạm vi và số PASS/FAIL.
- Lệnh không có `--low-ram` vẫn chọn chế độ đầy đủ 32 ca như trước.

## Giới hạn

Các trần container không bao gồm Docker VM/WSL, Docker daemon, filesystem cache,
hệ điều hành và các ứng dụng khác. Không phải cam kết tổng RAM máy chỉ dùng 1.6 GB.
Chưa xác nhận trên máy vật lý 4 GB hoặc 8 GB. Không đưa ra tỷ lệ giảm RAM so với
chế độ cũ vì chưa có phép đo đối chứng cùng điều kiện.
Build đầu tiên vẫn cần tải image và package; builder tạm có thể cần tải lại SDK ở lần sau.
Giới hạn tài nguyên có thể gây timeout/OOM nếu môi trường không đủ, khi đó báo lỗi;
không có fallback chạy không giới hạn, không sửa ứng dụng để làm test PASS.

Xem [cách chạy và chọn hợp đồng xác thực](../../../e2e/README.md).
