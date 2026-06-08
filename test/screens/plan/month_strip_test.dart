import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/plan_view_provider.dart';
import 'package:daysoff_mobile/screens/plan/widgets/month_strip.dart';

void main() {
  testWidgets('renders "All" chip and all 12 month chips', (tester) async {
    // Use a wide viewport so all chips fit without scrolling.
    tester.view.physicalSize = const Size(1600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: MonthStrip()),
        ),
      ),
    );

    expect(find.byKey(const Key('month-all')), findsOneWidget);
    for (int m = 1; m <= 12; m++) {
      expect(find.byKey(Key('month-$m')), findsOneWidget);
    }
  });

  testWidgets('tapping Mar chip sets planMonthProvider == 3', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: MonthStrip()),
        ),
      ),
    );

    // Default is null (All)
    expect(container.read(planMonthProvider), isNull);

    // Tap the Mar chip
    await tester.tap(find.byKey(const Key('month-3')));
    await tester.pump();

    expect(container.read(planMonthProvider), equals(3));
  });

  testWidgets('tapping month-all resets planMonthProvider to null',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Pre-set to month 3
    container.read(planMonthProvider.notifier).state = 3;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: MonthStrip()),
        ),
      ),
    );

    // Confirm initial state
    expect(container.read(planMonthProvider), equals(3));

    // Tap All
    await tester.tap(find.byKey(const Key('month-all')));
    await tester.pump();

    expect(container.read(planMonthProvider), isNull);
  });
}
