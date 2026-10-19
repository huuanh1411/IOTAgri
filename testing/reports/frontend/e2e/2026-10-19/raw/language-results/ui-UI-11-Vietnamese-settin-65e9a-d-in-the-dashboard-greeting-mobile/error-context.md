# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: ui.spec.cjs >> UI-11: Vietnamese settings are reflected in the dashboard greeting
- Location: tests\ui.spec.cjs:181:1

# Error details

```
Error: expect(locator).toBeVisible() failed

Locator: getByText(/Vườn của UI/)
Expected: visible
Timeout: 12000ms
Error: element(s) not found

Call log:
  - Expect "toBeVisible" getByText(/Vườn của UI/) with timeout 12000ms
  - waiting for getByText(/Vườn của UI/)

```

```yaml
- group:
  - text: Good morning UI's Garden U ĐANG TRỒNG Xà lách 37% KHỎE MẠNH Butterhead · Ngày 15 / 28
  - progressbar "54"
  - text: Nảy mầm Sinh trưởng Thu hoạch
  - group "Cảm biến Trực tiếp ● Đã đồng bộ":
    - button "Xem chi tiết MỨC NƯỚC — MỨC NƯỚC":
      - progressbar "100"
      - progressbar "0"
    - button "Xem chi tiết TDS — TDS":
      - progressbar "100"
      - progressbar "0"
    - button "Xem chi tiết NHIỆT ĐỘ KK — NHIỆT ĐỘ KK":
      - progressbar "100"
      - progressbar "0"
    - button "Xem chi tiết ÁNH SÁNG — ÁNH SÁNG":
      - progressbar "100"
      - progressbar "0"
    - button "Xem chi tiết NHIỆT ĐỘ NƯỚC — NHIỆT ĐỘ NƯỚC":
      - progressbar "100"
      - progressbar "0"
    - button "Xem chi tiết ĐỘ ẨM KHÔNG KHÍ — ĐỘ ẨM KHÔNG KHÍ":
      - progressbar "100"
      - progressbar "0"
  - text: Lịch chăm sóc Xà lách Tự động tối ưu CHU KỲ TƯỚI 2 phút mỗi 15 phút CHU KỲ DINH DƯỠNG 5ml mỗi 3 ngày NHIỆT ĐỘ LÝ TƯỞNG 18–22°C
- button "Trang chủ"
- button "Cảnh báo"
- button "Chọn giống"
- button "Khác"
```

# Test source

```ts
  89  | 
  90  | test('UI-04: rejected credentials show feedback and remain on login', async ({ page }, info) => {
  91  |   await openApp(page);
  92  |   await page.getByRole('textbox', { name: 'ban@vidu.com', exact: true }).fill('missing-ui-user@example.test');
  93  |   await page.getByRole('textbox', { name: 'Mật khẩu', exact: true }).fill('WrongPassword!9');
  94  |   const response = page.waitForResponse(r => r.url().endsWith('/api/auth/login'));
  95  |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  96  |   expect((await response).status()).toBe(401);
  97  |   await expect(page).toHaveURL(/#\/auth$/);
  98  |   await expect(page.getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()).toBeVisible();
  99  |   await snapshot(page, info, 'rejected-login');
  100 | });
  101 | 
  102 | test('UI-05: real login loads dashboard and survives a browser reload', async ({ page, diagnostics }, info) => {
  103 |   await login(page);
  104 |   await expect(page.getByText(/Vườn của UI|UI.s Garden/)).toBeVisible();
  105 |   await expect.poll(() => diagnostics.some(e => e.type === 'api' && e.url.endsWith('/api/dashboard/overview') && e.status === 200)).toBeTruthy();
  106 |   await expect(page.getByText(/KHỎE MẠNH/)).toBeVisible();
  107 |   await snapshot(page, info, 'dashboard');
  108 |   await page.reload();
  109 |   await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
  110 |   await expect(page).toHaveURL(/#\/home$/);
  111 |   await expect(page.getByText(/Vườn của UI|UI.s Garden/)).toBeVisible();
  112 |   await expect(page.getByText(/KHỎE MẠNH/)).toBeVisible();
  113 |   await snapshot(page, info, 'restored-session');
  114 | });
  115 | 
  116 | test('UI-06: alerts and plant selection tabs open with reachable navigation', async ({ page }, info) => {
  117 |   await login(page);
  118 |   await page.getByRole('button', { name: 'Cảnh báo', exact: true }).click();
  119 |   await expect(page).toHaveURL(/#\/alerts$/);
  120 |   await expect(page.getByRole('tab', { name: 'Tất cả', exact: true })).toBeVisible();
  121 |   await snapshot(page, info, 'alerts');
  122 |   await page.getByRole('button', { name: 'Chọn giống', exact: true }).click();
  123 |   await expect(page).toHaveURL(/#\/pick$/);
  124 |   await expect(page.getByRole('button', { name: /Bắt Đầu Trồng/ }).first()).toBeVisible();
  125 |   await insideViewport(page.getByRole('button', { name: 'Khác', exact: true }), page);
  126 |   await snapshot(page, info, 'plant-picker');
  127 | });
  128 | 
  129 | test('UI-07: account and settings remain usable on the viewport', async ({ page }, info) => {
  130 |   await login(page);
  131 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
  132 |   await expect(page.getByText(/UI Test/)).toBeVisible();
  133 |   await snapshot(page, info, 'account');
  134 |   await insideViewport(page.getByRole('button', { name: 'Đăng xuất', exact: true }), page);
  135 |   await page.getByRole('button', { name: /Tùy chỉnh/ }).click();
  136 |   await expect(page.getByRole('radio', { name: 'English', exact: true })).toBeVisible();
  137 |   await snapshot(page, info, 'settings');
  138 | });
  139 | 
  140 | test('UI-08: logout clears the session and returns to login after reload', async ({ page }, info) => {
  141 |   await login(page);
  142 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
  143 |   await page.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  144 |   await expect(page.getByRole('alertdialog')).toBeVisible();
  145 |   const response = page.waitForResponse(r => r.url().endsWith('/api/auth/logout'));
  146 |   await page.getByRole('alertdialog').getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  147 |   expect((await response).ok()).toBeTruthy();
  148 |   await expect(page).toHaveURL(/#\/auth$/);
  149 |   await page.reload();
  150 |   await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
  151 |   await expect(page.getByRole('button', { name: 'Đăng Nhập', exact: true })).toBeVisible();
  152 |   await expect(page).toHaveURL(/#\/auth$/);
  153 |   await snapshot(page, info, 'logged-out');
  154 | });
  155 | 
  156 | test('UI-09: a backend outage displays an error instead of authenticating', async ({ page }, info) => {
  157 |   await openApp(page);
  158 |   await page.route('**/api/auth/login', route => route.abort('connectionrefused'));
  159 |   await page.getByRole('textbox', { name: 'ban@vidu.com', exact: true }).fill('outage@example.test');
  160 |   await page.getByRole('textbox', { name: 'Mật khẩu', exact: true }).fill('[REDACTED]');
  161 |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  162 |   await expect(page.getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()).toBeVisible();
  163 |   await expect(page).toHaveURL(/#\/auth$/);
  164 |   await expect(page.getByRole('button', { name: 'Đăng nhập →', exact: true })).toBeEnabled();
  165 |   await snapshot(page, info, 'backend-outage');
  166 | });
  167 | 
  168 | test('UI-10: help and harvest history screens can be opened', async ({ page }, info) => {
  169 |   await login(page);
  170 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
  171 |   await page.getByRole('button', { name: /Trợ giúp & Hỗ trợ/ }).click();
  172 |   await expect(page.getByRole('button', { name: 'Chat với chúng tôi', exact: true })).toBeVisible();
  173 |   await snapshot(page, info, 'help');
  174 |   await page.getByRole('button', { name: '', exact: true }).first().click();
  175 |   await expect(page.getByRole('button', { name: /Lịch sử thu hoạch/ })).toBeVisible();
  176 |   await page.getByRole('button', { name: /Lịch sử thu hoạch/ }).click();
  177 |   await expect(page.getByText(/Nhật ký thu hoạch/)).toBeVisible();
  178 |   await snapshot(page, info, 'harvest-history');
  179 | });
  180 | 
  181 | test('UI-11: Vietnamese settings are reflected in the dashboard greeting', async ({ page }, info) => {
  182 |   await login(page);
  183 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
  184 |   await page.getByRole('button', { name: /Tùy chỉnh/ }).click();
  185 |   await expect(page.getByRole('radio', { name: 'Tiếng Việt', exact: true })).toBeChecked();
  186 |   await snapshot(page, info, 'vietnamese-selected');
  187 |   await page.getByRole('button', { name: 'Trang chủ', exact: true }).click();
  188 |   await expect(page).toHaveURL(/#\/home$/);
> 189 |   await expect(page.getByText(/Vườn của UI/)).toBeVisible();
      |                                               ^ Error: expect(locator).toBeVisible() failed
  190 |   await snapshot(page, info, 'vietnamese-dashboard');
  191 | });
  192 | 
```