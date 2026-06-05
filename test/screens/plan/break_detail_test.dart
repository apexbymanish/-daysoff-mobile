import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';
import 'package:daysoff_mobile/screens/plan/break_detail_screen.dart';

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
          // 2026-09-24 is a Thursday inside the break, not a PTO day → holiday kind.
          Holiday(
            date: DateTime(2026, 9, 24),
            name: 'Chuseok',
            nameLocal: '추석',
            source: 'library',
          ),
        ],
      );
}

class _LongNameApiClient extends ApiClient {
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
          Holiday(
            date: DateTime(2026, 9, 24),
            name: 'Alternative holiday for Independence Movement Day',
            nameLocal: '삼일절 대체 공휴일',
            source: 'library',
          ),
        ],
      );
}

PlanTrip _trip() => PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );

ProviderScope _wrap(Widget child) => ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('shows hero overlay with break title and PTO pill', (tester) async {
    await tester.pumpWidget(_wrap(BreakDetailScreen(trip: _trip())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('5-day break'), findsOneWidget);
    expect(find.textContaining('1 PTO'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows 5 day-by-day rows with correct overlines and tags',
      (tester) async {
    await tester.pumpWidget(_wrap(BreakDetailScreen(trip: _trip())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // One row per day in the break (Sep 23-27 = 5 rows).
    expect(find.byKey(const ValueKey('break-day-row')), findsNWidgets(5));

    // Sep 24 is holiday-kind and matched to Chuseok.
    expect(find.textContaining('Holiday • Chuseok'), findsWidgets);

    // Sep 26 + 27 are weekend.
    expect(find.text('REST'), findsWidgets);

    // Sep 23 is PTO kind.
    expect(find.text('ORDINARY DAY'), findsWidgets);
  });

  testWidgets('a long holiday name does not overflow the tag', (tester) async {
    // A RenderFlex overflow throws in widget tests, so a clean render proves
    // the tag truncates (ellipsis) instead of overflowing.
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_LongNameApiClient())],
      child: MaterialApp(home: BreakDetailScreen(trip: _trip())),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Holiday • '), findsWidgets);
  });

  testWidgets('Save this break adds to savedBreaksProvider', (tester) async {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: BreakDetailScreen(trip: _trip())),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Save this break'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(container.read(savedBreaksProvider).length, 1);
  });
}
