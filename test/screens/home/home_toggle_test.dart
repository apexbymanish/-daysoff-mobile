import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';

// Holiday is future-dated (Christmas Day 2026) so it remains in the windowed
// list (today..cap). Date changed from DateTime(2026, 1, 1) — which is past —
// to DateTime(2026, 12, 25) so the window filter introduced in T2 still shows it.
class _FakeApiClient extends ApiClient {
  @override
  Future<HolidaysResponse> getHolidays({
    required String country,
    required int year,
    bool fromToday = false,
  }) async =>
      HolidaysResponse(
        country: 'KR',
        year: 2026,
        count: 1,
        holidays: [
          // Was DateTime(2026,1,1) — past date. Updated to future so the
          // windowed list still contains it.
          Holiday(
              date: DateTime(2026, 12, 25),
              name: 'Christmas Day',
              source: 'library'),
        ],
      );

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
      throw Exception('no plan in test');
}

void main() {
  testWidgets('toggle switches between list and calendar', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Holiday shows in hero + card (both are expected in list view).
    expect(find.text('Christmas Day'), findsWidgets);
    expect(find.byKey(const Key('holiday-calendar')), findsNothing);

    await tester.tap(find.byKey(const Key('toggle-calendar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggle-list')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('holiday-calendar')), findsNothing);
    // Holiday visible again in list view (hero + card).
    expect(find.text('Christmas Day'), findsWidgets);
  });
}
