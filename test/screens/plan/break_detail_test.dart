import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';
import 'package:daysoff_mobile/screens/plan/break_detail_screen.dart';

void main() {
  testWidgets('shows day-by-day rows and PTO summary', (tester) async {
    final trip = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(home: BreakDetailScreen(trip: trip)),
    ));
    expect(find.text('5-day break'), findsOneWidget);
    expect(find.textContaining('1 PTO'), findsOneWidget);
    // One row per day in the break (23,24,25,26,27 = 5 rows).
    expect(find.byKey(const ValueKey('break-day-row')), findsNWidgets(5));
  });

  testWidgets('Save this break adds to savedBreaksProvider', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final trip = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: BreakDetailScreen(trip: trip)),
    ));
    await tester.tap(find.text('Save this break'));
    await tester.pump();
    expect(container.read(savedBreaksProvider).length, 1);
  });
}
