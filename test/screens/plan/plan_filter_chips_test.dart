import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';
import 'package:daysoff_mobile/screens/plan/widgets/plan_filter_chips.dart';
import 'package:daysoff_mobile/widgets/preferences_editor_sheet.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  final c = ProviderContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: Scaffold(body: PlanFilterChips())),
  ));
  return c;
}

void main() {
  testWidgets('shows year + budget + weekend chips', (tester) async {
    await _pump(tester);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('15 days'), findsOneWidget);
    expect(find.text('Sat, Sun off'), findsOneWidget);
  });

  testWidgets('tapping budget opens the editor', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('15 days'));
    await tester.pumpAndSettle();
    expect(find.byType(PreferencesEditorSheet), findsOneWidget);
  });

  testWidgets('year chip stepper bumps the year', (tester) async {
    final c = await _pump(tester);
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('year_inc')));
    await tester.pumpAndSettle();
    expect(c.read(selectedYearProvider), 2027);
  });
}
