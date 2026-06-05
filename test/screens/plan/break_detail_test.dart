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

void main() {
  testWidgets('shows day-by-day rows and PTO summary', (tester) async {
    final trip = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: MaterialApp(home: BreakDetailScreen(trip: trip)),
    ));
    await tester.pump(); // let holidaysProvider resolve
    expect(find.text('5-day break'), findsOneWidget);
    expect(find.textContaining('1 PTO'), findsOneWidget);
    // One row per day in the break (23,24,25,26,27 = 5 rows).
    expect(find.byKey(const ValueKey('break-day-row')), findsNWidgets(5));
  });

  testWidgets('Save this break adds to savedBreaksProvider', (tester) async {
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
    );
    addTearDown(container.dispose);
    final trip = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: BreakDetailScreen(trip: trip)),
    ));
    await tester.tap(find.text('Save this break'));
    await tester.pump();
    expect(container.read(savedBreaksProvider).length, 1);
  });

  testWidgets('holiday day shows the native name + type tags + scenery hero',
      (tester) async {
    final trip = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: [DateTime(2026, 9, 23)],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: MaterialApp(home: BreakDetailScreen(trip: trip)),
    ));
    await tester.pump(); // resolve holidaysProvider
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.text('추석'), findsOneWidget);
    expect(find.text('PTO'), findsWidgets);      // the Sep 23 PTO day
    expect(find.text('Weekend'), findsWidgets);  // Sat/Sun in the break
  });
}
