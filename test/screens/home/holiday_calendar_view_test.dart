import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';
import 'package:daysoff_mobile/screens/home/widgets/holiday_calendar_view.dart';

void main() {
  testWidgets('renders the calendar with a holiday marker for the focused month',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: HolidayCalendarView(
            holidays: [
              Holiday(date: DateTime(2026, 1, 1), name: "New Year's Day", source: 'library'),
            ],
            year: 2026,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);
    expect(find.byKey(const Key('holiday-marker')), findsWidgets);
  });

  testWidgets('news holiday renders the news marker', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: HolidayCalendarView(
            holidays: [
              Holiday(date: DateTime(2026, 1, 1), name: '임시공휴일', source: 'news'),
            ],
            year: 2026,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('news-marker')), findsWidgets);
  });

  testWidgets('tapping a holiday day opens the detail sheet', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: HolidayCalendarView(
            holidays: [
              Holiday(date: DateTime(2026, 1, 1), name: "New Year's Day", source: 'library'),
            ],
            year: 2026,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    // January 2026 is focused; Jan 1 is the only cell showing '1'.
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    expect(find.text("New Year's Day"), findsOneWidget);
  });

  testWidgets('tapping a day inside a saved break shows the break in the sheet',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        savedBreaksProvider.overrideWith(() => _FakeSavedBreaks()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: HolidayCalendarView(holidays: const [], year: 2026),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    // Saved break covers Jan 5–7; tap Jan 6.
    await tester.tap(find.text('6').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Winter trip'), findsOneWidget);
  });
}

class _FakeSavedBreaks extends SavedBreaksNotifier {
  @override
  List<SavedBreak> build() => [
        SavedBreak(
          id: '1', label: 'Winter trip',
          start: DateTime(2026, 1, 5), end: DateTime(2026, 1, 7),
          ptoCost: 1, kind: 'break',
        ),
      ];
}
