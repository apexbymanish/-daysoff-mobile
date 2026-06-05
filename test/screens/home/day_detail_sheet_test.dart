import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/screens/home/widgets/day_detail_sheet.dart';

void main() {
  testWidgets('shows holiday name, news tag, and saved break', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDayDetailSheet(
              context,
              DateTime(2026, 6, 5),
              [Holiday(date: DateTime(2026, 6, 5), name: '임시공휴일', source: 'news')],
              SavedBreak(
                id: 'x', label: 'Summer trip',
                start: DateTime(2026, 6, 4), end: DateTime(2026, 6, 6),
                ptoCost: 1, kind: 'break',
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.textContaining('임시공휴일'), findsOneWidget);
    expect(find.textContaining('news-detected'), findsOneWidget);
    expect(find.textContaining('Summer trip'), findsOneWidget);
  });

  testWidgets('empty day shows nothing-on-this-day', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDayDetailSheet(context, DateTime(2026, 3, 10), const [], null),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing on this day.'), findsOneWidget);
  });
}
