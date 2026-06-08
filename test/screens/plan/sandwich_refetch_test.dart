import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/api/models/sandwiches_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/providers/plan_view_provider.dart';
import 'package:daysoff_mobile/providers/preferences_provider.dart';
import 'package:daysoff_mobile/screens/plan/plan_screen.dart';

/// getSandwiches returns a different record depending on the weekend, and
/// records every weekend it was called with.
class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(dio: null);

  final List<List<String>> sandwichCalls = [];
  final List<int?> sandwichBudgets = [];

  @override
  Future<SandwichesResponse> getSandwiches({
    required String country,
    required int year,
    List<String>? workweek,
    int? budget,
    int? minLength,
    int? maxLength,
  }) async {
    final ww = workweek ?? const [];
    sandwichCalls.add(ww);
    sandwichBudgets.add(budget);
    final isMonWed = ww.contains('mon');
    return SandwichesResponse(
      country: country,
      year: year,
      workweek: ww,
      workweekSource: 'test',
      count: 1,
      sandwiches: [
        SandwichRecord(
          ptoDate: DateTime(2026, 5, 4),
          ptoDates: [DateTime(2026, 5, 4)],
          weekday: 'Monday',
          breakStart: DateTime(2026, 5, 2),
          breakEnd: DateTime(2026, 5, 5),
          breakLength: 4,
          ptoCost: 1,
          context: isMonWed ? 'MON_WED_CASE' : 'SAT_SUN_CASE',
        ),
      ],
    );
  }

  @override
  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
    int? month,
    List<String>? workweek,
  }) async =>
      PlanResponse(
        country: country,
        year: year,
        budget: budget,
        workweek: workweek ?? const [],
        workweekSource: 'test',
        resultsByLength: const {},
      );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sandwich list refetches when the weekend (days off) changes',
      (tester) async {
    final api = _FakeApiClient();
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWith((ref) => api),
      // Start on the Sandwich view.
      planViewProvider.overrideWith((ref) => PlanView.sandwich),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: PlanScreen()),
    ));
    await _settle(tester);

    // Default weekend (sat,sun) → first dataset.
    expect(find.textContaining('SAT_SUN_CASE'), findsWidgets);
    expect(find.textContaining('MON_WED_CASE'), findsNothing);

    // Change the days off → the sandwich list must refetch and update.
    container.read(weekendProvider.notifier).state = ['mon', 'wed'];
    await _settle(tester);

    expect(find.textContaining('MON_WED_CASE'), findsWidgets);
    expect(find.textContaining('SAT_SUN_CASE'), findsNothing);
    // Both weekends were actually requested from the backend.
    expect(api.sandwichCalls.any((w) => w.contains('sun')), isTrue);
    expect(api.sandwichCalls.any((w) => w.contains('mon')), isTrue);
  });

  testWidgets('sandwich list refetches when the PTO budget changes',
      (tester) async {
    final api = _FakeApiClient();
    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWith((ref) => api),
      planViewProvider.overrideWith((ref) => PlanView.sandwich),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: PlanScreen()),
    ));
    await _settle(tester);
    expect(api.sandwichBudgets.last, 15); // default budget

    // Lowering the budget must re-query /v1/sandwiches with the new budget.
    container.read(ptoBudgetProvider.notifier).state = 2;
    await _settle(tester);
    expect(api.sandwichBudgets.last, 2);
  });
}
