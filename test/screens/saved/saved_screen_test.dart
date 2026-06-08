import 'package:flutter/material.dart';
import 'package:daysoff_mobile/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';
import 'package:daysoff_mobile/screens/saved/saved_screen.dart';

void main() {
  testWidgets('empty state when nothing saved', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: SavedScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing saved'), findsOneWidget);
  });

  testWidgets('lists a saved break and removes it', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(savedBreaksProvider.notifier).add(SavedBreak(
          id: 'break-1', label: '5-day break',
          start: DateTime(2026, 9, 23), end: DateTime(2026, 9, 27),
          ptoCost: 1, kind: 'break'));

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(localizationsDelegates: AppL10n.localizationsDelegates, supportedLocales: AppL10n.supportedLocales, home: SavedScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('5-day break'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('5-day break'), findsNothing);
  });
}
