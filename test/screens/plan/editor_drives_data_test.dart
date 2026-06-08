import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/api/models/sandwiches_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/plan/plan_screen.dart';

/// Records the budget / weekend each call was made with.
class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(dio: null);

  final List<int> planBudgets = [];
  final List<List<String>> planWeekends = [];

  @override
  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
    int? month,
    List<String>? workweek,
  }) async {
    planBudgets.add(budget);
    planWeekends.add(workweek ?? const []);
    return PlanResponse(
      country: country,
      year: year,
      budget: budget,
      workweek: workweek ?? const [],
      workweekSource: 'test',
      resultsByLength: const {},
    );
  }

  @override
  Future<SandwichesResponse> getSandwiches({
    required String country,
    required int year,
    List<String>? workweek,
    int? budget,
    int? minLength,
    int? maxLength,
  }) async =>
      SandwichesResponse(
        country: country,
        year: year,
        workweek: workweek ?? const [],
        workweekSource: 'test',
        count: 0,
        sandwiches: const [],
      );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'changing PTO budget in the modal editor refetches the plan (real path)',
      (tester) async {
    final api = _FakeApiClient();
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWith((ref) => api)],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await _settle(tester);

    expect(api.planBudgets.isNotEmpty, isTrue);
    final initialBudget = api.planBudgets.last; // default 15

    // Open the editor via the AppBar pencil, then bump the budget.
    await tester.tap(find.byTooltip('Adjust preferences'));
    await _settle(tester);
    await tester.tap(find.byKey(const Key('budget_inc')));
    await _settle(tester);

    // The plan must have been refetched with the incremented budget.
    expect(api.planBudgets.last, initialBudget + 1,
        reason: 'editing the budget should re-query /v1/plan');
  });
}
