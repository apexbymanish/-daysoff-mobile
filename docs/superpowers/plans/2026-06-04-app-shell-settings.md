# daysoff-mobile — App Shell (bottom nav) + Settings + Dark Mode Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make every built surface reachable via a bottom-navigation shell (Holidays / Plan / Sandwich / Settings) and turn the Settings stub into a real screen with a **functional dark-mode toggle** (Riverpod-backed `themeMode`).

**Architecture:** A `themeModeProvider` (Riverpod `StateProvider<ThemeMode>`) drives `MaterialApp.router`'s `themeMode` (app.dart becomes a `ConsumerWidget`). The router is refactored to a go_router `StatefulShellRoute.indexedStack` with four branches behind a `ScaffoldWithNavBar` (Material 3 `NavigationBar`); the full-screen break-detail route becomes a child of the Plan branch pushed onto the root navigator. Settings is a `ConsumerWidget` reading/setting `themeModeProvider`.

**Tech Stack:** Flutter, flutter_riverpod, go_router 14.6.2. No new deps.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`), branch **`feat/app-shell-settings`** (commit there, never switch mid-task). Baseline green: Holidays + Plan + Sandwich on main, `flutter test` 19 pass, analyzer clean.

## Note on tabs
In this repo Sandwich is its own screen/route, so the shell has **4 tabs** (Holidays / Plan / Sandwich / Settings). (The earlier "3-tab, Sandwich-as-Plan-section" idea was for the discarded GetX design; the real repo models Sandwich as a peer screen, so 4 tabs is correct here.)

## Out of scope
Editing country/workweek/budget (Settings shows them as static rows for now), onboarding flow, persisting theme across launches (in-memory `StateProvider` this phase).

---

## File Structure

```
lib/providers/theme_mode_provider.dart        NEW
lib/app.dart                                   MODIFY → ConsumerWidget reading themeModeProvider
lib/router/scaffold_with_nav_bar.dart          NEW (NavigationBar shell)
lib/router/app_router.dart                     MODIFY → StatefulShellRoute
lib/screens/settings/settings_screen.dart      REPLACE stub → real settings + theme toggle
test/providers/theme_mode_provider_test.dart   NEW
test/screens/settings/settings_screen_test.dart NEW
test/router/app_shell_test.dart                NEW
test/widget_test.dart                          MODIFY (still boots to Home; nav bar now present)
```

---

## Task 1: themeModeProvider + wire app.dart

**Files:**
- Create: `lib/providers/theme_mode_provider.dart`
- Modify: `lib/app.dart`
- Test: `test/providers/theme_mode_provider_test.dart`

- [ ] **Step 1: Write the failing test**

`test/providers/theme_mode_provider_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/theme_mode_provider.dart';

void main() {
  test('defaults to light and can be updated', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);

    container.read(themeModeProvider.notifier).state = ThemeMode.dark;
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/theme_mode_provider_test.dart`
Expected: FAIL — undefined `themeModeProvider`.

- [ ] **Step 3: Implement provider + wire app.dart**

`lib/providers/theme_mode_provider.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide theme mode (in-memory this phase; persistence is a later task).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
```

Replace `lib/app.dart` (convert to a `ConsumerWidget` that reads the provider):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_mode_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class DaysoffApp extends ConsumerWidget {
  const DaysoffApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'daysoff',
      debugShowCheckedModeBanner: false,
      theme: DaysoffTheme.light(),
      darkTheme: DaysoffTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/providers/theme_mode_provider_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**
```bash
git add lib/providers/theme_mode_provider.dart lib/app.dart test/providers/theme_mode_provider_test.dart
git commit -m "feat(theme): add themeModeProvider and drive MaterialApp themeMode"
```

---

## Task 2: Real SettingsScreen (prefs rows + theme toggle)

**Files:**
- Replace: `lib/screens/settings/settings_screen.dart`
- Test: `test/screens/settings/settings_screen_test.dart`

- [ ] **Step 1: Write the failing test**

`test/screens/settings/settings_screen_test.dart`:
```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/screens/settings/settings_screen_test.dart`
Expected: FAIL — current stub has no such rows / no theme control.

- [ ] **Step 3: Implement the screen**

Replace `lib/screens/settings/settings_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_mode_provider.dart';
import '../../theme/colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            const _SectionHeader('PREFERENCES'),
            const _ValueRow(label: 'Country of work', value: '🇰🇷 South Korea'),
            const _ValueRow(label: 'Workweek', value: 'Sat, Sun'),
            const _ValueRow(label: 'PTO budget', value: '15 days'),
            const _SectionHeader('APPEARANCE'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Theme', style: TextStyle(fontSize: 16)),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('System')),
                      ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) =>
                        ref.read(themeModeProvider.notifier).state = s.first,
                  ),
                ],
              ),
            ),
            const _SectionHeader('ABOUT'),
            const _ValueRow(label: 'Version', value: '0.1.0'),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: DaysoffColors.neutral500)),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value,
          style: const TextStyle(color: DaysoffColors.neutral700)),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/screens/settings/settings_screen_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**
```bash
git add lib/screens/settings/settings_screen.dart test/screens/settings/settings_screen_test.dart
git commit -m "feat(settings): real Settings screen with functional theme toggle"
```

---

## Task 3: Bottom-navigation shell (StatefulShellRoute)

**Files:**
- Create: `lib/router/scaffold_with_nav_bar.dart`
- Modify: `lib/router/app_router.dart`
- Modify: `test/widget_test.dart`
- Test: `test/router/app_shell_test.dart`

- [ ] **Step 1: Write the failing test**

`test/router/app_shell_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/app.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';
import 'package:daysoff_mobile/screens/settings/settings_screen.dart';

void main() {
  testWidgets('shell shows 4 nav destinations and can switch to Settings',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        holidaysProvider(const HolidaysQuery(country: 'KR', year: 2026))
            .overrideWith((ref) async => const HolidaysResponse(
                  country: 'KR', year: 2026, count: 0, holidays: [],
                )),
      ],
      child: const DaysoffApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Holidays'), findsWidgets);
    expect(find.text('Plan'), findsWidgets);
    expect(find.text('Sandwich'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
```

Also update `test/widget_test.dart` — it still boots to Home (empty state) but the shell now adds a NavigationBar; keep the existing assertions and add one for the nav bar:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/app.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';

void main() {
  testWidgets('App boots to Home (empty) inside the nav shell, no network',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          holidaysProvider(const HolidaysQuery(country: 'KR', year: 2026))
              .overrideWith(
            (ref) async => const HolidaysResponse(
              country: 'KR', year: 2026, count: 0, holidays: [],
            ),
          ),
        ],
        child: const DaysoffApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('No holidays for this year.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/router/app_shell_test.dart`
Expected: FAIL — no `NavigationBar` (router is still flat).

- [ ] **Step 3: Implement the shell + refactor the router**

`lib/router/scaffold_with_nav_bar.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-navigation shell hosting the four primary branches.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Holidays'),
          NavigationDestination(
              icon: Icon(Icons.event_available_outlined),
              selectedIcon: Icon(Icons.event_available),
              label: 'Plan'),
          NavigationDestination(
              icon: Icon(Icons.bakery_dining_outlined),
              selectedIcon: Icon(Icons.bakery_dining),
              label: 'Sandwich'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}
```

Replace `lib/router/app_router.dart`:
```dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../api/models/plan_trip.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/plan/break_detail_screen.dart';
import '../screens/plan/plan_screen.dart';
import '../screens/sandwich/sandwich_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'scaffold_with_nav_bar.dart';

class AppRoutes {
  AppRoutes._();
  static const home = '/';
  static const onboarding = '/onboarding';
  static const plan = '/plan';
  static const breakDetail = '/plan/break';
  static const sandwich = '/sandwich';
  static const settings = '/settings';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.plan,
            builder: (context, state) => const PlanScreen(),
            routes: [
              GoRoute(
                path: 'break', // full path: /plan/break
                parentNavigatorKey: _rootNavigatorKey, // full-screen over the nav bar
                builder: (context, state) =>
                    BreakDetailScreen(trip: state.extra! as PlanTrip),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.sandwich,
            builder: (context, state) => const SandwichScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ]),
      ],
    ),
    // Onboarding stays outside the shell (full-screen entry surface).
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
  ],
);
```

Notes:
- `AppRoutes.breakDetail` stays `'/plan/break'`; `PlanScreen` already does `context.push(AppRoutes.breakDetail, extra: t)` — unchanged and still works (the nested `break` route resolves to `/plan/break` and pushes onto the root navigator, covering the nav bar).
- `HomeScreen`/`PlanScreen`/`SandwichScreen`/`SettingsScreen` keep their own `Scaffold`/`AppBar`; they nest inside the shell body — that is fine.

- [ ] **Step 4: Run tests to verify they pass + full gate**

Run: `flutter test test/router/app_shell_test.dart test/widget_test.dart`
Expected: PASS. Then the whole suite + analyzer:
Run: `flutter test && flutter analyze`
Expected: all tests pass; analyzer clean.

- [ ] **Step 5: Commit**
```bash
git add lib/router/scaffold_with_nav_bar.dart lib/router/app_router.dart test/router/app_shell_test.dart test/widget_test.dart
git commit -m "feat(nav): add bottom-navigation shell (Holidays/Plan/Sandwich/Settings)"
```

---

## Self-review
- **Coverage:** themeModeProvider + app.dart wiring ✓ (T1); real Settings with functional theme toggle ✓ (T2); StatefulShellRoute bottom-nav shell making all surfaces reachable ✓ (T3). breakDetail preserved as a root-navigator child of the Plan branch (full-screen). Onboarding kept outside the shell.
- **Placeholder scan:** none — full code throughout. Settings pref rows (country/workweek/budget) are intentionally static this phase (out-of-scope to edit), clearly value-only rows.
- **Type consistency:** `themeModeProvider` (StateProvider<ThemeMode>), `DaysoffApp` (ConsumerWidget), `ScaffoldWithNavBar({navigationShell})`, `AppRoutes.*` unchanged paths — `PlanScreen.context.push(AppRoutes.breakDetail)` still valid. 4 NavigationDestinations match 4 branches in order.
- **Idiom:** Riverpod providers + ConsumerWidget; go_router StatefulShellRoute (the standard nav-shell pattern); tests via ProviderScope/UncontrolledProviderScope overrides (no mocktail); `DaysoffColors` for tokens.

## Done when
`flutter test && flutter analyze` clean; running the app shows a 4-tab bottom bar (Holidays/Plan/Sandwich/Settings), each tab loads its screen on live data, tapping a Plan break card opens full-screen break detail over the bar, and Settings' Light/Dark/System toggle visibly re-themes the app.
