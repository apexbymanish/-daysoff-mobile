import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
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

// The query the screen builds using provider defaults:
// budget=15, minLength=3, maxLength=10, workweek=['sat','sun']
const _kQuery = PlanQuery(
  country: 'KR',
  year: 2026,
  budget: 15,
  minLength: 3,
  maxLength: 10,
  workweek: ['sat', 'sun'],
);

void main() {
  testWidgets('renders BreakCard widgets and numerals for each length', (tester) async {
    // With the new card, length is two separate Text widgets: '3'+'days' / '5'+'days'.
    // We assert BreakCard count + numerals visible (findsWidgets for text that
    // may appear in multiple cards) and the specific anchor texts.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        planProvider(_kQuery).overrideWith((ref) async => _resp()),
      ],
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: PlanScreen()),
    ));
    await tester.pumpAndSettle();
    // At least both BreakCards are built (list view renders all).
    expect(find.byType(BreakCard), findsWidgets);
    // Numerals as separate text widgets.
    expect(find.text('3'), findsWidgets);
    expect(find.text('5'), findsWidgets);
    // 'days' label appears at least once.
    expect(find.text('days'), findsWidgets);
    // Anchor names visible.
    expect(find.textContaining('Hangul Day'), findsOneWidget);
    expect(find.textContaining('Chuseok'), findsOneWidget);
  });

  testWidgets('error state shows Retry', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        planProvider(_kQuery)
            .overrideWith((ref) async => throw Exception('boom')),
      ],
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: PlanScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });
}
