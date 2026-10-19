# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: ui.spec.cjs >> UI-08: logout clears the session and returns to login after reload
- Location: tests\ui.spec.cjs:135:1

# Error details

```
Test timeout of 45000ms exceeded.
```

```
Error: locator.click: Test timeout of 45000ms exceeded.
Call log:
  - waiting for getByRole('button', { name: 'Đăng xuất', exact: true })

```

# Page snapshot

```yaml
- generic [ref=e4] [cursor=pointer]:
  - generic:
    - generic:
      - generic:
        - generic:
          - generic:
            - generic:
              - generic [ref=e5]:
                - generic [active]: Tài khoản
              - generic [ref=e6]: Khác
              - generic [ref=e7]: U UI Test ui-1792343376314@example.test Pro
              - generic:
                - button "Tùy chỉnh Ngôn ngữ và thông báo" [ref=e8]
                - button "Lịch sử thu hoạch Đã trồng 32 cây" [ref=e9]
                - button "Trợ giúp & Hỗ trợ Câu hỏi thường gặp và chat" [ref=e10]
          - button "Trang chủ" [ref=e11]
          - button "Cảnh báo" [ref=e12]
          - button "Chọn giống" [ref=e13]
          - button "Khác" [ref=e14]
```

# Test source

```ts
  38  |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  39  |   expect((await response).status(), 'Real backend accepts the test account').toBe(200);
  40  |   await expect(page).toHaveURL(/#\/home$/);
  41  | }
  42  | 
  43  | async function insideViewport(locator, page) {
  44  |   await expect(locator).toBeVisible();
  45  |   const box = await locator.boundingBox();
  46  |   expect(box, 'Element has a rendered rectangle').not.toBeNull();
  47  |   const size = page.viewportSize();
  48  |   expect(box.x, 'Element is not clipped at the left').toBeGreaterThanOrEqual(-1);
  49  |   expect(box.y, 'Element is not clipped at the top').toBeGreaterThanOrEqual(-1);
  50  |   expect(box.x + box.width, 'Element fits viewport width').toBeLessThanOrEqual(size.width + 1);
  51  |   expect(box.y + box.height, 'Element fits viewport height').toBeLessThanOrEqual(size.height + 1);
  52  | }
  53  | 
  54  | test('UI-01: login renders and the submit button is reachable', async ({ page }, info) => {
  55  |   await openApp(page);
  56  |   await expect(page.getByRole('textbox')).toHaveCount(2);
  57  |   const button = page.getByRole('button', { name: 'Đăng nhập →', exact: true });
  58  |   await button.scrollIntoViewIfNeeded();
  59  |   await insideViewport(button, page);
  60  |   await snapshot(page, info, 'login');
  61  | });
  62  | 
  63  | test('UI-02: empty login shows field validation without sending an API request', async ({ page, diagnostics }, info) => {
  64  |   await openApp(page);
  65  |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  66  |   await expect(page.getByText('Email không hợp lệ', { exact: true }).last()).toBeVisible();
  67  |   await expect(page.getByText('Vui lòng nhập mật khẩu', { exact: true }).last()).toBeVisible();
  68  |   expect(diagnostics.filter(e => e.type === 'api' && e.url.endsWith('/api/auth/login'))).toHaveLength(0);
  69  |   await snapshot(page, info, 'login-validation');
  70  | });
  71  | 
  72  | test('UI-03: registration validates weak and mismatched passwords', async ({ page, diagnostics }, info) => {
  73  |   await openApp(page);
  74  |   await page.getByRole('button', { name: 'Đăng Ký', exact: true }).click();
  75  |   await expect(page.getByRole('textbox')).toHaveCount(4);
  76  |   await page.getByRole('textbox', { name: 'Họ và tên', exact: true }).fill('UI Test');
  77  |   await page.getByRole('textbox', { name: 'ban@vidu.com', exact: true }).fill('validation@example.test');
  78  |   await page.getByRole('textbox', { name: 'Mật khẩu', exact: true }).fill('weak');
  79  |   await page.getByRole('textbox', { name: 'Xác nhận mật khẩu', exact: true }).fill('different');
  80  |   await page.getByRole('button', { name: 'Tạo tài khoản →', exact: true }).click();
  81  |   await expect(page.getByText('Mật khẩu không khớp', { exact: true }).last()).toBeVisible();
  82  |   await expect(page.getByText(/Mật khẩu cần có:/).last()).toBeVisible();
  83  |   expect(diagnostics.filter(e => e.type === 'api' && e.url.endsWith('/api/auth/register'))).toHaveLength(0);
  84  |   await snapshot(page, info, 'registration-validation');
  85  | });
  86  | 
  87  | test('UI-04: rejected credentials show feedback and remain on login', async ({ page }, info) => {
  88  |   await openApp(page);
  89  |   await page.getByRole('textbox', { name: 'ban@vidu.com', exact: true }).fill('missing-ui-user@example.test');
  90  |   await page.getByRole('textbox', { name: 'Mật khẩu', exact: true }).fill('WrongPassword!9');
  91  |   const response = page.waitForResponse(r => r.url().endsWith('/api/auth/login'));
  92  |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  93  |   expect((await response).status()).toBe(401);
  94  |   await expect(page).toHaveURL(/#\/auth$/);
  95  |   await expect(page.getByText(/Exception:|không|thất bại|Unauthorized|Failed|invalid/i).last()).toBeVisible();
  96  |   await snapshot(page, info, 'rejected-login');
  97  | });
  98  | 
  99  | test('UI-05: real login loads dashboard and survives a browser reload', async ({ page, diagnostics }, info) => {
  100 |   await login(page);
  101 |   await expect(page.getByText(/Vườn của UI|UI.s Garden/)).toBeVisible();
  102 |   await expect.poll(() => diagnostics.some(e => e.type === 'api' && e.url.endsWith('/api/dashboard/overview') && e.status === 200)).toBeTruthy();
  103 |   await snapshot(page, info, 'dashboard');
  104 |   await page.reload();
  105 |   await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
  106 |   await expect(page).toHaveURL(/#\/home$/);
  107 |   await expect(page.getByText(/Vườn của UI|UI.s Garden/)).toBeVisible();
  108 |   await snapshot(page, info, 'restored-session');
  109 | });
  110 | 
  111 | test('UI-06: alerts and plant selection tabs open with reachable navigation', async ({ page }, info) => {
  112 |   await login(page);
  113 |   await page.getByRole('button', { name: 'Cảnh báo', exact: true }).click();
  114 |   await expect(page).toHaveURL(/#\/alerts$/);
  115 |   await expect(page.getByRole('tab', { name: 'Tất cả', exact: true })).toBeVisible();
  116 |   await snapshot(page, info, 'alerts');
  117 |   await page.getByRole('button', { name: 'Chọn giống', exact: true }).click();
  118 |   await expect(page).toHaveURL(/#\/pick$/);
  119 |   await expect(page.getByRole('button', { name: /Bắt Đầu Trồng/ }).first()).toBeVisible();
  120 |   await insideViewport(page.getByRole('button', { name: 'Khác', exact: true }), page);
  121 |   await snapshot(page, info, 'plant-picker');
  122 | });
  123 | 
  124 | test('UI-07: account and settings remain usable on the viewport', async ({ page }, info) => {
  125 |   await login(page);
  126 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
  127 |   await expect(page.getByText(/UI Test/)).toBeVisible();
  128 |   await snapshot(page, info, 'account');
  129 |   await insideViewport(page.getByRole('button', { name: 'Đăng xuất', exact: true }), page);
  130 |   await page.getByRole('button', { name: /Tùy chỉnh/ }).click();
  131 |   await expect(page.getByRole('radio', { name: 'English', exact: true })).toBeVisible();
  132 |   await snapshot(page, info, 'settings');
  133 | });
  134 | 
  135 | test('UI-08: logout clears the session and returns to login after reload', async ({ page }, info) => {
  136 |   await login(page);
  137 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
> 138 |   await page.getByRole('button', { name: 'Đăng xuất', exact: true }).click();
      |                                                                      ^ Error: locator.click: Test timeout of 45000ms exceeded.
  139 |   await expect(page.getByRole('alertdialog')).toBeVisible();
  140 |   const response = page.waitForResponse(r => r.url().endsWith('/api/auth/logout'));
  141 |   await page.getByRole('alertdialog').getByRole('button', { name: 'Đăng xuất', exact: true }).click();
  142 |   expect((await response).ok()).toBeTruthy();
  143 |   await expect(page).toHaveURL(/#\/auth$/);
  144 |   await page.reload();
  145 |   await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
  146 |   await expect(page.getByRole('button', { name: 'Đăng Nhập', exact: true })).toBeVisible();
  147 |   await expect(page).toHaveURL(/#\/auth$/);
  148 |   await snapshot(page, info, 'logged-out');
  149 | });
  150 | 
  151 | test('UI-09: a backend outage displays an error instead of authenticating', async ({ page }, info) => {
  152 |   await openApp(page);
  153 |   await page.route('**/api/auth/login', route => route.abort('connectionrefused'));
  154 |   await page.getByRole('textbox', { name: 'ban@vidu.com', exact: true }).fill('outage@example.test');
  155 |   await page.getByRole('textbox', { name: 'Mật khẩu', exact: true }).fill('[REDACTED]');
  156 |   await page.getByRole('button', { name: 'Đăng nhập →', exact: true }).click();
  157 |   await expect(page.getByText(/Exception:|ClientException:|Failed|kết nối|thất bại/i).last()).toBeVisible();
  158 |   await expect(page).toHaveURL(/#\/auth$/);
  159 |   await expect(page.getByRole('button', { name: 'Đăng nhập →', exact: true })).toBeEnabled();
  160 |   await snapshot(page, info, 'backend-outage');
  161 | });
  162 | 
  163 | test('UI-10: help and harvest history screens can be opened', async ({ page }, info) => {
  164 |   await login(page);
  165 |   await page.getByRole('button', { name: 'Khác', exact: true }).click();
  166 |   await page.getByRole('button', { name: /Trợ giúp & Hỗ trợ/ }).click();
  167 |   await expect(page.getByRole('button', { name: 'Chat với chúng tôi', exact: true })).toBeVisible();
  168 |   await snapshot(page, info, 'help');
  169 |   await page.getByRole('button', { name: '', exact: true }).first().click();
  170 |   await expect(page.getByRole('button', { name: /Lịch sử thu hoạch/ })).toBeVisible();
  171 |   await page.getByRole('button', { name: /Lịch sử thu hoạch/ }).click();
  172 |   await expect(page.getByText(/Nhật ký thu hoạch/)).toBeVisible();
  173 |   await snapshot(page, info, 'harvest-history');
  174 | });
  175 | 
```