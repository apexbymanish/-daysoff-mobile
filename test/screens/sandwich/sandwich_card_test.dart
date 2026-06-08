import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';
import 'package:daysoff_mobile/screens/sandwich/widgets/sandwich_card.dart';

SandwichRecord _rec() => SandwichRecord(
      ptoDate: DateTime(2026, 5, 4),
      weekday: 'Monday',
      breakStart: DateTime(2026, 5, 2),
      breakEnd: DateTime(2026, 5, 5),
      breakLength: 4,
      ptoCost: 1,
      context: "Weekend + Children's Day",
    );

Widget _host(Widget child) =>
    ProviderScope(child: MaterialApp(home: Scaffold(body: child)));

void main() {
  testWidgets('shows "Take … off" headline', (tester) async {
    await tester.pumpWidget(_host(SandwichCard(record: _rec())));
    expect(find.textContaining('Take Monday'), findsOneWidget);
    expect(find.textContaining('May 4'), findsWidgets);
    expect(find.textContaining('off'), findsWidgets);
  });

  testWidgets('shows PTO pill', (tester) async {
    await tester.pumpWidget(_host(SandwichCard(record: _rec())));
    // Pill text is "1 PTO" via labelCaps
    expect(find.textContaining('1 PTO'), findsOneWidget);
  });

  testWidgets('ptoDate cell is highlighted (4 day-cells rendered)', (tester) async {
    await tester.pumpWidget(_host(SandwichCard(record: _rec())));
    // breakStart=May2, breakEnd=May5 → 4 cells; ptoDate=May4 is highlighted.
    // Verify all four date numerals are present.
    expect(find.text('2'), findsWidgets);
    expect(find.text('3'), findsWidgets);
    expect(find.text('4'), findsWidgets);
    expect(find.text('5'), findsWidgets);
  });

  testWidgets('multi-PTO bridge: "Take N days off" + all PTO days listed',
      (tester) async {
    // 2-PTO bridge: take Feb 19 + 20 for a 9-day Lunar New Year break.
    final rec = SandwichRecord(
      ptoDate: DateTime(2026, 2, 19),
      ptoDates: [DateTime(2026, 2, 19), DateTime(2026, 2, 20)],
      weekday: 'Thursday',
      breakStart: DateTime(2026, 2, 14),
      breakEnd: DateTime(2026, 2, 22),
      breakLength: 9,
      ptoCost: 2,
      context: 'Korean New Year',
    );
    await tester.pumpWidget(_host(SandwichCard(record: rec)));
    expect(find.textContaining('Take 2 days off'), findsOneWidget);
    expect(find.textContaining('2 PTO'), findsOneWidget);
    // Both PTO numerals (19, 20) render in the 9-cell ribbon.
    expect(find.text('19'), findsWidgets);
    expect(find.text('20'), findsWidgets);
  });

  testWidgets('Save adds to savedBreaksProvider (length 1)', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: Scaffold(body: SandwichCard(record: _rec()))),
    ));
    await tester.tap(find.text('Save + remind'));
    await tester.pump();
    expect(container.read(savedBreaksProvider).length, 1);
  });
}
