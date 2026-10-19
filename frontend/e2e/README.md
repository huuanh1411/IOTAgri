# Web E2E · Playwright

11 kịch bản UI chạy trên ba viewport: mobile `390×844`, small-mobile `320×568` và desktop `1280×900`. Tổng cộng 33 ca được discovery. Đây là kiểm thử Chrome ở các kích thước màn hình, không thay thế test Android/iOS native.

## Chuẩn bị

1. Dùng checkout ứng dụng có mã frontend, backend và các file test từ nhánh `Test`.
2. Cài Node.js ≥20, Google Chrome, Python 3 và Flutter SDK của dự án.
3. Khởi động backend kiểm thử ở `http://localhost:5261`; `/health` phải trả `status: ready`.
4. Build frontend trỏ vào backend kiểm thử:

```powershell
cd frontend
flutter pub get
flutter build web --dart-define=API_BASE_URL=http://localhost:5261
cd ..
npm.cmd ci --prefix frontend/e2e
```

Playwright dùng Chrome có sẵn. Web server mặc định phục vụ `frontend/build/web` qua Python ở cổng 3000. Suite bật Flutter semantics để tương tác với giao diện.

## Chạy

Các lệnh dưới đây chạy từ gốc repo:

```powershell
# Kiểm tra danh sách ca; không chạy setup hay đăng nhập
npm.cmd run test:list --prefix frontend/e2e

# Chạy toàn bộ hoặc hai viewport mobile
npm.cmd test --prefix frontend/e2e
npm.cmd run test:mobile --prefix frontend/e2e

# Chạy một kịch bản trên desktop
npm.cmd test --prefix frontend/e2e -- --project=desktop --grep UI-01
```

Trên macOS/Linux dùng `npm`. Xem HTML report Playwright gần nhất bằng `npm.cmd run report --prefix frontend/e2e`.

## Biến môi trường

| Biến | Mặc định | Ý nghĩa |
| --- | --- | --- |
| `FE_URL` | `http://localhost:3000` | URL frontend; FE ngoài cổng mặc định phải được phục vụ sẵn |
| `API_URL` | `http://localhost:5261` | Backend dùng để tạo tài khoản test; phải khớp API của bản build frontend |
| `E2E_REPORT_DIR` | `testing/reports/frontend/e2e/<UTC-timestamp>-<pid>/` | Thư mục báo cáo; đường dẫn tương đối tính từ gốc repo |

Ví dụ PowerShell:

```powershell
$env:E2E_REPORT_DIR = 'testing/reports/frontend/e2e/local-review'
npm.cmd test --prefix frontend/e2e
```

Dùng thư mục mới cho mỗi phiên; nếu chỉ định lại cùng đường dẫn, các file báo cáo cùng tên sẽ được ghi đè.

## Kết quả và dữ liệu phiên

- Báo cáo xuất: `index.html`, `BAO_CAO_UI.txt`, `results.json`, ảnh, `runner.log` và `exit-code.txt` trong thư mục báo cáo của phiên.
- Playwright gốc: `test-results/` và `playwright-report/` trong thư mục E2E; đây là kết quả local gần nhất.
- Có thể xuất lại JSON Playwright gần nhất: `npm.cmd run report:export --prefix frontend/e2e`. Lệnh này tạo báo cáo mới từ dữ liệu cũ, không chạy lại test.

Setup tạo một tài khoản `@example.test` qua API local và lưu fixture trong `.auth/`. Tài khoản không tự xóa sau khi chạy. Suite không gửi lệnh điều khiển phần cứng. Credential, trace và báo cáo local được gitignore; rà soát nội dung trước khi bàn giao bằng chứng.

Exit code của test được giữ nguyên khi test FAIL. Nếu tiến trình kết thúc bất thường hoặc xuất báo cáo gặp lỗi, runner trả mã khác 0. Nhánh này chưa lưu kết quả chạy đầy đủ E2E; discovery không phải kết quả PASS.

## Cấu trúc

```text
e2e/
├── playwright.config.cjs
├── package.json / package-lock.json
├── scripts/
│   ├── paths.cjs       # Đường dẫn chung và thư mục báo cáo theo phiên
│   ├── setup.cjs       # Kiểm tra BE và tạo fixture
│   ├── run.cjs         # Chạy Playwright, lưu log và exit code
│   └── report.cjs      # Xuất HTML, văn bản và JSON
└── tests/
    └── ui.spec.cjs
```
