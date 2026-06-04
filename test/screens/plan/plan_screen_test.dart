import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/providers/plan_provider.dart';
import 'package:daysoff_mobile/screens/plan/plan_screen.dart';
import 'package:daysoff_mobile/screens/plan/widgets/break_card.dart';

PlanResponse _resp() => PlanResponse(
      country: 'KR',
      year: 2026,
      budget: 15,
      workweek: const ['sat', 'sun'],
      workweekSource: 'default',
      resultsByLength: {
        '3': [
          PlanTrip(
            breakStart: DateTime(2026, 10, 9),
            breakEnd: DateTime(2026, 10, 11),
            breakLength: 3,
            ptoDates: const [],
            ptoCost: 0,
            anchors: const ['Hangul Day'],
          ),
        ],
        '5': [
          PlanTrip(
            breakStart: DateTime(2026, 9, 23),
            breakEnd: DateTime(2026, 9, 27),
            breakLength: 5,
            ptoDates: [DateTime(2026, 9, 23)],
            ptoCost: 1,
            anchors: const ['Chuseok'],
          ),
        ],
      },
    );

void main() {
  testWidgets('renders one BreakCard per length, ascending', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        planProvider(const PlanQuery(country: 'KR', year: 2026, budget: 15))
            .overrideWith((ref) async => _resp()),
      ],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(BreakCard), findsNWidgets(2));
    expect(find.text('3 days'), findsOneWidget);
    expect(find.text('5 days'), findsOneWidget);
  });

  testWidgets('error state shows Retry', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        planProvider(const PlanQuery(country: 'KR', year: 2026, budget: 15))
            .overrideWith((ref) async => throw Exception('boom')),
      ],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });
}
