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
          // Month 2 (February) trip
          '3': [
            PlanTrip(
              breakStart: DateTime(2026, 2, 14),
              breakEnd: DateTime(2026, 2, 16),
              breakLength: 3,
              ptoDates: const [],
              ptoCost: 0,
              anchors: const ['Valentine'],
            ),
          ],
          // Month 9 (September) trip
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
        count: 2,
        sandwiches: [
          // Month 5 (May) sandwich
          SandwichRecord(
            ptoDate: DateTime(2026, 5, 4),
            weekday: 'Monday',
            breakStart: DateTime(2026, 5, 2),
            breakEnd: DateTime(2026, 5, 5),
            breakLength: 4,
            ptoCost: 1,
            context: "Children's Day",
          ),
          // Month 10 (October) sandwich
          SandwichRecord(
            ptoDate: DateTime(2026, 10, 2),
            weekday: 'Friday',
            breakStart: DateTime(2026, 10, 1),
            breakEnd: DateTime(2026, 10, 4),
            breakLength: 4,
            ptoCost: 1,
            context: 'National Foundation Day',
          ),
        ],
      );
}

Widget _buildApp() => ProviderScope(
      overrides: [
        apiClientProvider.overrideWith((ref) => _FakeApiClient()),
      ],
      child: const MaterialApp(home: PlanScreen()),
    );

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Buffet month filter', () {
    testWidgets('All (default) shows both months\' break cards', (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);

      // Both trips are rendered (PageView builds them all)
      expect(find.byType(BreakCard), findsWidgets);
      expect(find.textContaining('Valentine'), findsOneWidget);
      expect(find.textContaining('Chuseok'), findsOneWidget);
    });

    testWidgets('selecting Feb shows only Feb trip', (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);

      // Tap month-2 chip (February)
      await tester.tap(find.byKey(const Key('month-2')));
      await _settle(tester);

      expect(find.textContaining('Valentine'), findsOneWidget);
      expect(find.textContaining('Chuseok'), findsNothing);
    });

    testWidgets('selecting Sep shows only Sep trip', (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);

      await tester.tap(find.byKey(const Key('month-9')));
      await _settle(tester);

      expect(find.textContaining('Chuseok'), findsOneWidget);
      expect(find.textContaining('Valentine'), findsNothing);
    });

    testWidgets('selecting a month with no trips shows empty message',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);

      // Month 1 (January) has no trips
      await tester.tap(find.byKey(const Key('month-1')));
      await _settle(tester);

      expect(find.textContaining('No break options in January'), findsOneWidget);
      expect(find.byType(BreakCard), findsNothing);
    });

    testWidgets('switching FROM an empty month to another does not crash',
        (tester) async {
      // Regression: in an empty month no PageView is built, so the
      // PageController is detached; the next month change must not assert
      // 'PageController is not attached to a PageView'.
      await tester.pumpWidget(_buildApp());
      await _settle(tester);

      await tester.tap(find.byKey(const Key('month-1'))); // empty (Jan)
      await _settle(tester);
      expect(find.textContaining('No break options'), findsOneWidget);

      await tester.tap(find.byKey(const Key('month-2'))); // populated (Feb)
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Valentine'), findsOneWidget);

      // And back to All from a populated state, then to empty again.
      await tester.tap(find.byKey(const Key('month-1'))); // empty
      await _settle(tester);
      await tester.tap(find.byKey(const Key('month-all'))); // populated
      await _settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Chuseok'), findsOneWidget);
    });

    testWidgets('tapping All after filtering shows all trips again',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);

      // Filter to Feb
      await tester.tap(find.byKey(const Key('month-2')));
      await _settle(tester);
      expect(find.textContaining('Chuseok'), findsNothing);

      // Reset to All
      await tester.tap(find.byKey(const Key('month-all')));
      await _settle(tester);
      expect(find.textContaining('Chuseok'), findsOneWidget);
    });
  });

  group('Sandwich month filter', () {
    Future<void> switchToSandwich(WidgetTester tester) async {
      await tester.tap(find.text('Sandwich days'));
      await _settle(tester);
    }

    testWidgets('All shows both sandwich cards', (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);
      await switchToSandwich(tester);

      expect(find.byType(SandwichCard), findsNWidgets(2));
    });

    testWidgets('selecting May shows only May sandwich', (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);
      await switchToSandwich(tester);

      await tester.tap(find.byKey(const Key('month-5')));
      await _settle(tester);

      expect(find.byType(SandwichCard), findsOneWidget);
      // The May sandwich has ptoDate 2026-05-04
      expect(find.textContaining("Children's Day"), findsOneWidget);
    });

    testWidgets('selecting Oct shows only Oct sandwich', (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);
      await switchToSandwich(tester);

      await tester.tap(find.byKey(const Key('month-10')));
      await _settle(tester);

      expect(find.byType(SandwichCard), findsOneWidget);
      expect(find.textContaining('National Foundation Day'), findsOneWidget);
    });

    testWidgets('selecting a month with no sandwiches shows empty message',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);
      await switchToSandwich(tester);

      // Month 3 (March) has no sandwiches
      await tester.tap(find.byKey(const Key('month-3')));
      await _settle(tester);

      expect(
          find.textContaining('No sandwich days in March'), findsOneWidget);
      expect(find.byType(SandwichCard), findsNothing);
    });

    testWidgets('tapping All after sandwich filter shows all sandwiches',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await _settle(tester);
      await switchToSandwich(tester);

      // Filter to May only
      await tester.tap(find.byKey(const Key('month-5')));
      await _settle(tester);
      expect(find.byType(SandwichCard), findsOneWidget);

      // Reset to All
      await tester.tap(find.byKey(const Key('month-all')));
      await _settle(tester);
      expect(find.byType(SandwichCard), findsNWidgets(2));
    });
  });
}
