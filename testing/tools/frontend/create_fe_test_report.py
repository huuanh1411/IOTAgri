import collections
import json
import re
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'docs/testing/2026-10-18-frontend'

def events(path):
    result = []
    for line in path.read_text(encoding='utf-8', errors='replace').splitlines():
        try:
            event = json.loads(line)
            if isinstance(event, dict) and 'type' in event:
                result.append(event)
        except ValueError:
            pass
    return result

es = events(OUT / 'flutter-test.jsonl')
starts = {e['test']['id']: e['test'] for e in es if e['type'] == 'testStart'}
suites = {e['suite']['id']: e['suite'] for e in es if e['type'] == 'suite'}
rows = []
for e in es:
    if e['type'] != 'testDone' or e.get('hidden'):
        continue
    t = starts[e['testID']]
    file = Path(suites[t['suiteID']]['path']).name
    rows.append(dict(file=file, name=t['name'], line=t.get('line'),
                     status='skipped' if e.get('skipped') else e['result'],
                     placeholder=file in ('add_device_test.dart', 'pump_control_test.dart')))
(OUT / 'test-cases.json').write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding='utf-8')

scopes = {
 'active_plant_controller_test.dart': 'Chọn cây đang trồng, lưu/khôi phục ngày bắt đầu, giới hạn tiến độ tăng trưởng.',
 'add_device_test.dart': 'Tên ca mô tả QR/BLE, Wi-Fi, claim code, điều hướng, đặt tên; toàn bộ 35 ca là placeholder, không thao tác ứng dụng.',
 'alert_center_provider_test.dart': 'Số cảnh báo chưa đọc, lọc mức nghiêm trọng, chống lặp, giờ yên lặng, chuyển trạng thái, deep link thông báo.',
 'api_contract_models_test.dart': 'Ánh xạ dashboard DTO giữ ID thiết bị/cảnh báo và số tin nhắn hỗ trợ.',
 'app_motion_test.dart': 'Tắt hoạt ảnh theo cài đặt, hiệu ứng xuất hiện kết thúc, thời lượng animation.',
 'dio_repositories_test.dart': 'Repository ticket với API giả, cấu hình Dio/interceptor, định tuyến telemetry và trạng thái reconnect của realtime stub.',
 'history_flow_test.dart': 'Min/trung bình/max, đơn vị cảm biến, dữ liệu tổng hợp, tạo CSV và PDF.',
 'live_sensor_contract_test.dart': 'Ánh xạ nhiệt độ dung dịch và độ ẩm không khí từ DTO mẫu sang lịch sử.',
 'device_settings_test.dart': 'Thông tin thiết bị/Wi-Fi offline, đổi tên và validate, xác nhận xóa, điều hướng sau xóa.',
 'phase12_global_states_a11y_test.dart': 'Banner offline/online, dịch Việt–Anh, đổi ngôn ngữ, phóng chữ 1.5x, Semantics cho trình đọc màn hình.',
 'phase11_account_support_test.dart': 'Trang tài khoản, lưu thiết lập, đổi mật khẩu, lọc/tạo ticket và gửi phản hồi với dữ liệu giả.',
 'pump_control_test.dart': 'Tên ca mô tả Auto/Manual, bật/tắt, timeout, chống chạy khô và đếm ngược; toàn bộ 22 ca là placeholder.',
 'phase13_widget_variants_test.dart': 'Dashboard rỗng/bình thường/cần chú ý/nguy cấp; thiết bị online/offline/thiếu dữ liệu/bơm chạy/đang gửi. Hai test validate lịch chỉ kiểm tra hàm định nghĩa trong test.',
 'water_pump_control_panel_test.dart': 'Bật/tắt bơm mô phỏng cục bộ, chặn khi nước dưới 30%, form lịch và múi giờ Việt Nam; không điều khiển bơm thật.',
 'widget_test.dart': 'Đăng ký/đăng nhập, dashboard, tìm/hiện/xóa/tạo thiết bị, tài khoản, trạng thái cảm biến và điều khiển bơm với fake API.',
 'phase13_integration_flow_test.dart': 'Widget flow đăng nhập → chi tiết thiết bị → chạy bơm → lịch sử → mở tùy chọn xuất; API giả, thiết bị được tạo trực tiếp trong test, chưa kiểm tra luồng thêm thiết bị thật hoặc tải tệp qua UI.',
}

raw_analysis = (OUT / 'flutter-analyze.log').read_text(encoding='utf-8', errors='replace')
issues = []
for line in raw_analysis.splitlines():
    parts = [p.strip() for p in line.split(' • ')]
    if len(parts) < 4:
        parts = [p.strip() for p in line.split(' - ')]
    if len(parts) >= 4 and parts[0] in ('info', 'warning', 'error'):
        issues.append(dict(severity=parts[0], message=' - '.join(parts[1:-2]), location=parts[-2], rule=parts[-1]))
(OUT / 'analysis-issues.json').write_text(json.dumps(issues, ensure_ascii=False, indent=2), encoding='utf-8')
severities = collections.Counter(i['severity'] for i in issues)
rules = collections.Counter(i['rule'] for i in issues)
explain = {
 'unused_import': 'Import không được sử dụng; tăng nhiễu và nên xóa nếu không cần.',
 'unused_local_variable': 'Biến cục bộ được khai báo nhưng không sử dụng; cần kiểm tra logic có bỏ sót hay chỉ là mã thừa.',
 'unused_field': 'Field không được đọc/sử dụng; cần kiểm tra chức năng chưa nối vào luồng ứng dụng hay mã thừa.',
 'unused_element': 'Hàm/lớp/thành phần không được sử dụng; cần xem có mã tính năng chưa tích hợp.',
 'use_build_context_synchronously': 'Dùng BuildContext sau một await có thể truy cập widget đã bị dispose. Cần kiểm tra mounted trước khi dùng context. Đây là nguy cơ runtime, không phải crash đã tái hiện.',
 'deprecated_member_use': 'Đang gọi API đã bị đánh dấu deprecated; hiện vẫn chạy nhưng cần thay API tương ứng khi nâng SDK.',
 'unnecessary_import': 'Import dư do biểu tượng đã được cung cấp bởi import khác.',
 'prefer_const_constructors': 'Có thể dùng const cho constructor để giảm tạo lại đối tượng; vấn đề phong cách/tối ưu.',
 'prefer_const_literals_to_create_immutables': 'Có thể dùng collection const; vấn đề phong cách/tối ưu.',
 'prefer_final_fields': 'Field không thay đổi sau khởi tạo nên dùng final.',
 'avoid_print': 'Có print trong mã ứng dụng; nên dùng cơ chế logging phù hợp.',
 'curly_braces_in_flow_control_structures': 'Nhánh if/for thiếu dấu ngoặc khối; giảm độ rõ ràng và dễ sửa nhầm.',
 'unnecessary_to_list_in_spreads': 'Gọi toList trước spread không cần thiết.',
 'library_private_types_in_public_api': 'API public lộ kiểu private; cần điều chỉnh phạm vi hoặc kiểu trả về.',
 'unnecessary_underscores': 'Tên tham số dùng nhiều dấu gạch dưới không cần thiết.',
 'unnecessary_string_interpolations': 'Nội suy chuỗi không cần thiết.',
 'prefer_is_empty': 'Nên dùng isEmpty để biểu đạt kiểm tra rỗng.',
 'sized_box_for_whitespace': 'Nên dùng SizedBox khi chỉ tạo khoảng trống.',
 'unnecessary_non_null_assertion': 'Dấu ! không cần thiết vì kiểu đã không nullable.',
 'dead_code': 'Đoạn mã không bao giờ được chạy; cần kiểm tra điều kiện hoặc mã thừa.',
 'avoid_unnecessary_containers': 'Container không tạo hiệu ứng cần thiết, có thể bỏ lớp bọc.',
 'use_super_parameters': 'Có thể dùng super parameter để rút gọn constructor.',
}
now = datetime.now(timezone(timedelta(hours=7))).isoformat(timespec='seconds')
lines = [
 'BÁO CÁO KIỂM THỬ FRONTEND IOTAGRI',
 f'Thời điểm lập: {now} (giờ Việt Nam)',
 'Phạm vi: kiểm thử tự động có sẵn của frontend Flutter và phân tích tĩnh Dart. Không sửa mã frontend/test trong lượt kiểm tra này.',
 '', '1. KẾT QUẢ',
 f'Test mặc định: {len(rows)} ca; đạt {sum(r["status"] == "success" for r in rows)}, lỗi {sum(r["status"] in ("error", "failure") for r in rows)}, bỏ qua {sum(r["status"] == "skipped" for r in rows)}. Exit code: 0.',
 'Không tính 16 sự kiện loading file là ca kiểm thử nghiệp vụ.',
 'Trong 133 ca đạt: 57 placeholder (35 thêm thiết bị + 22 điều khiển bơm), 76 ca có assertion về dữ liệu/hành vi. Con số này không phải tỷ lệ code coverage.',
 'Test Chrome: CHƯA KIỂM CHỨNG. add_device_web_test.dart kẹt ở loading khoảng 3 phút, không phát sinh sự kiện testStart cho ca nghiệp vụ, được chủ động dừng để hoàn tất báo cáo.',
 'Không coi exit code sau khi dừng Chrome là assertion thất bại của ứng dụng. Chưa xác định nguyên nhân Chrome không hoàn tất tải test.',
 f'Phân tích tĩnh: {len(issues)} vấn đề; error={severities["error"]}, warning={severities["warning"]}, info={severities["info"]}. Xem flutter-analyze-exit-code.txt cho exit code nguyên gốc.',
 '', '2. ĐÃ TEST VỀ PHẦN GÌ',
]
byfile = collections.defaultdict(list)
for row in rows:
    byfile[row['file']].append(row)
for file, tests in sorted(byfile.items()):
    lines += [f'{file}: {len(tests)} ca, {sum(t["status"] == "success" for t in tests)} đạt.', '  ' + scopes.get(file, '')]
lines += [
 'add_device_web_test.dart: mong đợi web chỉ cho nhập claim code, không hiện quét thiết bị gần/BLE, không ném exception dart:io. Ca này chưa chạy tới assertion.',
 '', '3. LỖI/ĐIỂM CẦN XỬ LÝ VÀ Ý NGHĨA',
 'A. Assertion/runtime trong lượt unit/widget test: không ghi nhận ca thất bại. Không thể suy ra mọi chức năng đều đúng từ kết quả này.',
 'B. Thiếu độ bao phủ: 57 placeholder chỉ dùng expect(true, isTrue). Nếu QR/BLE/Wi-Fi/timeout/đếm ngược hoặc điều khiển bơm bị lỗi, 57 test này vẫn có thể xanh.',
 '  Tái hiện: mở frontend/test/add_device_test.dart hoặc pump_control_test.dart; mỗi test chỉ kiểm tra hằng true. Cần thay bằng thao tác widget/controller và kiểm tra kết quả thực.',
 'C. Chrome loading chưa hoàn tất: log browser-test.log kết thúc tại loading và allSuites, không có testDone nghiệp vụ; kiểm tra riêng môi trường runner/browser trước khi kết luận lỗi UI.',
 'D. Phân tích mã: các nhóm dưới đây là cảnh báo/lint tĩnh, không tự động tương đương lỗi người dùng đã gặp.',
    'Cụ thể api_service.dart:509:33 — getPumpCommands tạo tham số truy vấn to bằng now, nhưng pattern if (rangeHours case final r?) khai báo r rồi không sử dụng.',
    '  Mong đợi: chỉ kiểm tra rangeHours khác null khi thêm tham số to; thực tế: thêm một biến cục bộ thừa. Gợi ý: if (rangeHours != null) cho dòng to. Không sửa mã trong lượt báo cáo.',
    '  Tác động đã quan sát: flutter analyze trả exit code 1 vì warning; unit/widget tests vẫn đạt. Chưa chứng minh lỗi truy vấn lịch sử hoặc lỗi runtime.',
]
for rule, count in rules.most_common():
    subset = [i for i in issues if i['rule'] == rule]
    lines += ['', f'{rule}: {count} vị trí ({", ".join(sorted({i["severity"] for i in subset}))}).',
              '  Ý nghĩa: ' + explain.get(rule, 'Xem thông báo gốc và từng vị trí dưới đây; cần đánh giá trong ngữ cảnh trước khi kết luận ảnh hưởng chức năng.')]
    for i in subset:
        lines.append(f'  - frontend/{i["location"]}: {i["message"]}')
lines += [
 '', '4. GIỚI HẠN CẦN BIẾT',
 'Nhiều test dùng fake API, mock lưu trữ và realtime stub. Không kiểm tra tài khoản thật, JWT qua backend thật, ESP32/MQTT thật, hay bật/tắt bơm vật lý.',
 'Test tích hợp hiện tại là widget test với API giả. Test tạo CSV/PDF riêng có kiểm tra tệp, nhưng widget flow export chỉ xác nhận mở sheet và các lựa chọn.',
 'Các test validation lịch trong phase13_widget_variants_test.dart định nghĩa hàm validate trong test; chưa chứng minh UI hoặc backend áp dụng cùng logic.',
 'Chưa chạy mọi test trên browser, Android/iOS, kiểm thử tải, bảo mật hay code coverage.',
 '', '5. TÁI CHẠY',
 'Chạy từ frontend, đặt PUB_CACHE trỏ tới .runtime/pub-cache và dùng .runtime/flutter/bin/flutter.bat của repo.',
 '../.runtime/flutter/bin/flutter.bat test --no-pub --machine',
 '../.runtime/flutter/bin/flutter.bat test --no-pub --platform chrome --machine test/add_device_web_test.dart',
 '../.runtime/flutter/bin/flutter.bat analyze --no-pub',
 '', '6. DANH SÁCH TỪNG CA ĐÃ CHẠY',
]
for idx, row in enumerate(rows, 1):
    lines.append(f'{idx:03d}. [{row["status"].upper()}]{" [PLACEHOLDER]" if row["placeholder"] else ""} {row["file"]}:{row["line"] or "?"} | {row["name"]}')
lines += ['', '7. TỆP ĐÍNH KÈM',
 'flutter-test.jsonl: log thô đầy đủ, gồm testStart/testDone và output của test.',
 'flutter-test.stderr.log: stderr của lượt test mặc định.',
 'test-cases.json: danh sách 133 ca và đánh dấu placeholder để xử lý tự động.',
 'browser-test.log / browser-test.stderr.log / browser-status.txt: bằng chứng và trạng thái test Chrome.',
 'flutter-analyze.log / flutter-analyze.stderr.log: toàn bộ kết quả phân tích tĩnh.',
 'analysis-issues.json: toàn bộ vấn đề phân tích tĩnh có mức độ, vị trí, rule và mô tả gốc.',
 '*exit-code.txt: exit code nguyên gốc; mã lỗi Chrome do chủ động dừng runner, không phải test assertion.',
]
(OUT / 'BAO_CAO_TEST_FE.txt').write_text('\n'.join(lines) + '\n', encoding='utf-8')
print(json.dumps(dict(tests=len(rows), placeholders=57, static_issues=len(issues), severities=dict(severities), rules=dict(rules)), ensure_ascii=True))
