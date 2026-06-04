import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/theme_mode_provider.dart';
import 'package:daysoff_mobile/screens/settings/settings_screen.dart';

void main() {
  testWidgets('shows preference rows and section headers', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: SettingsScreen()),
    ));
    expect(find.text('Country of work'), findsOneWidget);
    expect(find.text('Workweek'), findsOneWidget);
    expect(find.text('PTO budget'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
  });

  testWidgets('selecting Dark updates themeModeProvider', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: SettingsScreen()),
    ));

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
