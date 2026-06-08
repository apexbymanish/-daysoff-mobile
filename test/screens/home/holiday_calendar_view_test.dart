import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/screens/home/widgets/holiday_calendar_view.dart';
import 'package:daysoff_mobile/screens/home/widgets/day_summary_card.dart';

void main() {
  // ─── 1. Calendar renders ───────────────────────────────────────────────────
  testWidgets('renders the calendar widget', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, 
        home: Scaffold(
          body: HolidayCalendarView(
            holidays: const [],
            year: 2026,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);
  });

  // ─── 2. Holiday day shows sun marker ──────────────────────────────────────
  testWidgets('a holiday day shows a sun marker', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, 
        home: Scaffold(
          body: HolidayCalendarView(
            holidays: [
              Holiday(
                date: DateTime(2026, 1, 1),
                name: "New Year's Day",
                source: 'library',
              ),
            ],
            year: 2026,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-marker')), findsWidgets);
  });

  // ─── 3. Tapping a holiday updates the inline card ─────────────────────────
  testWidgets(
      'tapping a holiday day updates the inline DaySummaryCard to show its name',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, 
        home: Scaffold(
          body: SingleChildScrollView(
            child: HolidayCalendarView(
              holidays: [
                Holiday(
                  date: DateTime(2026, 1, 1),
                  name: "New Year's Day",
                  source: 'library',
                ),
              ],
              year: 2026,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // January is focused; tap the "1" cell.
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    expect(find.text("New Year's Day"), findsWidgets);
    expect(find.textContaining('Public Holiday'), findsOneWidget);
  });

  // ─── 4. Legend renders ────────────────────────────────────────────────────
  testWidgets('legend shows free day, absorbed, and selected entries',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, 
        home: Scaffold(
          body: SingleChildScrollView(
            child: HolidayCalendarView(
              holidays: const [],
              year: 2026,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('FREE DAY'), findsOneWidget);
    expect(find.textContaining('ABSORBED'), findsOneWidget);
    expect(find.textContaining('SELECTED'), findsOneWidget);
  });

  // ─── 5. DaySummaryCard: holiday variant ───────────────────────────────────
  testWidgets('DaySummaryCard shows holiday name and Public Holiday label',
      (tester) async {
    final holiday = Holiday(
      date: DateTime(2026, 9, 24),
      name: 'Chuseok',
      nameLocal: '추석',
      source: 'library',
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, 
        home: Scaffold(
          body: DaySummaryCard(
            day: DateTime(2026, 9, 24),
            holiday: holiday,
            weekend: const ['sat', 'sun'],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Chuseok'), findsOneWidget);
    expect(find.textContaining('Public Holiday'), findsOneWidget);
  });

  // ─── 6. DaySummaryCard: no-holiday variant ────────────────────────────────
  testWidgets('DaySummaryCard shows nothing-on-this-day when no holiday',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, 
        home: Scaffold(
          body: DaySummaryCard(
            day: DateTime(2026, 3, 10),
            holiday: null,
            weekend: const ['sat', 'sun'],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing on this day'), findsOneWidget);
  });

  // ─── 7. DaySummaryCard: absorbed pill ─────────────────────────────────────
  testWidgets('DaySummaryCard shows Absorbed pill for a holiday on a weekend',
      (tester) async {
    // 2026-01-03 is a Saturday → absorbed with ['sat','sun'].
    final holiday = Holiday(
      date: DateTime(2026, 1, 3),
      name: 'Test Holiday',
      source: 'library',
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, 
        home: Scaffold(
          body: DaySummaryCard(
            day: DateTime(2026, 1, 3),
            holiday: holiday,
            weekend: const ['sat', 'sun'],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('ABSORBED'), findsOneWidget);
  });

  // ─── 8. DaySummaryCard: free day pill ─────────────────────────────────────
  testWidgets('DaySummaryCard shows Free Day pill for a holiday on a workday',
      (tester) async {
    // 2026-01-01 is a Thursday → free day with ['sat','sun'].
    final holiday = Holiday(
      date: DateTime(2026, 1, 1),
      name: "New Year's Day",
      source: 'library',
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, 
        home: Scaffold(
          body: DaySummaryCard(
            day: DateTime(2026, 1, 1),
            holiday: holiday,
            weekend: const ['sat', 'sun'],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('FREE DAY'), findsOneWidget);
  });
}
