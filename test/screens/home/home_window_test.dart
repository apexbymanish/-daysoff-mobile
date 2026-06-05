import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';

// Three holidays:
//   A — past (Jan 1 2026)  → always filtered out by lower bound
//   B — near-future (Jul 4 2026) → within cap, must appear
//   C — late-future (Dec 25 2026) → beyond plan cap (Aug 31), filtered out
final _pastHoliday = Holiday(
  date: DateTime(2026, 1, 1),
  name: 'Past Holiday',
  source: 'library',
);
final _inWindowHoliday = Holiday(
  date: DateTime(2026, 7, 4),
  name: 'In Window Holiday',
  source: 'library',
);
final _postCapHoliday = Holiday(
  date: DateTime(2026, 12, 25),
  name: 'Post Cap Holiday',
  source: 'library',
);

// Longest break ends Aug 31 → cap = 2026-08-31
final _capDate = DateTime(2026, 8, 31);

class _FakeApiClientWithPlan extends ApiClient {
  @override
  Future<HolidaysResponse> getHolidays({
    required String country,
    required int year,
    bool fromToday = false,
  }) async =>
      HolidaysResponse(
        country: 'KR',
        year: 2026,
        count: 3,
        holidays: [_pastHoliday, _inWindowHoliday, _postCapHoliday],
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
        country: 'KR',
        year: 2026,
        budget: budget,
        workweek: ['mon', 'tue', 'wed', 'thu', 'fri'],
        workweekSource: 'default',
        resultsByLength: {
          '5': [
            PlanTrip(
              breakStart: DateTime(2026, 7, 1),
              breakEnd: _capDate,
              breakLength: 5,
              ptoDates: [DateTime(2026, 7, 2)],
              ptoCost: 1,
              anchors: [],
            ),
          ],
        },
      );
}

// Longest break overall is in the PAST (10-day ending Feb 22); the longest
// UPCOMING break is the 5-day ending Aug 31. The cap must use the upcoming
// one (Aug 31), not the past one (which would empty the window).
class _FakeApiClientPastLongest extends ApiClient {
  @override
  Future<HolidaysResponse> getHolidays({
    required String country,
    required int year,
    bool fromToday = false,
  }) async =>
      HolidaysResponse(
        country: 'KR',
        year: 2026,
        count: 2,
        holidays: [_inWindowHoliday, _postCapHoliday],
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
        country: 'KR',
        year: 2026,
        budget: budget,
        workweek: ['sat', 'sun'],
        workweekSource: 'user',
        resultsByLength: {
          '10': [
            PlanTrip(
              breakStart: DateTime(2026, 2, 13),
              breakEnd: DateTime(2026, 2, 22), // longest, but PAST
              breakLength: 10,
              ptoDates: const [],
              ptoCost: 0,
              anchors: const [],
            ),
          ],
          '5': [
            PlanTrip(
              breakStart: DateTime(2026, 7, 1),
              breakEnd: _capDate, // Aug 31 — longest UPCOMING
              breakLength: 5,
              ptoDates: [DateTime(2026, 7, 2)],
              ptoCost: 1,
              anchors: const [],
            ),
          ],
        },
      );
}

class _FakeApiClientPlanError extends ApiClient {
  @override
  Future<HolidaysResponse> getHolidays({
    required String country,
    required int year,
    bool fromToday = false,
  }) async =>
      HolidaysResponse(
        country: 'KR',
        year: 2026,
        count: 2,
        holidays: [_pastHoliday, _inWindowHoliday],
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
      throw Exception('plan error → cap = year-end');
}

void main() {
  testWidgets(
      'windowed list shows only in-window holidays; past + post-cap hidden',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_FakeApiClientWithPlan()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Past holiday must not appear in list.
    expect(find.text('Past Holiday'), findsNothing);
    // In-window holiday must appear (may appear in hero + card = multiple).
    expect(find.text('In Window Holiday'), findsWidgets);
    // Post-cap holiday must not appear.
    expect(find.text('Post Cap Holiday'), findsNothing);
  });

  testWidgets(
      'when plan errors, cap falls back to year-end and upcoming holidays show',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_FakeApiClientPlanError()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Past holiday still filtered by lower bound.
    expect(find.text('Past Holiday'), findsNothing);
    // Near-future holiday shows (cap = year-end, may appear in hero + card).
    expect(find.text('In Window Holiday'), findsWidgets);
  });

  testWidgets(
      'cap uses the longest UPCOMING break, not a longer past break',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_FakeApiClientPastLongest()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The Feb (past) 10-day break must NOT cap the window to Feb; the Jul 4
    // holiday (within the Aug 31 upcoming-break cap) must still show.
    expect(find.text('In Window Holiday'), findsWidgets);
    // Dec 25 is beyond the Aug 31 cap → hidden.
    expect(find.text('Post Cap Holiday'), findsNothing);
  });

  testWidgets('hero still shows upcoming.first (today-based, from all holidays)',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_FakeApiClientWithPlan()),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The NextBreakHero uses upcoming.first (in-window holiday is the first
    // upcoming), so "NEXT BREAK IN" header should appear.
    expect(find.text('NEXT BREAK IN'), findsOneWidget);
  });
}
