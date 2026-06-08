import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';
import 'package:daysoff_mobile/screens/home/widgets/holiday_card.dart';

// A future holiday that will be in the windowed list.
final _holiday = Holiday(
  date: DateTime(2026, 9, 9), // Future date — Sep 9 2026
  name: 'Test Holiday',
  source: 'library',
);

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
        holidays: [_holiday],
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
      throw Exception('no plan in test — cap = year-end');
}

void main() {
  testWidgets(
      'tapping a HolidayCard flips to calendar with the holiday selected',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Should be in list view showing the holiday card.
    expect(find.byType(HolidayCard), findsOneWidget);
    expect(find.byKey(const Key('holiday-calendar')), findsNothing);

    // Tap the holiday card.
    await tester.tap(find.byType(HolidayCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Now in calendar view.
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);

    // The DaySummaryCard should show the holiday name.
    expect(find.text('Test Holiday'), findsWidgets);
    // And the "Public Holiday" label in the date string.
    expect(find.textContaining('Public Holiday'), findsOneWidget);
  });

  testWidgets('toggle-list button returns to list view', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Tap the card to flip to calendar.
    await tester.tap(find.byType(HolidayCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);

    // Tap the toggle-list button to return.
    await tester.tap(find.byKey(const Key('toggle-list')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Back to list view.
    expect(find.byKey(const Key('holiday-calendar')), findsNothing);
    expect(find.byType(HolidayCard), findsOneWidget);
  });
}
