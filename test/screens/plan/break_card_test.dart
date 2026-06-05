import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/screens/plan/widgets/break_card.dart';

PlanTrip _trip() => PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('BreakCard shows length, range, PTO pill and anchor', (tester) async {
    // New card: length + "days" are separate Text widgets; PTO pill shows "1 PTO USED".
    await tester.pumpWidget(_host(BreakCard(trip: _trip(), onTap: () {})));
    expect(find.text('5'), findsWidgets); // numeral
    expect(find.text('days'), findsWidgets); // label beside numeral
    expect(find.textContaining('PTO USED'), findsOneWidget);
    expect(find.textContaining('Chuseok'), findsOneWidget);
  });

  testWidgets('tapping the card fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(BreakCard(trip: _trip(), onTap: () => tapped = true)));
    await tester.tap(find.byType(BreakCard));
    expect(tapped, isTrue);
  });

  testWidgets('zero PTO shows red pill with 0 PTO USED', (tester) async {
    final freeTrip = PlanTrip(
      breakStart: DateTime(2026, 10, 3),
      breakEnd: DateTime(2026, 10, 5),
      breakLength: 3,
      ptoDates: const [],
      ptoCost: 0,
      anchors: const ['Foundation Day'],
    );
    await tester.pumpWidget(_host(BreakCard(trip: freeTrip)));
    expect(find.text('0 PTO USED'), findsOneWidget);
  });

  testWidgets('isBestValue shows Details button and badge', (tester) async {
    await tester.pumpWidget(_host(BreakCard(trip: _trip(), isBestValue: true, onTap: () {})));
    expect(find.text('Details ›'), findsOneWidget);
    expect(find.text('BEST VALUE'), findsOneWidget);
  });
}
