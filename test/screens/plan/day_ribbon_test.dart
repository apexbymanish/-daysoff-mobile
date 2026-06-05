import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/screens/plan/widgets/day_ribbon.dart';

void main() {
  testWidgets('renders a letter pill per day (P for PTO, W for weekend)',
      (tester) async {
    // 2026-01-03 is Saturday (weekend); 2026-01-05 is Monday, marked PTO.
    final trip = PlanTrip(
      breakStart: DateTime(2026, 1, 3),
      breakEnd: DateTime(2026, 1, 5),
      breakLength: 3,
      ptoDates: [DateTime(2026, 1, 5)],
      ptoCost: 1,
      anchors: const ['X'],
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DayRibbon(trip: trip))),
    );
    expect(find.text('P'), findsWidgets);
    expect(find.text('W'), findsWidgets);
  });
}
