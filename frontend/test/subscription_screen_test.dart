import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/l10n/app_localizations.dart';
import 'package:iotagri_app/models/crop_subscription.dart';
import 'package:iotagri_app/screens/subscription_screen.dart';
import 'package:iotagri_app/services/api_service.dart';

class _FakeApiService extends ApiService {
  bool active = false;
  String? createdDeviceId;
  String? createdCropName;

  @override
  Future<List<dynamic>> getDevices() async => [
    {
      'id': 'device-1',
      'name': 'Giàn rau sân thượng',
      'isOnline': true,
      'createdAt': '2026-11-25T00:00:00Z',
    },
  ];

  @override
  Future<CropSubscriptionPayment> createCropSubscription({
    required String deviceId,
    required String cropName,
  }) async {
    createdDeviceId = deviceId;
    createdCropName = cropName;
    return _payment(status: 'Pending');
  }

  @override
  Future<List<CropSubscription>> getSubscriptions() async => [
    _payment(status: active ? 'Active' : 'Pending').subscription,
  ];

  CropSubscriptionPayment _payment({required String status}) => CropSubscriptionPayment(
    subscription: CropSubscription(
      id: 'subscription-1',
      deviceId: 'device-1',
      cropName: 'Xà lách',
      amountVnd: 50000,
      paymentCode: 'AGPAYMENT123',
      status: status,
      createdAt: DateTime.utc(2030, 11, 25),
      paymentExpiresAt: DateTime.utc(2030, 11, 25, 1),
      paidAt: status == 'Active' ? DateTime.utc(2030, 11, 25, 0, 5) : null,
      expiresAt: status == 'Active' ? DateTime.utc(2030, 12, 25, 0, 5) : null,
    ),
    bankCode: 'MB',
    accountNumber: '1234567890',
    accountName: 'AEROGREEN',
  );
}

Widget _app(ApiService api) => MaterialApp(
  locale: const Locale('vi'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: SubscriptionScreen(apiService: api),
);

Future<void> _selectLettuce(WidgetTester tester) async {
  final cropPicker = find.byType(DropdownButtonFormField<String>);
  await tester.ensureVisible(cropPicker);
  await tester.tap(cropPicker);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Xà lách').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows a back button in the subscription header', (tester) async {
    await tester.pumpWidget(_app(_FakeApiService()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('creates a server-backed payment request for the selected device', (
    tester,
  ) async {
    final api = _FakeApiService();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();

    expect(find.text('Giàn rau sân thượng'), findsOneWidget);
    await _selectLettuce(tester);
    await tester.tap(find.text('Tiếp tục thanh toán'));
    await tester.pumpAndSettle();

    expect(api.createdDeviceId, 'device-1');
    expect(api.createdCropName, 'Xà lách');
    expect(find.text('50.000 đ'), findsOneWidget);
    expect(find.text('AGPAYMENT123'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Đang chờ thanh toán'), findsOneWidget);
  });

  testWidgets('renders VietQR as a PNG supported by Flutter', (tester) async {
    final api = _FakeApiService();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await _selectLettuce(tester);
    await tester.tap(find.text('Tiếp tục thanh toán'));
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, contains('compact2.png'));
  });

  testWidgets('formats a payment amount without a leading separator', (tester) async {
    final api = _FakeApiService();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await _selectLettuce(tester);
    await tester.tap(find.text('Tiếp tục thanh toán'));
    await tester.pump();

    expect(find.text('.50.000 đ'), findsNothing);
    expect(find.text('50.000 đ'), findsOneWidget);
  });

  testWidgets('centers the subscription content on wide screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_FakeApiService()));
    await tester.pumpAndSettle();

    final header = tester.getTopLeft(find.text('Gói dịch vụ'));
    expect(header.dx, 220);
    expect(header.dy, 24);
  });

  testWidgets('refreshes the status supplied by the subscription endpoint', (
    tester,
  ) async {
    final api = _FakeApiService();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await _selectLettuce(tester);
    await tester.tap(find.text('Tiếp tục thanh toán'));
    await tester.pumpAndSettle();

    api.active = true;
    final refresh = find.text('Cập nhật trạng thái thanh toán');
    await tester.ensureVisible(refresh);
    await tester.tap(refresh);
    await tester.pumpAndSettle();

    expect(find.text('Thanh toán thành công'), findsOneWidget);
  });

  testWidgets('payment details fit a 320 px phone without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = _FakeApiService();
    await tester.pumpWidget(_app(api));
    await tester.pumpAndSettle();
    await _selectLettuce(tester);
    await tester.tap(find.text('Tiếp tục thanh toán'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('AGPAYMENT123'), findsOneWidget);
  });
}
