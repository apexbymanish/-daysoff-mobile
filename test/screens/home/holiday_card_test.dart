import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/providers/preferences_provider.dart';
import 'package:daysoff_mobile/screens/home/widgets/holiday_card.dart';

Holiday _h() => Holiday(
      date: DateTime(2026, 1, 2), // Friday
      name: 'Some Holiday',
      nameLocal: '설날',
      source: 'library',
    );

Future<void> _pump(WidgetTester tester, {List<String>? weekend}) {
  final days = weekend ?? const ['sat', 'sun'];
  final container = ProviderContainer(
    overrides: [weekendProvider.overrideWith((ref) => days)],
  );
  addTearDown(container.dispose);
  return tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(home: Scaffold(body: HolidayCard(holiday: _h()))),
  ));
}

void main() {
  testWidgets('shows the native name', (tester) async {
    await _pump(tester);
    expect(find.text('설날'), findsOneWidget);
  });

  testWidgets('Friday holiday is free by default, absorbed when Fri is a day off',
      (tester) async {
    await _pump(tester);
    expect(find.text('Free'), findsOneWidget);

    await _pump(tester, weekend: const ['fri']);
    expect(find.text('Absorbed'), findsOneWidget);
  });
}
