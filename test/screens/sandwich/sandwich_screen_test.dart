import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/sandwich_record.dart';
import 'package:daysoff_mobile/api/models/sandwiches_response.dart';
import 'package:daysoff_mobile/providers/sandwiches_provider.dart';
import 'package:daysoff_mobile/screens/sandwich/sandwich_screen.dart';
import 'package:daysoff_mobile/screens/sandwich/widgets/sandwich_card.dart';

SandwichesResponse _resp(List<SandwichRecord> s) => SandwichesResponse(
      country: 'KR',
      year: 2026,
      workweek: const ['sat', 'sun'],
      workweekSource: 'default',
      count: s.length,
      sandwiches: s,
    );

SandwichRecord _rec() => SandwichRecord(
      ptoDate: DateTime(2026, 5, 4),
      weekday: 'Monday',
      breakStart: DateTime(2026, 5, 2),
      breakEnd: DateTime(2026, 5, 5),
      breakLength: 4,
      ptoCost: 1,
      context: "Weekend + Children's Day",
    );

void main() {
  // workweek matches the weekendProvider default ['sat','sun'] now passed by the screen
  const q = SandwichesQuery(country: 'KR', year: 2026, workweek: ['sat', 'sun']);

  testWidgets('data state renders a SandwichCard', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [sandwichesProvider(q).overrideWith((ref) async => _resp([_rec()]))],
      child: const MaterialApp(home: SandwichScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(SandwichCard), findsOneWidget);
  });

  testWidgets('empty state shows a message', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [sandwichesProvider(q).overrideWith((ref) async => _resp([]))],
      child: const MaterialApp(home: SandwichScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('No sandwich days'), findsOneWidget);
  });

  testWidgets('error state shows Retry', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [sandwichesProvider(q).overrideWith((ref) async => throw Exception('x'))],
      child: const MaterialApp(home: SandwichScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
  });
}
