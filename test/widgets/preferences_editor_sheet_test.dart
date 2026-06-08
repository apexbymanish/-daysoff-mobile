import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/preferences_provider.dart';
import 'package:daysoff_mobile/widgets/preferences_editor_sheet.dart';

void main() {
  Future<ProviderContainer> pump(WidgetTester tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: Scaffold(body: PreferencesEditorSheet())),
    ));
    return c;
  }

  testWidgets('renders the three controls', (tester) async {
    await pump(tester);
    expect(find.text('PTO budget'), findsOneWidget);
    expect(find.textContaining('Break length'), findsOneWidget);
    expect(find.text('Weekend (days off)'), findsOneWidget);
    expect(find.byType(RangeSlider), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(7));
  });

  testWidgets('plus raises the budget', (tester) async {
    final c = await pump(tester);
    expect(c.read(ptoBudgetProvider), 15);
    await tester.tap(find.byKey(const Key('budget_inc')));
    await tester.pump();
    expect(c.read(ptoBudgetProvider), 16);
  });

  testWidgets('tapping an unselected day adds it to the weekend', (tester) async {
    final c = await pump(tester);
    expect(c.read(weekendProvider), const ['sat', 'sun']);
    await tester.tap(find.text('Fri'));
    await tester.pump();
    expect(c.read(weekendProvider).contains('fri'), true);
  });

  testWidgets('cannot deselect the last remaining day off', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.text('Sat'));
    await tester.pump();
    await tester.tap(find.text('Sun'));
    await tester.pump();
    expect(c.read(weekendProvider).isNotEmpty, true);
  });
}
