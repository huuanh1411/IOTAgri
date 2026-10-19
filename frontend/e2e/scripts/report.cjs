const fs = require('node:fs');
const path = require('node:path');
const { e2eRoot, resolveReportDir } = require('./paths.cjs');

const descriptions = {
  'UI-01': [
    'Hiển thị đăng nhập và nút bấm trên viewport',
    'Hiện 2 ô nhập, nút đăng nhập nằm trong màn hình sau khi cuộn.',
  ],
  'UI-02': [
    'Validate đăng nhập bỏ trống',
    'Hiện lỗi email/mật khẩu và không gửi yêu cầu đăng nhập tới BE.',
  ],
  'UI-03': [
    'Validate đăng ký',
    'Hiện yêu cầu mật khẩu mạnh và lỗi xác nhận mật khẩu; không tạo tài khoản.',
  ],
  'UI-04': [
    'Đăng nhập sai thông tin với BE thật',
    'BE trả 401, FE vẫn ở trang đăng nhập và hiển thị lý do thất bại.',
  ],
  'UI-05': [
    'Đăng nhập thành công và khôi phục phiên',
    'BE trả 200, dashboard tải thành công, reload vẫn đăng nhập.',
  ],
  'UI-06': [
    'Tab cảnh báo và chọn giống',
    'Mở được các tab và nút điều hướng nằm trong viewport.',
  ],
  'UI-07': [
    'Trang tài khoản và cài đặt',
    'Hiển thị đúng tài khoản, nút đăng xuất không bị cắt và mở được cài đặt.',
  ],
  'UI-08': [
    'Đăng xuất và xóa phiên',
    'Xác nhận đăng xuất, BE chấp nhận, reload vẫn ở trang đăng nhập.',
  ],
  'UI-09': [
    'Xử lý mất kết nối backend',
    'Hiện thông báo lỗi, không đăng nhập và cho phép thử lại. Lỗi mạng được mô phỏng bằng cách chặn đúng request login trong trình duyệt.',
  ],
  'UI-10': [
    'Màn hình hỗ trợ và lịch sử thu hoạch',
    'Mở được hai màn hình bằng thao tác UI; không gửi chat hoặc điều khiển phần cứng.',
  ],
  'UI-11': [
    'Đồng bộ lựa chọn tiếng Việt với dashboard',
    'Cài đặt đang chọn Tiếng Việt thì tiêu đề vườn trên dashboard cũng phải hiển thị tiếng Việt.',
  ],
};

function generateReport(destination) {
  const report = JSON.parse(
    fs.readFileSync(path.join(e2eRoot, 'test-results/results.json'), 'utf8'),
  );
  const out = destination || resolveReportDir();
  fs.mkdirSync(path.join(out, 'screenshots'), { recursive: true });
  const fixturePath = path.join(e2eRoot, '.auth/fixture.json');
  const password = fs.existsSync(fixturePath)
    ? JSON.parse(fs.readFileSync(fixturePath, 'utf8')).password
    : '';
  const redact = (value) =>
    password ? String(value).split(password).join('[REDACTED]') : String(value);
  const cases = [];
  const visit = (suites) => {
    for (const suite of suites) {
      for (const spec of suite.specs || [])
        for (const test of spec.tests) {
          const result = test.results.at(-1);
          const id = spec.title.split(':')[0];
          const entry = {
            id,
            project: test.projectName,
            title: descriptions[id]?.[0] || spec.title,
            expected: descriptions[id]?.[1] || spec.title,
            status: result.status,
            durationMs: result.duration,
            errors: result.errors
              .map((e) => redact(e.message || ''))
              .map((e) => e.replace(/\u001b\[[0-9;]*m/g, '')),
            screenshots: [],
            diagnostics: [],
            accessibility: '',
          };
          let number = 0;
          for (const a of result.attachments) {
            if (a.contentType === 'image/png') {
              const name = `${test.projectName}-${id}-${String(++number).padStart(2, '0')}.png`;
              const buffer = a.path
                ? fs.readFileSync(a.path)
                : Buffer.from(a.body, 'base64');
              fs.writeFileSync(path.join(out, 'screenshots', name), buffer);
              entry.screenshots.push({
                name: a.name,
                path: `screenshots/${name}`,
              });
            } else if (a.body && a.name === 'browser-diagnostics') {
              entry.diagnostics = JSON.parse(
                redact(Buffer.from(a.body, 'base64').toString('utf8')),
              );
            } else if (a.body && a.name === 'accessibility-tree') {
              entry.accessibility = redact(
                Buffer.from(a.body, 'base64').toString('utf8'),
              );
            }
          }
          cases.push(entry);
        }
      visit(suite.suites || []);
    }
  };
  visit(report.suites);
  const passed = cases.filter((c) => c.status === 'passed').length;
  const failed = cases.filter(
    (c) => c.status !== 'passed' && c.status !== 'skipped',
  );
  const date = new Date(report.stats.startTime).toLocaleString('vi-VN', {
    timeZone: 'Asia/Ho_Chi_Minh',
  });
  const notes = [
    'Phạm vi: bản Flutter web release đang phục vụ tại localhost:3000, API thật tại localhost:5261.',
    'Viewport: mobile 390×844, small-mobile 320×568, desktop 1280×900; Chrome desktop mô phỏng kích thước và touch của mobile, không phải thiết bị Android/iPhone thật.',
    'Bộ test bật accessibility/semantics của Flutter để thao tác bằng tên và role; không sửa mã ứng dụng.',
    'Chuẩn bị tài khoản kiểm thử riêng qua API local. Đăng nhập/đăng xuất và dashboard được kiểm tra qua UI với BE thật. Ca UI-09 cố ý chặn request để tái hiện mất kết nối.',
    'Ảnh là bằng chứng giao diện thực tế. Chưa có ảnh baseline được duyệt nên chưa khẳng định mọi pixel đều đúng hoặc giao diện giống thiết kế.',
    'Không kiểm tra lệnh bơm/đèn trên thiết bị thật, provisioning ESP32, mọi trình duyệt hoặc Android/iOS native.',
    'Màn hình lịch sử thu hoạch đang dùng mockHarvests; chat hỗ trợ là placeholder. Mở được các màn hình này không đồng nghĩa dữ liệu/tính năng đã tích hợp BE.',
    'Không thay đổi mã ứng dụng để làm test xanh. Trace đầy đủ giữ ở frontend/e2e/test-results (đã gitignore); báo cáo công khai chỉ dùng ảnh, kết quả và log phương thức/URL/status, không xuất token hoặc mật khẩu fixture.',
  ];
  if (report.verificationRuns)
    notes.push(
      'Kết quả hợp nhất theo ca mới nhất: ma trận 30 ca ban đầu; 6 ca dashboard/hỗ trợ chạy lại để chụp ảnh sau loading/chuyển cảnh; bổ sung 3 ca xác minh tiếng Việt. Tổng 33 ca riêng biệt, 39 lượt thực thi. Chi tiết từng lượt nằm trong verification-runs.json.',
    );
  const findings = [];
  if (failed.some((c) => c.id === 'UI-04' || c.id === 'UI-09'))
    findings.push({
      title:
        'F-01 — Không hiện phản hồi khi đăng nhập thất bại hoặc mất kết nối',
      meaning:
        'Nhập thông tin sai: BE trả 401 nhưng FE không hiện thông báo trong thời gian chờ 12 giây. Khi chặn kết nối login cũng chưa thấy thông báo. Người dùng ở lại màn hình đăng nhập mà không biết lý do.',
      source:
        'Dấu hiệu nguyên nhân từ mã: AuthState.copyWith mặc định đặt error=null; login catch gán error rồi finally gọi copyWith(isLoading:false) xóa error ngay. AuthScreen đọc error trong build nên có thể không kịp dựng SnackBar. Đây là phân tích nguồn, cần sửa và chạy lại để xác nhận.',
      affected: failed
        .filter((c) => ['UI-04', 'UI-09'].includes(c.id))
        .map((c) => `${c.project}/${c.id}`),
    });
  if (
    failed.some(
      (c) =>
        c.id === 'UI-07' &&
        c.errors.some((e) => /viewport|clipped|rectangle|Đăng xuất/.test(e)),
    )
  )
    findings.push({
      title: 'F-02 — Trang tài khoản có nội dung vượt khỏi màn hình',
      meaning:
        'Trên viewport nhỏ, nút đăng xuất không hiển thị/không nằm đầy đủ trong vùng nhìn thấy. Ảnh xác nhận phần dưới trang tài khoản bị cắt; MoreScreen dùng Column cố định, không có cuộn cho toàn bộ nội dung. Vì vậy ca đăng xuất trên màn hình này cũng có thể không thao tác được.',
      source:
        'Vị trí cần xem: frontend/lib/screens/more_screen.dart. Chưa sửa bố cục trong lượt test này.',
      affected: failed
        .filter((c) => ['UI-07', 'UI-08'].includes(c.id))
        .map((c) => `${c.project}/${c.id}`),
    });
  if (failed.some((c) => c.id === 'UI-11'))
    findings.push({
      title: 'F-03 — Dashboard chưa theo đúng lựa chọn tiếng Việt',
      meaning:
        "Cài đặt đánh dấu Tiếng Việt nhưng dashboard vẫn hiển thị Good morning và UI's Garden, trong khi các nhãn khác là tiếng Việt. Ca test kiểm tra lựa chọn radio trước khi quay lại dashboard.",
      source:
        'Vị trí cần xem: frontend/lib/app.dart truyền locale nhưng chưa khai báo supportedLocales/delegates cho tiếng Việt; HomeScreen đọc Localizations.localeOf(context), còn nhãn điều hướng đọc AppSettingsProvider. Hai nguồn locale có thể lệch nhau.',
      affected: failed
        .filter((c) => c.id === 'UI-11')
        .map((c) => `${c.project}/${c.id}`),
    });
  const summary = {
    date,
    passed,
    failed: failed.length,
    total: cases.length,
    notes,
    findings,
    cases,
  };
  fs.writeFileSync(
    path.join(out, 'results.json'),
    JSON.stringify(summary, null, 2),
  );
  const lines = [
    'BÁO CÁO TEST GIAO DIỆN FE — CHROME THỰC TẾ',
    `Bắt đầu: ${date} (giờ Việt Nam)`,
    `Kết quả: ${passed}/${cases.length} đạt; ${failed.length} ca chưa đạt.`,
    '',
    ...notes,
    '',
    'CÁC VẤN ĐỀ ĐÃ GHI NHẬN',
  ];
  for (const f of findings)
    lines.push(
      '',
      f.title,
      f.meaning,
      f.source,
      `Ảnh hưởng: ${f.affected.join(', ')}`,
    );
  lines.push('', 'TỪNG CA KIỂM THỬ');
  for (const c of cases) {
    lines.push(
      '',
      `[${c.status}] ${c.project} / ${c.id}: ${c.title}`,
      `Mong đợi: ${c.expected}`,
      `Thời gian: ${(c.durationMs / 1000).toFixed(1)} giây.`,
    );
    if (c.errors.length) lines.push('Thực tế / lỗi:', ...c.errors);
    lines.push('Ảnh: ' + c.screenshots.map((s) => s.path).join(', '));
    if (c.diagnostics.length)
      lines.push('Log browser/API:', JSON.stringify(c.diagnostics, null, 2));
  }
  lines.push(
    '',
    'CHẠY LẠI',
    'Từ thư mục repo: npm.cmd test --prefix frontend/e2e',
    'Chỉ mobile: npm.cmd run test:mobile --prefix frontend/e2e',
    'Bảo đảm BE đang chạy và frontend/build/web đã build với API_BASE_URL đúng.',
  );
  fs.writeFileSync(path.join(out, 'BAO_CAO_UI.txt'), lines.join('\n') + '\n');
  const escape = (s) =>
    String(s).replace(
      /[&<>"']/g,
      (c) =>
        ({
          '&': '&amp;',
          '<': '&lt;',
          '>': '&gt;',
          '"': '&quot;',
          "'": '&#39;',
        })[c],
    );
  const html = `<!doctype html><html lang="vi"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Kết quả kiểm thử giao diện Aerogreen</title><style>body{font:16px/1.6 system-ui;margin:32px auto;padding:0 20px;max-width:1200px;background:#f4f6f3;color:#20352b}h1{font-size:30px}article,section{background:white;border:1px solid #d5ded6;border-radius:16px;padding:20px;margin:18px 0}.fail{border-left:6px solid #be3942}.pass{border-left:6px solid #267348}small{color:#59695f}pre{white-space:pre-wrap;overflow-wrap:anywhere;background:#f1f4f1;padding:14px;border-radius:8px;font-size:13px}.images{display:flex;gap:16px;overflow-x:auto;align-items:start}img{max-height:500px;max-width:100%;border:1px solid #ccc}.badge{font-weight:bold}a{color:#246d4c}</style><h1>Kiểm thử giao diện Aerogreen</h1><p>${escape(date)} · ${passed}/${cases.length} đạt · ${failed.length} ca chưa đạt</p><p><a href="BAO_CAO_UI.txt">Báo cáo đầy đủ dạng văn bản</a> · <a href="results.json">Dữ liệu JSON</a></p><section><h2>Phạm vi và giới hạn</h2><ul>${notes.map((n) => `<li>${escape(n)}</li>`).join('')}</ul></section>${findings.map((f) => `<article class="fail"><h2>${escape(f.title)}</h2><p>${escape(f.meaning)}</p><p>${escape(f.source)}</p><small>${escape(f.affected.join(', '))}</small></article>`).join('')}${cases.map((c) => `<article class="${c.status === 'passed' ? 'pass' : 'fail'}"><h2>${escape(c.project)} / ${escape(c.id)} — ${escape(c.title)}</h2><p class="badge">${escape(c.status)} · ${(c.durationMs / 1000).toFixed(1)} giây</p><p>Mong đợi: ${escape(c.expected)}</p>${c.errors.map((e) => `<pre>${escape(e)}</pre>`).join('')}<div class="images">${c.screenshots.map((s) => `<a href="${s.path}" target="_blank"><img loading="lazy" src="${s.path}" alt="${escape(s.name)}"><br><small>${escape(s.name)}</small></a>`).join('')}</div><details><summary>Log browser/API và accessibility</summary><pre>${escape(JSON.stringify(c.diagnostics, null, 2))}</pre><pre>${escape(c.accessibility)}</pre></details></article>`).join('')}</html>`;
  fs.writeFileSync(path.join(out, 'index.html'), html);
  console.log(`UI report: ${out} (${passed}/${cases.length} passed)`);
  return summary;
}

module.exports = { generateReport };
if (require.main === module) generateReport(process.argv[2]);
