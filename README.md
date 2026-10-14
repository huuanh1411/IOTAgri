# IOTAgri — Hướng dẫn đọc dữ liệu kiểm thử

Nhánh `Test` lưu mã kiểm thử backend trong `backend/tests/` và tài liệu, dữ liệu kết quả trong `testing/`. Nhánh này không chứa mã nguồn ứng dụng; có thể đọc báo cáo trực tiếp trên GitHub mà không cần cài môi trường.

## 1. Đọc nhanh kết quả

Lần chạy mới nhất được lưu là **`followup-final`**, bắt đầu lúc **01:42:13 ngày 14/10/2026 (UTC+07:00)**, trên mã nguồn nền `318fca181741c95e73b56808ebe04a65a3ee0466`.

| Chỉ số | Kết quả đã ghi nhận |
| --- | --- |
| Test case đã chạy | 345 |
| PASS / FAIL | 339 / 6 |
| Skipped / error / aborted | 0 / 0 / 0 |
| Phương thức test / file test | 212 / 44 |
| Nhóm lỗi xác nhận | 4 |
| Line coverage | 1399/2071, khoảng 67,55% |
| Branch coverage | 463/760, khoảng 60,92% |
| Exit code của lần chạy | 1 — còn test thất bại |

Đây là kết quả của lần chạy đã lưu, không phải kết quả tự động cập nhật theo `main`. Một phương thức có nhiều dòng dữ liệu `[InlineData]` có thể tạo nhiều test case, nên 212 phương thức tương ứng 345 ca thực thi. PASS chỉ cho biết các assertion của ca đó đạt; không chứng minh toàn bộ backend đã đúng.

## 2. Thứ tự đọc tài liệu

| Thứ tự | File | Đọc để biết |
| --- | --- | --- |
| 1 | [TEST_REPORT.md](testing/TEST_REPORT.md) | Kết luận tổng thể, kết quả, phạm vi đã kiểm tra và giới hạn còn lại. |
| 2 | [DEFECTS_AND_BLOCKERS.md](testing/DEFECTS_AND_BLOCKERS.md) | Lỗi BE-001 đến BE-004: cách tái hiện, expected/actual, bằng chứng; phân biệt lỗi xác nhận, rủi ro và khoảng trống kiểm thử. |
| 3 | [TEST_CASES.md](testing/TEST_CASES.md) | Từng ca: dữ liệu đầu vào, thân test, assertion, mã `TC-BE-...`, PASS/FAIL và liên kết bằng chứng. |
| 4 | [TEST_EXECUTION_LOG.md](testing/TEST_EXECUTION_LOG.md) | Lịch sử các lần chạy, môi trường, lệnh đã dùng và danh sách ca thất bại cuối cùng. |
| 5 | [Coverage SUMMARY.md](testing/reports/coverage/SUMMARY.md) | Mức bao phủ theo module và file mã nguồn. |
| 6 | [TEST_SCOPE_AND_INVENTORY.md](testing/TEST_SCOPE_AND_INVENTORY.md) | Danh mục mã nguồn, phạm vi đã khảo sát và các phần cần kiểm tra thêm. |
| 7 | [TEST_STRATEGY.md](testing/TEST_STRATEGY.md) | Cách tổ chức unit/component/integration test, cách cô lập môi trường và giới hạn của từng loại test. |

[testing/README.md](testing/README.md) là hướng dẫn kỹ thuật bàn giao và chạy lại suite.

## 3. Tra cứu một test case

Ví dụ cần xem lỗi đăng nhập tài khoản bị khóa:

1. Mở [DEFECTS_AND_BLOCKERS.md](testing/DEFECTS_AND_BLOCKERS.md), tìm `BE-001` để đọc hành vi mong đợi và thực tế.
2. Mở [TEST_CASES.md](testing/TEST_CASES.md), tìm `TC-BE-F21073B388` hoặc `Locked_user_with_correct_password_must_not_receive_tokens`.
3. Đọc phần **Preconditions**, thân test và bảng **Expected Result / Actual Result / Status**. Với ca có tham số, đọc đúng dòng dữ liệu của ca đó.
4. Mở file test qua liên kết để xem fixture và ngữ cảnh đầy đủ.
5. Đối chiếu với [registry JSON](testing/reports/summary/test-case-registry.json), [TRX gốc](testing/reports/coverage/followup-final/backend-tests.trx) và [console log](testing/reports/summary/followup-final-test.log).

Trong TRX, dùng `trx_test_id` hoặc `trx_execution_id` của registry để tìm đúng bản ghi. Trong console log, tìm tên phương thức; log không nhất thiết chứa mã `TC-BE-...`.

| Nhóm lỗi | Nội dung | Số ca FAIL trong lần chạy mới nhất |
| --- | --- | --- |
| BE-001 | Tài khoản bị khóa vẫn có thể nhận token đăng nhập | 2 |
| BE-002 | Rollback migration PostgreSQL thất bại | 1 |
| BE-003 | Trả lời ticket không lưu được tin nhắn mới | 2 |
| BE-004 | HTTP tạo thiết bị chấp nhận tên chỉ có khoảng trắng | 1 |

Các mục `RISK-*` và `GAP-*` không tự động được tính là ca FAIL hay SKIPPED. Xem giới hạn tái hiện trong tài liệu lỗi, đặc biệt với HTTP host được dựng riêng cho kiểm thử.

## 4. Các file dữ liệu trong reports

Các đường dẫn trong bảng dưới đây tính từ `testing/reports/`.

| File / thư mục | Ý nghĩa và cách đọc |
| --- | --- |
| [summary/results.json](testing/reports/summary/results.json) | Tổng hợp lần chạy. `run` xác định phiên; `test_counters` chứa số ca; `trx_times` chứa thời gian; `totals` chứa số dòng/nhánh được bao phủ và tổng số được đo. |
| [summary/test-case-registry.json](testing/reports/summary/test-case-registry.json) | Mảng bản ghi cho từng ca thực thi: ID, tên test, kết quả, mã lỗi, vị trí mã nguồn và ID đối chiếu TRX. |
| [coverage/followup-final/backend-tests.trx](testing/reports/coverage/followup-final/backend-tests.trx) | Kết quả XML gốc của test runner: outcome, thời gian, thông báo lỗi và stack trace. Dùng khi cần kiểm chứng báo cáo tổng hợp. |
| [junit/backend-tests.xml](testing/reports/junit/backend-tests.xml) | Kết quả chuyển sang XML JUnit để công cụ báo cáo/CI có thể đọc; vẫn giữ ca thất bại. |
| [summary/followup-final-test.log](testing/reports/summary/followup-final-test.log) | Console output của lần chạy mới nhất. File `.log.exitcode` đi kèm ghi mã kết thúc; `.log.restore` ghi bước restore package. |
| [coverage/SUMMARY.md](testing/reports/coverage/SUMMARY.md) | Bảng coverage dễ đọc cho người xem. |
| [coverage/coverage.cobertura.xml](testing/reports/coverage/coverage.cobertura.xml) | Coverage ở định dạng Cobertura, chứa số lượt thực thi và thông tin theo dòng. |
| [coverage/coverage.json](testing/reports/coverage/coverage.json) | Coverage chi tiết do Coverlet xuất ra, gồm dữ liệu dòng và nhánh theo lớp/phương thức. |
| `coverage/followup-final/<id>/` | Dữ liệu collector gốc của lần chạy, có thể có bản sao dưới thư mục tên máy/người dùng. Các bản sao không phải các lần chạy độc lập. |
| [summary/backend-integrity.json](testing/reports/summary/backend-integrity.json) | Kết quả so sánh mã nguồn/config trước và sau phiên QA. Đây là bằng chứng tại thời điểm đã ghi, không kiểm tra trạng thái repo hiện tại. |
| [summary/backend-source-before.json](testing/reports/summary/backend-source-before.json), [backend-source-after.json](testing/reports/summary/backend-source-after.json) | Manifest và SHA-256 dùng để đối chiếu sự thay đổi của mã nguồn/config. |
| Các log `baseline*`, `iteration*`, `reviewed-existing*` | Lịch sử thử build và xử lý môi trường. Không coi chúng là lần chạy test thành công. |

### Đọc JSON tổng hợp

Trong `results.json`:

- `test_counters.executed`, `passed`, `failed`: số ca thực thi, đạt và thất bại.
- `test_methods`, `test_files`: số phương thức và file test, không phải số ca thực thi.
- `totals.lines_covered / totals.lines_valid`: tỷ lệ bao phủ dòng.
- `totals.branches_covered / totals.branches_valid`: tỷ lệ bao phủ nhánh.
- Mỗi phần tử trong `files` có dạng `[lines_covered, lines_valid, branches_covered, branches_valid]` của file mã nguồn đó.

Trong `test-case-registry.json`:

- `id`: mã ổn định `TC-BE-...` của ca.
- `test_name`: tên đầy đủ, gồm tham số nếu có; `fqn`: tên phương thức đầy đủ.
- `status`, `actual`, `defect`: kết quả, mô tả thực tế và mã lỗi liên quan.
- `file`, `line`: vị trí định nghĩa test; `setup`, `body`, `expected`: chuẩn bị dữ liệu, thân test và assertion.
- `trx_test_id`, `trx_execution_id`, `duration`: thông tin đối chiếu với kết quả gốc.

### Đọc coverage đúng cách

**Line coverage** đo tỷ lệ dòng được thực thi; **branch coverage** đo tỷ lệ nhánh được thực thi. Cả hai không phải tỷ lệ test PASS hoặc tỷ lệ chức năng đã hoàn thành. `N/A` ở branch coverage nghĩa là không có nhánh được đo, không phải 0%.

Coverage đã lưu loại migration, file sinh tự động trong `obj` và test assembly khỏi phép đo. `Program.cs` vẫn nằm trong mẫu số; HTTP component host không chạy startup thật nên coverage của file này là 0%. Không có chỉ số instruction coverage trong dữ liệu collector này.

Một số liên kết từ báo cáo coverage tới mã nguồn ứng dụng sẽ không mở được trên nhánh `Test`, vì nhánh chỉ giữ test. Đối chiếu file tương ứng ở [mã nguồn nền 318fca1](https://github.com/huuanh1411/IOTAgri/tree/318fca181741c95e73b56808ebe04a65a3ee0466/backend).

## 5. Phân biệt dữ liệu mới nhất và lịch sử

Trong `coverage/` có các lần chạy `run`, `verified`, `acceptance`, `final`, `postgres-followup`, `postgres-expanded`, `http-followup` và **`followup-final`**. Dùng `results.json.run` và `TEST_EXECUTION_LOG.md` để xác định lần chạy cần đọc; tên `final` không phải lần mới nhất.

Không cộng số ca của các lần chạy với nhau: nhiều ca được chạy lại. Khi trích số liệu, dùng TRX, log và coverage thuộc cùng một phiên. Các file coverage ở ngay `coverage/` là bản xuất ổn định của lần mới nhất được ghi nhận.

Một số tài liệu lịch sử vẫn nhắc đến công cụ hoặc log graphify đã được loại khỏi nhánh `Test`; chúng không phải dữ liệu để tính kết quả kiểm thử.

## 6. Đọc và lọc dữ liệu trên máy

Trên GitHub, Markdown có thể xem trực tiếp; JSON/XML/log lớn có thể cần bấm **Raw** hoặc tải xuống rồi mở bằng VS Code. Nếu log hiển thị sai ký tự, chọn lại encoding phù hợp, thường là UTF-16 LE với log được PowerShell 5.1 ghi.

Để lấy file về thư mục làm việc đang có mã nguồn ứng dụng, chạy từ gốc repo:

```powershell
git fetch origin
git restore --source=origin/Test -- backend/tests testing
```

Lệnh restore thay thế các file test trùng đường dẫn bằng phiên bản từ `Test`; lưu các chỉnh sửa test local cần giữ trước khi chạy. Nó không tự commit hay push lên `main`.

Xem số ca và lọc các ca lỗi bằng PowerShell:

```powershell
$qaSummary = Get-Content testing/reports/summary/results.json -Raw | ConvertFrom-Json
$qaSummary.run
$qaSummary.test_counters

$qaCases = Get-Content testing/reports/summary/test-case-registry.json -Raw | ConvertFrom-Json
$qaCases | Where-Object { $_.status -eq 'FAIL' } |
    Select-Object id, test_name, defect, actual | Format-List
```

## 7. Khi cần chạy lại test

Cần mã nguồn ứng dụng nền cùng các file test, .NET SDK 10, Docker Desktop chạy Linux containers, image PostgreSQL 17 hoặc quyền tải image, package cache/NuGet và Python 3. Nhánh `Test` đứng riêng không đủ để build.

Từ repo có mã nguồn nền và đã lấy file test như trên:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File testing/run-backend-tests.ps1 -RunName local-review
python testing/build-test-reports.py --run local-review
```

Dùng tên phiên mới để giữ lịch sử cũ. Vẫn chạy lệnh tạo báo cáo khi test kết thúc với mã 1 nếu đã có TRX/coverage. Nếu restore/build thất bại và chưa tạo dữ liệu, đọc log để xử lý môi trường trước.

Fixture PostgreSQL tạo database/container riêng cho kiểm thử. Kết quả mới có thể khác dữ liệu đã lưu nếu mã nguồn hoặc môi trường thay đổi. Đọc [hướng dẫn kỹ thuật](testing/README.md) và [chiến lược test](testing/TEST_STRATEGY.md) trước khi chạy lại.
