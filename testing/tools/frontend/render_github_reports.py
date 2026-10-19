"""Render GitHub-readable views of published QA snapshots; retain raw evidence."""
from collections import Counter, defaultdict
from html import escape
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
UI = ROOT / 'docs/testing/2026-10-19-ui'
FLUTTER = ROOT / 'docs/testing/2026-10-18-frontend'
PROJECTS = ('mobile', 'small-mobile', 'desktop')
LABELS = {
    'passed': '✅ PASS',
    'success': '✅ PASS',
    'failed': '❌ FAIL',
    'timedOut': '⏱ TIMEOUT',
    'skipped': '⏸ SKIP',
}


def cell(value):
    return escape(str(value), quote=False).replace('|', '\\|').replace('\n', '<br>')


def write(path, lines):
    path.write_text('\n'.join(lines).rstrip() + '\n', encoding='utf-8')


def render_ui():
    data = json.loads((UI / 'results.json').read_text(encoding='utf-8'))
    environment = json.loads((UI / 'environment.json').read_text(encoding='utf-8-sig'))
    cases = data['cases']
    by_id = defaultdict(dict)
    for case in cases:
        by_id[case['id']][case['project']] = case
    counts = Counter(case['status'] for case in cases)
    lines = [
        '# Web UI · Báo cáo kiểm thử', '',
        '[← Tổng quan frontend](../README.md) · [Thư viện ảnh](screenshots/README.md) · [PDF](Bao_cao_loi_giao_dien_FE_2026-10-19.pdf) · [Log](runner.log)', '',
        f"**{data['date']} (UTC+07:00)** · Chrome {environment['chrome_version']} · Mã ứng dụng `{environment['git_head'][:7]}`", '',
        f"**{len(cases)} ca riêng biệt · {counts['passed']} PASS · {counts['failed']} FAIL · {counts['timedOut']} TIMEOUT**", '',
        '> Đây là kết quả đã lưu của ngày 19/10/2026. Không chạy lại test khi tạo trang này. Các báo cáo gốc gộp FAIL và TIMEOUT thành 11 ca chưa đạt.', '',
        '## Kết quả theo màn hình', '',
        '| Viewport | Kích thước | PASS | FAIL | TIMEOUT | Tổng |',
        '| --- | --- | ---: | ---: | ---: | ---: |',
    ]
    for project, dimensions in zip(PROJECTS, ('390 × 844', '320 × 568', '1280 × 900')):
        group = Counter(c['status'] for c in cases if c['project'] == project)
        lines.append(f"| {project} | {dimensions} | {group['passed']} | {group['failed']} | {group['timedOut']} | {sum(group.values())} |")
    lines += ['', '## Ma trận 11 kịch bản × 3 viewport', '',
              'Bấm mã kịch bản để mở nhóm ảnh tương ứng.', '',
              '| Kịch bản | Nội dung | Mobile | Small-mobile | Desktop |',
              '| --- | --- | --- | --- | --- |']
    for case_id, group in sorted(by_id.items()):
        title = cell(next(iter(group.values()))['title'])
        statuses = ' | '.join(LABELS.get(group[p]['status'], group[p]['status']) for p in PROJECTS)
        lines.append(f'| [{case_id}](screenshots/README.md#{case_id.lower()}) | {title} | {statuses} |')
    lines += ['', '## Những vấn đề đã ghi nhận', '']
    for finding in data['findings']:
        lines += [f"### {finding['title']}", '', finding['meaning'], '',
                  '**Ca liên quan:** ' + ', '.join(f"`{x}`" for x in finding['affected']) + '.', '',
                  '<details>', '<summary>Phân tích nguồn đã ghi trong báo cáo gốc</summary>', '',
                  finding['source'], '', '</details>', '']
    lines += ['## Tra cứu ca chưa đạt', '',
              '| Ca / viewport | Trạng thái | Thời gian | Ảnh |',
              '| --- | --- | ---: | --- |']
    for case in cases:
        if case['status'] in ('passed', 'skipped'):
            continue
        links = ' · '.join(f"[Ảnh {i}]({s['path']})" for i, s in enumerate(case['screenshots'], 1)) or 'Không có ảnh'
        lines.append(f"| {case['id']} / {case['project']} | {LABELS.get(case['status'], case['status'])} | {case['durationMs']/1000:.1f} s | {links} |")
    lines += ['', '<details>', '<summary>Thông báo lỗi từng ca</summary>', '']
    for case in cases:
        if case['status'] not in ('passed', 'skipped'):
            lines += [f"#### {case['project']} / {case['id']}", '', '```text',
                      '\n'.join(case['errors']).replace('```', "'''"), '```', '']
    lines += ['</details>', '', '## Bằng chứng và giới hạn', '',
              '- [JSON đầy đủ](results.json), [báo cáo văn bản](BAO_CAO_UI.txt), [console log](runner.log), [exit code](exit-code.txt).',
              '- [Môi trường và revision](environment.json), [lịch sử các lượt xác minh](verification-runs.json).',
              '- 33 ca riêng biệt, 39 lượt thực thi gồm các lượt chụp lại/xác minh. Không cộng các lượt chạy lại thành ca mới.',
              '- Chrome desktop mô phỏng viewport/touch; không thay thế kiểm thử native hoặc thiết bị thật.',
              '- Credential trong bản công bố đã được che. [Artifact Playwright](../../../testing/reports/frontend/e2e/2026-10-19/raw/) giữ log, ảnh, trace và báo cáo HTML.',
              '- [HTML gốc](index.html) cần tải cùng ảnh về để mở; trang Markdown này đọc trực tiếp trên GitHub.']
    write(UI / 'README.md', lines)

    gallery = ['# Thư viện ảnh · Web UI', '',
               '[← Báo cáo và ma trận kết quả](../README.md) · [PDF lỗi giao diện](../Bao_cao_loi_giao_dien_FE_2026-10-19.pdf)', '',
               '**70 ảnh gốc · 11 kịch bản · 3 viewport**', '',
               'Mở từng nhóm bên dưới; bấm ảnh để xem kích thước gốc. Thumbnail chọn ảnh cuối của mỗi ca, các ảnh còn lại có liên kết ngay dưới.', '']
    assert len(list((UI / 'screenshots').glob('*.png'))) == 70
    for case_id, group in sorted(by_id.items()):
        title = next(iter(group.values()))['title']
        passed = sum(c['status'] == 'passed' for c in group.values())
        gallery += [f'<a id="{case_id.lower()}"></a>', '<details open>' if case_id == 'UI-01' else '<details>',
                    f'<summary><strong>{escape(case_id)}</strong> · {escape(title)} · {passed}/3 PASS</summary>', '',
                    '| Mobile · 390 × 844 | Small-mobile · 320 × 568 | Desktop · 1280 × 900 |',
                    '| --- | --- | --- |']
        statuses, previews, all_links = [], [], []
        for project in PROJECTS:
            case = group[project]
            statuses.append(LABELS.get(case['status'], case['status']))
            shots = case['screenshots']
            if shots:
                src = Path(shots[-1]['path']).name
                alt = escape(f'{case_id} {project}', quote=True)
                previews.append(f'<a href="{src}"><img src="{src}" width="220" alt="{alt}"></a>')
            else:
                previews.append('Không có ảnh')
            all_links.append(' · '.join(f"[Ảnh {i}]({Path(s['path']).name})" for i, s in enumerate(shots, 1)))
        gallery += ['| ' + ' | '.join(statuses) + ' |',
                    '| ' + ' | '.join(previews) + ' |',
                    '| ' + ' | '.join(all_links) + ' |', '', '</details>', '']
    write(UI / 'screenshots/README.md', gallery)


def render_flutter():
    cases = json.loads((FLUTTER / 'test-cases.json').read_text(encoding='utf-8'))
    groups = defaultdict(list)
    for case in cases:
        groups[case['file']].append(case)
    placeholders = sum(bool(c['placeholder']) for c in cases)
    lines = ['# Flutter · Báo cáo kiểm thử', '',
             '[← Tổng quan frontend](../README.md) · [Báo cáo văn bản gốc](BAO_CAO_TEST_FE.txt) · [JSON events](flutter-test.jsonl)', '',
             '**Phiên đã lưu ngày 18/10/2026 · 133 PASS · 0 FAIL · 0 SKIP · exit code 0**', '',
             '| Phạm vi | Kết quả | Cách hiểu |',
             '| --- | --- | --- |',
             f'| Ca có assertion dữ liệu/hành vi | {len(cases)-placeholders} PASS | Có kiểm tra dữ liệu hoặc hành vi trong suite hiện có |',
             f'| Placeholder | {placeholders} PASS | Chưa chứng minh luồng QR/BLE, Wi-Fi hoặc điều khiển bơm hoạt động |',
             '| Flutter Chrome | ⏸ CHƯA KIỂM CHỨNG | Kẹt loading khoảng 3 phút, chủ động dừng; chưa có assertion nghiệp vụ |',
             '| Dart analyzer | ⚠ 1 warning, 0 error | `unused_local_variable` trong `api_service.dart` |', '',
             '> Số PASS gồm cả placeholder. Đây không phải tỷ lệ code coverage hoặc xác nhận đầy đủ chức năng ứng dụng.', '',
             '## Kết quả theo file', '',
             '| File test | PASS | Có assertion | Placeholder |',
             '| --- | ---: | ---: | ---: |']
    for file, group in sorted(groups.items()):
        ph = sum(bool(c['placeholder']) for c in group)
        lines.append(f'| [{file}](../../../frontend/test/{file}) | {len(group)} | {len(group)-ph} | {ph} |')
    lines += ['', '## Danh sách từng ca', '',
              'Mở từng file để đọc tên ca và phân biệt placeholder.', '']
    for file, group in sorted(groups.items()):
        lines += ['<details>', f'<summary><strong>{escape(file)}</strong> · {len(group)} ca</summary>', '',
                  '| Ca kiểm thử | Kết quả | Loại |', '| --- | --- | --- |']
        for case in group:
            kind = 'Placeholder' if case['placeholder'] else 'Có assertion'
            lines.append(f"| {cell(case['name'])} | {LABELS.get(case['status'], case['status'])} | {kind} |")
        lines += ['', '</details>', '']
    lines += ['## Log và dữ liệu gốc', '',
              '| Dữ liệu | Liên kết |', '| --- | --- |',
              '| Test events và registry | [JSONL](flutter-test.jsonl) · [Test cases JSON](test-cases.json) · [Exit code](test-exit-code.txt) |',
              '| Chrome loading | [Trạng thái](browser-status.txt) · [Log](browser-test.log) · [Exit code sau khi dừng](browser-test-exit-code.txt) |',
              '| Analyzer | [Issues JSON](analysis-issues.json) · [Console](flutter-analyze.log) · [Exit code](flutter-analyze-exit-code.txt) |',
              '| Mô tả phạm vi và hạn chế | [Báo cáo văn bản gốc](BAO_CAO_TEST_FE.txt) |', '',
              'Trang này được trình bày lại từ dữ liệu đã lưu; không chạy lại suite và không sửa outcome gốc.']
    write(FLUTTER / 'README.md', lines)


if __name__ == '__main__':
    render_ui()
    render_flutter()
    print('Rendered UI report, screenshot gallery and Flutter report from published JSON.')
