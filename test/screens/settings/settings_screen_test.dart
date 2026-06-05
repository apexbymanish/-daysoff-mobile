import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/screens/settings/settings_screen.dart';
import 'package:daysoff_mobile/widgets/preferences_editor_sheet.dart';

void main() {
  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SettingsScreen()),
        ),
      );

  testWidgets('shows current pref values and the Weekend label', (tester) async {
    await pump(tester);
    expect(find.text('Weekend'), findsOneWidget);
    expect(find.text('Workweek'), findsNothing);
    expect(find.text('Sat, Sun'), findsOneWidget);
    expect(find.text('15 days'), findsOneWidget);
    expect(find.text('3–10 days'), findsOneWidget);
  });

  testWidgets('tapping the PTO budget row opens the editor', (tester) async {
    await pump(tester);
    await tester.tap(find.text('PTO budget'));
    await tester.pumpAndSettle();
    expect(find.byType(PreferencesEditorSheet), findsOneWidget);
  });
}
