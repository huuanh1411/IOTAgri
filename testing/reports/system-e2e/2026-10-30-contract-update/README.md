# E2E: cập nhật cấu hình theo hợp đồng xác thực — 30/10/2026

Chỉ thay đổi bộ test, cấu hình chạy và tài liệu. Không sửa backend/frontend,
không tự sửa lỗi ứng dụng, không retry hoặc bỏ qua ca FAIL để tạo kết quả PASS.

## Main mới nhất tại thời điểm kiểm tra

- Ứng dụng: `a3dc75761cba97f71b9fe3cc80d49773ff89295b`, tải từ `refs/heads/main`.
- Chế độ: `verified-v1`; đăng ký 202, xác thực email 204, đăng nhập 200.
- Chạy đầy đủ **32 ca: 30 PASS / 2 FAIL / 0 skipped / 0 flaky**.
- Test exit `1`; cleanup exit `0`. Không có lỗi global setup.
- [Kết quả từng ca và lỗi assertion](latest-main.json).

| Ca FAIL | Quan sát | Giới hạn kết luận |
|---|---|---|
| SYS-13 / system | Không thấy MQTT command có source `scheduled` trong 30 giây sau khi tạo lịch bơm | Cần điều tra scheduler và cửa sổ thời gian; chưa khẳng định nguyên nhân gốc |
| WEB-04 / mobile 390×844 | Sau thao tác BẬT BƠM, không tìm được nút chọn `30 giây`; không có response tạo lệnh bơm trong thời gian chờ | Có thể liên quan thao tác tự động/semantics Flutter; chưa đủ bằng chứng kết luận bơm thực tế hỏng |

Các ca desktop và small-mobile PASS. WEB-01 đăng ký/xác thực email/đăng nhập PASS
trên cả ba viewport. Lỗi trên được giữ nguyên để người phụ trách điều tra.

## Commit của bạn người dùng: đăng ký trực tiếp

- Ứng dụng nguyên bản: `202ffb8e7cc01440cae2ebd93f96df634b19a831`.
- Chế độ: `direct-v1`; đăng ký 201 và đăng nhập ngay.
- Lệnh lọc: `node testing/e2e/scripts/run.cjs --grep 'SYS-01|WEB-01'`.
- **4 PASS / 0 FAIL / 0 skipped**: SYS-01 và WEB-01 trên ba viewport.
- Global setup tạo tài khoản/đăng nhập thành công; test exit `0`, cleanup exit `0`.
- [Kết quả từng ca](direct-registration.json).
- Đây là kiểm tra tập trung cho phần cấu hình xác thực đã thay đổi, không phải kết quả
  toàn bộ 32 ca trên commit này; 28 ca khác không được chọn chạy trong phiên này.

Nếu bạn đang ở checkout `202ffb8...` có thư mục test cũ:

```powershell
git fetch origin
git restore --source=origin/Test -- testing/e2e
$env:E2E_AUTH_CONTRACT='direct-v1'
node testing/e2e/scripts/run.cjs
Remove-Item Env:E2E_AUTH_CONTRACT
```

Lệnh này chạy toàn bộ suite trên code local; các lỗi khác vẫn được báo FAIL.

## Cách cấu hình và tái lập

Xem [hướng dẫn chạy](../../../e2e/README.md). Khi chạy riêng nhánh Test,
runner fetch main mới nhất mỗi lần và ghi SHA đã chốt trong `run.json`.
Để tái lập phiên main này:

```powershell
$env:E2E_APP_REV='a3dc75761cba97f71b9fe3cc80d49773ff89295b'
$env:E2E_AUTH_CONTRACT='verified-v1'
node testing/e2e/scripts/run.cjs
```

Nếu chạy trong checkout có ứng dụng, bộ test dùng code local thay vì tải remote.
Không tự pull/reset code local. Phải chọn hợp đồng theo yêu cầu nghiệp vụ trước khi chạy;
không đổi hợp đồng chỉ vì ứng dụng trả status khác mong đợi.

Các file JSON ở đây là bản tóm tắt từ kết quả Playwright, không chứa token/mật khẩu.
Log, HTML, video, screenshot và trace đầy đủ được lưu tại thư mục artifacts theo run ID
trên máy chạy, không đưa các trace chứa phiên đăng nhập lên Git.
Các bằng chứng lịch sử trong thư mục `2026-10-30/` được giữ riêng, không cộng gộp kết quả.
