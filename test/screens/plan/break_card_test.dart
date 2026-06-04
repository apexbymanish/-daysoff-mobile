import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/screens/plan/widgets/break_card.dart';
import 'package:daysoff_mobile/screens/plan/widgets/pto_cost_pill.dart';

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
    await tester.pumpWidget(_host(BreakCard(trip: _trip(), onTap: () {})));
    expect(find.text('5 days'), findsOneWidget);
    expect(find.text('1 PTO'), findsOneWidget);
    expect(find.textContaining('Chuseok'), findsOneWidget);
  });

  testWidgets('tapping the card fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(BreakCard(trip: _trip(), onTap: () => tapped = true)));
    await tester.tap(find.byType(BreakCard));
    expect(tapped, isTrue);
  });

  testWidgets('PtoCostPill formats zero as Free', (tester) async {
    await tester.pumpWidget(_host(const PtoCostPill(cost: 0)));
    expect(find.text('Free'), findsOneWidget);
  });
}
