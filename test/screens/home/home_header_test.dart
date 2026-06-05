import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';
// ignore: unused_import
import 'package:daysoff_mobile/screens/home/widgets/holiday_calendar_view.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<HolidaysResponse> getHolidays({required String country, required int year, bool fromToday = false}) async =>
      HolidaysResponse(country: 'KR', year: 2026, count: 1,
        holidays: [Holiday(date: DateTime(2026, 1, 1), name: "New Year's Day", source: 'library')]);
}

void main() {
  testWidgets('header shows the daysoff wordmark and calendar toggle flips views', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('daysoff'), findsOneWidget);
    expect(find.byKey(const Key('holiday-calendar')), findsNothing);
    await tester.tap(find.byKey(const Key('toggle-calendar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);
  });
}
