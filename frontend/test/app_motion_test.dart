import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iotagri_app/core/animation/app_motion.dart';

void main() {
  testWidgets('motion durations collapse when animations are disabled', (
    tester,
  ) async {
    late Duration effectiveDuration;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            effectiveDuration = AppMotion.duration(context, AppMotion.chart);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(effectiveDuration, Duration.zero);
  });

  testWidgets('card entrance completes once without a repeating ticker', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppMotionEntrance(index: 7, child: Text('sensor-card')),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('sensor-card'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
  });

  test('motion tokens stay inside the requested timing ranges', () {
    expect(AppMotion.toggle.inMilliseconds, inInclusiveRange(150, 200));
    expect(AppMotion.tabSwitch.inMilliseconds, inInclusiveRange(200, 250));
    expect(
      AppMotion.navigationIndicator.inMilliseconds,
      inInclusiveRange(200, 300),
    );
    expect(AppMotion.status.inMilliseconds, inInclusiveRange(200, 300));
    expect(AppMotion.detailOpen.inMilliseconds, inInclusiveRange(250, 300));
    expect(AppMotion.cardEntrance.inMilliseconds, inInclusiveRange(250, 350));
    expect(AppMotion.chart.inMilliseconds, inInclusiveRange(300, 500));
    expect(AppMotion.cardDelay(7), const Duration(milliseconds: 280));
    expect(AppMotion.cardDelay(20), const Duration(milliseconds: 280));
  });
}
