# Web UI · Báo cáo kiểm thử

[← Tổng quan frontend](../README.md) · [Thư viện ảnh](screenshots/README.md) · [PDF](Bao_cao_loi_giao_dien_FE_2026-10-19.pdf) · [Log](runner.log)

**00:09:36 19/10/2026 (UTC+07:00)** · Chrome 155.0.8059.82 · Mã ứng dụng `2a87c1d`

**33 ca riêng biệt · 22 PASS · 10 FAIL · 1 TIMEOUT**

> Đây là kết quả đã lưu của ngày 19/10/2026. Không chạy lại test khi tạo trang này. Các báo cáo gốc gộp FAIL và TIMEOUT thành 11 ca chưa đạt.

## Kết quả theo màn hình

| Viewport | Kích thước | PASS | FAIL | TIMEOUT | Tổng |
| --- | --- | ---: | ---: | ---: | ---: |
| mobile | 390 × 844 | 8 | 3 | 0 | 11 |
| small-mobile | 320 × 568 | 6 | 4 | 1 | 11 |
| desktop | 1280 × 900 | 8 | 3 | 0 | 11 |

## Ma trận 11 kịch bản × 3 viewport

Bấm mã kịch bản để mở nhóm ảnh tương ứng.

| Kịch bản | Nội dung | Mobile | Small-mobile | Desktop |
| --- | --- | --- | --- | --- |
| [UI-01](screenshots/README.md#ui-01) | Hiển thị đăng nhập và nút bấm trên viewport | ✅ PASS | ✅ PASS | ✅ PASS |
| [UI-02](screenshots/README.md#ui-02) | Validate đăng nhập bỏ trống | ✅ PASS | ✅ PASS | ✅ PASS |
| [UI-03](screenshots/README.md#ui-03) | Validate đăng ký | ✅ PASS | ✅ PASS | ✅ PASS |
| [UI-04](screenshots/README.md#ui-04) | Đăng nhập sai thông tin với BE thật | ❌ FAIL | ❌ FAIL | ❌ FAIL |
| [UI-05](screenshots/README.md#ui-05) | Đăng nhập thành công và khôi phục phiên | ✅ PASS | ✅ PASS | ✅ PASS |
| [UI-06](screenshots/README.md#ui-06) | Tab cảnh báo và chọn giống | ✅ PASS | ✅ PASS | ✅ PASS |
| [UI-07](screenshots/README.md#ui-07) | Trang tài khoản và cài đặt | ✅ PASS | ❌ FAIL | ✅ PASS |
| [UI-08](screenshots/README.md#ui-08) | Đăng xuất và xóa phiên | ✅ PASS | ⏱ TIMEOUT | ✅ PASS |
| [UI-09](screenshots/README.md#ui-09) | Xử lý mất kết nối backend | ❌ FAIL | ❌ FAIL | ❌ FAIL |
| [UI-10](screenshots/README.md#ui-10) | Màn hình hỗ trợ và lịch sử thu hoạch | ✅ PASS | ✅ PASS | ✅ PASS |
| [UI-11](screenshots/README.md#ui-11) | Đồng bộ lựa chọn tiếng Việt với dashboard | ❌ FAIL | ❌ FAIL | ❌ FAIL |

## Những vấn đề đã ghi nhận

### F-01 — Không hiện phản hồi khi đăng nhập thất bại hoặc mất kết nối

Nhập thông tin sai: BE trả 401 nhưng FE không hiện thông báo trong thời gian chờ 12 giây. Khi chặn kết nối login cũng chưa thấy thông báo. Người dùng ở lại màn hình đăng nhập mà không biết lý do.

**Ca liên quan:** `mobile/UI-04`, `mobile/UI-09`, `small-mobile/UI-04`, `small-mobile/UI-09`, `desktop/UI-04`, `desktop/UI-09`.

<details>
<summary>Phân tích nguồn đã ghi trong báo cáo gốc</summary>

Dấu hiệu nguyên nhân từ mã: AuthState.copyWith mặc định đặt error=null; login catch gán error rồi finally gọi copyWith(isLoading:false) xóa error ngay. AuthScreen đọc error trong build nên có thể không kịp dựng SnackBar. Đây là phân tích nguồn, cần sửa và chạy lại để xác nhận.

</details>

### F-02 — Trang tài khoản có nội dung vượt khỏi màn hình

Trên viewport nhỏ, nút đăng xuất không hiển thị/không nằm đầy đủ trong vùng nhìn thấy. Ảnh xác nhận phần dưới trang tài khoản bị cắt; MoreScreen dùng Column cố định, không có cuộn cho toàn bộ nội dung. Vì vậy ca đăng xuất trên màn hình này cũng có thể không thao tác được.

**Ca liên quan:** `small-mobile/UI-07`, `small-mobile/UI-08`.

<details>
<summary>Phân tích nguồn đã ghi trong báo cáo gốc</summary>

Vị trí cần xem: frontend/lib/screens/more_screen.dart. Chưa sửa bố cục trong lượt test này.

</details>

### F-03 — Dashboard chưa theo đúng lựa chọn tiếng Việt

Cài đặt đánh dấu Tiếng Việt nhưng dashboard vẫn hiển thị Good morning và UI's Garden, trong khi các nhãn khác là tiếng Việt. Ca test kiểm tra lựa chọn radio trước khi quay lại dashboard.

**Ca liên quan:** `mobile/UI-11`, `small-mobile/UI-11`, `desktop/UI-11`.

<details>
<summary>Phân tích nguồn đã ghi trong báo cáo gốc</summary>

Vị trí cần xem: frontend/lib/app.dart truyền locale nhưng chưa khai báo supportedLocales/delegates cho tiếng Việt; HomeScreen đọc Localizations.localeOf(context), còn nhãn điều hướng đọc AppSettingsProvider. Hai nguồn locale có thể lệch nhau.

</details>

## Tra cứu ca chưa đạt

| Ca / viewport | Trạng thái | Thời gian | Ảnh |
| --- | --- | ---: | --- |
| UI-04 / mobile | ❌ FAIL | 15.8 s | [Ảnh 1](screenshots/mobile-UI-04-01.png) |
| UI-09 / mobile | ❌ FAIL | 15.8 s | [Ảnh 1](screenshots/mobile-UI-09-01.png) |
| UI-11 / mobile | ❌ FAIL | 17.5 s | [Ảnh 1](screenshots/mobile-UI-11-01.png) · [Ảnh 2](screenshots/mobile-UI-11-02.png) |
| UI-04 / small-mobile | ❌ FAIL | 15.9 s | [Ảnh 1](screenshots/small-mobile-UI-04-01.png) |
| UI-07 / small-mobile | ❌ FAIL | 16.4 s | [Ảnh 1](screenshots/small-mobile-UI-07-01.png) · [Ảnh 2](screenshots/small-mobile-UI-07-02.png) |
| UI-08 / small-mobile | ⏱ TIMEOUT | 45.5 s | [Ảnh 1](screenshots/small-mobile-UI-08-01.png) |
| UI-09 / small-mobile | ❌ FAIL | 16.1 s | [Ảnh 1](screenshots/small-mobile-UI-09-01.png) |
| UI-11 / small-mobile | ❌ FAIL | 17.5 s | [Ảnh 1](screenshots/small-mobile-UI-11-01.png) · [Ảnh 2](screenshots/small-mobile-UI-11-02.png) |
| UI-04 / desktop | ❌ FAIL | 16.0 s | [Ảnh 1](screenshots/desktop-UI-04-01.png) |
| UI-09 / desktop | ❌ FAIL | 15.9 s | [Ảnh 1](screenshots/desktop-UI-09-01.png) |
| UI-11 / desktop | ❌ FAIL | 17.7 s | [Ảnh 1](screenshots/desktop-UI-11-01.png) · [Ảnh 2](screenshots/desktop-UI-11-02.png) |

<details>
<summary>Thông báo lỗi từng ca</summary>

#### mobile / UI-04

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last() with timeout 12000ms
  - waiting for getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()


  93 |   expect((await response).status()).toBe(401);
  94 |   await expect(page).toHaveURL(/#\/auth$/);
> 95 |   await expect(page.getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()).toBeVisible();
     |                                                                                                 ^
  96 |   await snapshot(page, info, 'rejected-login');
  97 | });
  98 |
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:95:97
```

#### mobile / UI-09

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last() with timeout 12000ms
  - waiting for getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()


  155 |   await page.getByRole('textbox', { name: 'Mật khẩu', exact: true }).fill('[REDACTED]');
  156 |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
> 157 |   await expect(page.getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()).toBeVisible();
      |                                                                                               ^
  158 |   await expect(page).toHaveURL(/#\/auth$/);
  159 |   await expect(page.getByRole('button', { name: 'Đăng nhập →', exact: true })).toBeEnabled();
  160 |   await snapshot(page, info, 'backend-outage');
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:157:95
```

#### mobile / UI-11

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Vườn của UI/)
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Vườn của UI/) with timeout 12000ms
  - waiting for getByText(/Vườn của UI/)


  187 |   await page.getByRole('button', { name: 'Trang chủ', exact: true }).click();
  188 |   await expect(page).toHaveURL(/#\/home$/);
> 189 |   await expect(page.getByText(/Vườn của UI/)).toBeVisible();
      |                                               ^
  190 |   await snapshot(page, info, 'vietnamese-dashboard');
  191 | });
  192 |
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:189:47
```

#### small-mobile / UI-04

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last() with timeout 12000ms
  - waiting for getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()


  93 |   expect((await response).status()).toBe(401);
  94 |   await expect(page).toHaveURL(/#\/auth$/);
> 95 |   await expect(page.getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()).toBeVisible();
     |                                                                                                 ^
  96 |   await snapshot(page, info, 'rejected-login');
  97 | });
  98 |
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:95:97
```

#### small-mobile / UI-07

```text
Error: expect(locator).toBeVisible() failed

Locator: getByRole('button', { name: 'Đăng xuất', exact: true })
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByRole('button', { name: 'Đăng xuất', exact: true }) with timeout 12000ms
  - waiting for getByRole('button', { name: 'Đăng xuất', exact: true })


  42 |
  43 | async function insideViewport(locator, page) {
> 44 |   await expect(locator).toBeVisible();
     |                         ^
  45 |   const box = await locator.boundingBox();
  46 |   expect(box, 'Element has a rendered rectangle').not.toBeNull();
  47 |   const size = page.viewportSize();
    at insideViewport (D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:44:25)
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:129:9
```

#### small-mobile / UI-08

```text
Test timeout of 45000ms exceeded.
Error: locator.click: Test timeout of 45000ms exceeded.
Call log:
  - waiting for getByRole('button', { name: 'Đăng xuất', exact: true })


  136 |   await login(page);
  137 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
> 138 |   await page.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
      |                                                                      ^
  139 |   await expect(page.getByRole('alertdialog')).toBeVisible();
  140 |   const response = page.waitForResponse(r => r.url().endsWith('/api/auth/logout'));
  141 |   await page.getByRole('alertdialog').getByRole('button', { name: 'Đăng xuất', exact: true }).click();
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:138:70
```

#### small-mobile / UI-09

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last() with timeout 12000ms
  - waiting for getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()


  155 |   await page.getByRole('textbox', { name: 'Mật khẩu', exact: true }).fill('[REDACTED]');
  156 |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
> 157 |   await expect(page.getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()).toBeVisible();
      |                                                                                               ^
  158 |   await expect(page).toHaveURL(/#\/auth$/);
  159 |   await expect(page.getByRole('button', { name: 'Đăng nhập →', exact: true })).toBeEnabled();
  160 |   await snapshot(page, info, 'backend-outage');
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:157:95
```

#### small-mobile / UI-11

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Vườn của UI/)
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Vườn của UI/) with timeout 12000ms
  - waiting for getByText(/Vườn của UI/)


  187 |   await page.getByRole('button', { name: 'Trang chủ', exact: true }).click();
  188 |   await expect(page).toHaveURL(/#\/home$/);
> 189 |   await expect(page.getByText(/Vườn của UI/)).toBeVisible();
      |                                               ^
  190 |   await snapshot(page, info, 'vietnamese-dashboard');
  191 | });
  192 |
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:189:47
```

#### desktop / UI-04

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last() with timeout 12000ms
  - waiting for getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()


  93 |   expect((await response).status()).toBe(401);
  94 |   await expect(page).toHaveURL(/#\/auth$/);
> 95 |   await expect(page.getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()).toBeVisible();
     |                                                                                                 ^
  96 |   await snapshot(page, info, 'rejected-login');
  97 | });
  98 |
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:95:97
```

#### desktop / UI-09

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last() with timeout 12000ms
  - waiting for getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()


  155 |   await page.getByRole('textbox', { name: 'Mật khẩu', exact: true }).fill('[REDACTED]');
  156 |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
> 157 |   await expect(page.getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()).toBeVisible();
      |                                                                                               ^
  158 |   await expect(page).toHaveURL(/#\/auth$/);
  159 |   await expect(page.getByRole('button', { name: 'Đăng nhập →', exact: true })).toBeEnabled();
  160 |   await snapshot(page, info, 'backend-outage');
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:157:95
```

#### desktop / UI-11

```text
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Vườn của UI/)
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Vườn của UI/) with timeout 12000ms
  - waiting for getByText(/Vườn của UI/)


  187 |   await page.getByRole('button', { name: 'Trang chủ', exact: true }).click();
  188 |   await expect(page).toHaveURL(/#\/home$/);
> 189 |   await expect(page.getByText(/Vườn của UI/)).toBeVisible();
      |                                               ^
  190 |   await snapshot(page, info, 'vietnamese-dashboard');
  191 | });
  192 |
    at D:\Aerogreen\app_web_aerogreen\IOTAgri\frontend\e2e\tests\ui.spec.cjs:189:47
```

</details>

## Bằng chứng và giới hạn

- [JSON đầy đủ](results.json), [báo cáo văn bản](BAO_CAO_UI.txt), [console log](runner.log), [exit code](exit-code.txt).
- [Môi trường và revision](environment.json), [lịch sử các lượt xác minh](verification-runs.json).
- 33 ca riêng biệt, 39 lượt thực thi gồm các lượt chụp lại/xác minh. Không cộng các lượt chạy lại thành ca mới.
- Chrome desktop mô phỏng viewport/touch; không thay thế kiểm thử native hoặc thiết bị thật.
- Credential trong bản công bố đã được che. [Artifact Playwright](../../../testing/reports/frontend/e2e/2026-10-19/raw/) giữ log, ảnh, trace và báo cáo HTML.
- [HTML gốc](index.html) cần tải cùng ảnh về để mở; trang Markdown này đọc trực tiếp trên GitHub.
