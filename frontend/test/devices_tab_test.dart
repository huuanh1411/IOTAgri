import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iotagri_app/core/theme/app_theme.dart';
import 'package:iotagri_app/core/widgets/floating_pill_nav_bar.dart';
import 'package:iotagri_app/core/widgets/page_header.dart';
import 'package:iotagri_app/router.dart';
import 'package:iotagri_app/screens/devices/devices_screen.dart';
import 'package:iotagri_app/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Map<String, dynamic> device(String name) => {
  'id': name, 'name': name, 'isOnline': true,
  'createdAt': '2026-10-01T00:00:00Z',
  'lastSeenAt': '2026-10-16T08:30:00Z',
};

class ListApi extends ApiService {
  List<dynamic> devices = [device('Tháp 1')];
  Completer<List<dynamic>>? pending;
  bool fail = false;
  @override
  Future<List<dynamic>> getDevices() async {
    if (fail) throw Exception('Mất kết nối');
    return pending == null ? devices : pending!.future;
  }
  @override
  Future<Map<String, dynamic>> createDevice(String name) async {
    final added = device(name);
    devices = [...devices, added];
    return added;
  }
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('five tab taps select corresponding shell branch and preserve URLs', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(goRouterProvider);
    addTearDown(router.dispose);
    final shell = router.configuration.routes.whereType<StatefulShellRoute>().single;
    expect(shell.branches.map((b) => (b.routes.first as GoRoute).path),
      ['/home', '/alerts', '/pick', '/devices', '/other']);
    final devicesRoute = shell.branches[3].routes.first as GoRoute;
    expect(devicesRoute.name, 'devices');
    final other = shell.branches[4].routes.first as GoRoute;
    expect(other.routes.whereType<GoRoute>().map((r) => r.path), ['settings', 'harvest', 'help']);

    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var selected = 0;
    await tester.pumpWidget(MaterialApp(home: StatefulBuilder(builder: (context, setState) {
      return Scaffold(bottomNavigationBar: FloatingPillNavBar(
        currentIndex: selected,
        onTap: (index) => setState(() => selected = index),
      ));
    })));
    for (final (index, label) in ['Trang chủ', 'Cảnh báo', 'Chọn giống', 'Thiết bị', 'Khác'].indexed) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(selected, index);
      expect(tester.takeException(), isNull);
    }
  });

  Future<void> mount(WidgetTester tester, ListApi api) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: DevicesScreen(apiService: api)));
    await tester.pump();
  }

  testWidgets('list uses page header and fits long names/actions at 320px', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = ListApi()..devices = [device('Tháp rau rất dài ở khu vườn phía đông')];
    await mount(tester, api);
    expect(find.byType(PageHeader), findsOneWidget);
    expect(find.text('Chi tiết'), findsOneWidget);
    expect(find.text('Mã thiết lập'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search filters case-insensitively and shows no matches', (tester) async {
    final api = ListApi()..devices = List.generate(7, (i) => device('Tháp $i'));
    await mount(tester, api);
    await tester.enterText(find.byType(CupertinoSearchTextField), 'THÁP 2');
    await tester.pump();
    expect(find.text('Tháp 2'), findsOneWidget);
    expect(find.text('Tháp 0'), findsNothing);
    await tester.enterText(find.byType(CupertinoSearchTextField), 'không có');
    await tester.pump();
    expect(find.text('Không tìm thấy thiết bị.'), findsOneWidget);
  });

  testWidgets('loading, error retry, empty and create remain usable', (tester) async {
    final api = ListApi()..pending = Completer<List<dynamic>>();
    await mount(tester, api);
    expect(find.text('Đang tải thiết bị...'), findsOneWidget);
    api.pending!.completeError(Exception('Mất kết nối'));
    await tester.pumpAndSettle();
    expect(find.text('Đã xảy ra lỗi'), findsOneWidget);
    api.pending = null;
    api.devices = [];
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có thiết bị nào'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Tháp mới');
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    expect(find.text('Tháp mới'), findsOneWidget);
    expect(find.text('Thêm thiết bị thành công'), findsOneWidget);
  });

  testWidgets('pull refresh updates short list', (tester) async {
    final api = ListApi();
    await mount(tester, api);
    api.devices = [device('Đã làm mới')];
    await tester.drag(find.byType(ListView), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(find.text('Đã làm mới'), findsOneWidget);
  });
}
