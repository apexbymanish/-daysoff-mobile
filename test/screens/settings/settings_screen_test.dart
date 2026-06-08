import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/auth/auth_controller.dart';
import 'package:daysoff_mobile/auth/token_store.dart';
import 'package:daysoff_mobile/providers/theme_mode_provider.dart';
import 'package:daysoff_mobile/screens/settings/settings_screen.dart';
import 'package:daysoff_mobile/widgets/preferences_editor_sheet.dart';

void main() {
  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        ProviderScope(
          // Empty in-memory store → the account section resolves to logged-out.
          overrides: [
            tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

  // ── PREFERENCES section ──────────────────────────────────────────────────

  testWidgets('shows the Weekend label (not Workweek) and formatWeekend default value',
      (tester) async {
    await pump(tester);
    expect(find.text('Weekend'), findsOneWidget);
    expect(find.text('Workweek'), findsNothing);
    expect(find.text('Sat, Sun'), findsOneWidget);
  });

  testWidgets('shows 15 days for PTO budget and 3–10 days for break length',
      (tester) async {
    await pump(tester);
    expect(find.text('15 days'), findsOneWidget);
    expect(find.text('3–10 days'), findsOneWidget);
  });

  testWidgets('tapping the PTO budget row opens the editor', (tester) async {
    await pump(tester);
    await tester.tap(find.text('PTO budget'));
    await tester.pumpAndSettle();
    expect(find.byType(PreferencesEditorSheet), findsOneWidget);
  });

  // ── APPEARANCE section — theme toggle (MUST be preserved) ────────────────

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

  // ── CALENDAR & REMINDERS placeholders (disabled, no navigation) ──────────

  testWidgets('disabled Apple Calendar row renders but does not navigate',
      (tester) async {
    await pump(tester);
    // Scroll down until the item is visible.
    await tester.scrollUntilVisible(
      find.text('Apple Calendar'),
      150,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Apple Calendar'), findsOneWidget);
    // Tapping does nothing — no exception, no new screen.
    await tester.tap(find.text('Apple Calendar'), warnIfMissed: false);
    await tester.pumpAndSettle();
    // Still on SettingsScreen.
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  // ── ACCOUNT section ──────────────────────────────────────────────────────

  testWidgets('logged out shows the Sign in / Create account row',
      (tester) async {
    await pump(tester);
    await tester.pumpAndSettle(); // let the auth state hydrate
    await tester.scrollUntilVisible(
      find.text('Sign in / Create account'),
      150,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Sign in / Create account'), findsOneWidget);
    // Old placeholders are gone.
    expect(find.text('Sign out'), findsNothing);
  });
}
