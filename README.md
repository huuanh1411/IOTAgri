# IOTAgri · Quality Assurance

Kho mã kiểm thử và bằng chứng QA cho hệ thống nông nghiệp thông minh IOTAgri.
Nhánh `Test` tập trung test backend, test Flutter và test giao diện web; mã nguồn ứng dụng được quản lý trên `main`.

## Bắt đầu từ đâu?

| Nhu cầu | Tài liệu |
| --- | --- |
| Chạy test backend | [Backend testing](backend/README.md) |
| Chạy test Flutter | [Frontend testing](frontend/README.md) |
| Chạy test giao diện web | [Playwright E2E](frontend/e2e/README.md) |
| Xem báo cáo và lỗi backend đã ghi nhận | [QA reports](testing/README.md) |
| Hiểu TRX, registry JSON và coverage | [Hướng dẫn đọc kết quả](testing/guides/RESULTS_GUIDE.md) |
| Bổ sung test và bàn giao kết quả | [Quy ước đóng góp](testing/guides/CONTRIBUTING.md) |

## Cấu trúc thư mục

```text
.
├── backend/
│   ├── README.md                    # Môi trường và cách chạy backend test
│   └── tests/                       # xUnit, Moq, HTTP và PostgreSQL fixtures
│       └── TestSupport/             # Host, test doubles và database fixture
├── frontend/
│   ├── README.md                    # Hướng dẫn Flutter và danh mục kiểm thử
│   ├── test/                        # Unit, provider, repository và widget tests
│   └── e2e/
│       ├── README.md                # Cài đặt và chạy Playwright
│       ├── playwright.config.cjs    # Viewport, timeout và web server
│       ├── package.json             # Lệnh npm và dependencies
│       ├── scripts/                 # Setup, runner và xuất báo cáo
│       └── tests/                   # Các kịch bản UI
└── testing/
    ├── README.md                    # Chỉ mục tài liệu và bằng chứng
    ├── guides/                      # Cách đọc kết quả và quy ước QA
    ├── TEST_*.md                    # Phạm vi, chiến lược, ca test và báo cáo BE
    ├── DEFECTS_AND_BLOCKERS.md       # Lỗi backend đã xác nhận
    ├── run-backend-tests.ps1         # Runner backend có lưu exit code
    ├── build-test-reports.py         # Chuyển TRX/coverage thành báo cáo
    ├── finalize-qa-records.py        # Công cụ hoàn thiện hồ sơ QA backend
    ├── coverage.runsettings         # Cấu hình đo coverage backend
    └── reports/
        ├── coverage/                # Coverage và TRX backend đã lưu
        ├── junit/                   # JUnit chuyển đổi từ kết quả backend
        ├── summary/                 # Tổng hợp, registry, log và integrity
        └── frontend/                # Quy ước lưu kết quả Flutter/E2E mới
```

Giữ các thư mục test ở đường dẫn chuẩn của dự án để có thể đưa chúng vào checkout ứng dụng mà không sửa import hoặc project reference. Đường dẫn bằng chứng backend lịch sử được giữ nguyên để đối chiếu báo cáo.

## Trạng thái bằng chứng

| Bộ kiểm thử | Nội dung trên nhánh | Kết quả được lưu |
| --- | --- | --- |
| Backend | 44 file test C# và 3 helper trong `TestSupport/` | Phiên `followup-final`: **345 ca, 339 PASS, 6 FAIL**, ngày 14/10/2026 |
| Flutter | 17 file Dart trong `frontend/test/` | Chưa đưa kết quả thực thi frontend lên nhánh này |
| Web E2E | 11 kịch bản × 3 viewport, **33 ca được discovery** | Discovery chỉ xác nhận danh sách ca, chưa chứng minh test PASS |

Số liệu backend thuộc mã nguồn nền [`318fca1`](https://github.com/huuanh1411/IOTAgri/tree/318fca181741c95e73b56808ebe04a65a3ee0466), không đại diện cho trạng thái hiện tại của `main`. Sáu ca FAIL lịch sử được giữ nguyên trong bằng chứng; xem [báo cáo backend](testing/TEST_REPORT.md).

## Chuẩn bị checkout để chạy test

Nhánh này thiếu mã ứng dụng nên không build độc lập. Trong một checkout ứng dụng sạch, lấy đúng các file kiểm thử:

```powershell
git fetch origin
git restore --source=origin/Test -- backend/tests frontend/test frontend/e2e testing
```

Lệnh trên thay thế file trùng đường dẫn; lưu chỉnh sửa test local trước khi dùng. Chọn revision ứng dụng phù hợp với suite. Khi tái hiện báo cáo backend lịch sử, dùng revision nền đã ghi ở trên.

| Suite | Môi trường | Lệnh từ gốc checkout ứng dụng |
| --- | --- | --- |
| Backend | .NET SDK 10, Docker Linux/PostgreSQL 17, Python 3 | `powershell -NoProfile -ExecutionPolicy Bypass -File testing/run-backend-tests.ps1 -RunName local-review` |
| Flutter | Flutter với Dart tương thích `frontend/pubspec.yaml` | `cd frontend`, `flutter pub get`, `flutter test` |
| Web E2E | Node.js ≥20, Chrome, Python 3, FE build web và BE local | `npm.cmd ci --prefix frontend/e2e`, `npm.cmd test --prefix frontend/e2e` |

Chi tiết về biến môi trường, phạm vi kiểm thử và cách lấy báo cáo nằm trong README của từng suite. Trên macOS/Linux, dùng `npm` thay cho `npm.cmd`.

## Quy tắc quản lý kết quả

- Mỗi lần chạy có tên hoặc thư mục riêng; ghi revision ứng dụng, môi trường và exit code.
- Kết quả backend lịch sử trong `testing/reports/` được giữ để kiểm chứng. Kết quả frontend mới được tạo local và gitignore theo mặc định.
- Fixture đăng nhập, dependency, build output và trace thô được gitignore. Chỉ commit bằng chứng đã rà soát.
- Thay đổi cách tổ chức hoặc tài liệu không đồng nghĩa đã chạy lại test hay xác nhận các lỗi cũ đã được sửa.
