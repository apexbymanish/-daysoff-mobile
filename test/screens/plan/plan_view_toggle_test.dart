import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/api/models/sandwiches_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/plan/plan_screen.dart';
import 'package:daysoff_mobile/screens/plan/widgets/break_card.dart';
import 'package:daysoff_mobile/screens/sandwich/widgets/sandwich_card.dart';

// ── Fake ApiClient ─────────────────────────────────────────────────────────────

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(dio: null);

  @override
  Future<SandwichesResponse> getSandwiches({
    required String country,
    required int year,
    List<String>? workweek,
  }) async =>
      SandwichesResponse(
        country: country,
        year: year,
        workweek: workweek ?? const [],
        workweekSource: 'default',
        count: 1,
        sandwiches: [
          SandwichRecord(
            ptoDate: DateTime(2026, 5, 4),
            weekday: 'Monday',
            breakStart: DateTime(2026, 5, 2),
            breakEnd: DateTime(2026, 5, 5),
            breakLength: 4,
            ptoCost: 1,
            context: "Weekend + Children's Day",
          ),
        ],
      );

  @override
  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
    List<String>? workweek,
  }) async =>
      PlanResponse(
        country: country,
        year: year,
        budget: budget,
        workweek: workweek ?? const [],
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
        },
      );
}

// Build the app with a fake ApiClient so both providers resolve from it.
Widget _buildApp() => ProviderScope(
      overrides: [
        apiClientProvider.overrideWith((ref) => _FakeApiClient()),
      ],
      child: const MaterialApp(home: PlanScreen()),
    );

void main() {
  testWidgets(
      'toggling to "Sandwich days" shows SandwichCard, toggling back shows carousel',
      (tester) async {
    await tester.pumpWidget(_buildApp());
    // Let futures resolve
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Default view = buffet → BreakCard should be present
    await tester.pumpAndSettle();
    expect(find.byType(BreakCard), findsWidgets);
    expect(find.byType(SandwichCard), findsNothing);

    // Tap "Sandwich days" segment
    await tester.tap(find.text('Sandwich days'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    // Sandwich view: SandwichCard visible
    expect(find.byType(SandwichCard), findsOneWidget);
    expect(find.byType(BreakCard), findsNothing);

    // Tap "Length buffet" to switch back
    await tester.tap(find.text('Length buffet'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    // Back to buffet → BreakCard visible again
    expect(find.byType(BreakCard), findsWidgets);
    expect(find.byType(SandwichCard), findsNothing);
  });

  testWidgets('sandwich view shows subtitle text', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Sandwich days'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Single workdays wedged between days off'),
      findsOneWidget,
    );
  });
}
