import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
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
}
