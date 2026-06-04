# daysoff-mobile — Onboarding (Welcome) Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Replace the onboarding stub with a real value-first Welcome screen (logotype + value prop + calm hero) that is the app's entry: a primary "Get started" enters the app (Home), and a secondary action opens the country picker first.

**Architecture:** `OnboardingScreen` is a plain `StatelessWidget` (no data deps) using go_router to navigate: "Get started" → `context.go(AppRoutes.home)`; "Choose your work country" → `context.push(AppRoutes.countryPicker)`. The router's `initialLocation` becomes `/onboarding`. The two app-boot tests tap "Get started" to reach Home before asserting.

**Tech Stack:** Flutter, go_router. No new deps. No persistence yet (the screen shows on each launch; gating to first-launch-only is a follow-up once `get_storage` is wired).

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`), branch **`feat/onboarding`** (commit there, never switch). Baseline green: full app on main (Holidays/Plan/Sandwich/shell/Settings/country selection), 30 tests, analyzer clean. `lib/theme/colors.dart` = `DaysoffColors` (brandTeal, brandTealDark, sage, cream, creamSoft, neutral...). `AppRoutes` (in `lib/router/app_router.dart`) has `home='/'`, `onboarding='/onboarding'`, `countryPicker='/picker/country'`; onboarding is currently a top-level route outside the shell.

## Out of scope
First-launch-only gating / persistence, auth, sign-up. Scenic photo asset (use a teal→sage gradient hero — no bundled image).

---

## File Structure
```
lib/screens/onboarding/onboarding_screen.dart   REPLACE stub → Welcome
lib/router/app_router.dart                        MODIFY: initialLocation → /onboarding
test/screens/onboarding/onboarding_screen_test.dart  NEW
test/widget_test.dart                             MODIFY: tap "Get started" → Home
test/router/app_shell_test.dart                   MODIFY: tap "Get started" → shell
```

---

## Task 0: Commit plan
- [ ] `git add docs/superpowers/plans/2026-06-04-onboarding.md && git commit -m "docs: add onboarding (welcome) plan"`

---

## Task 1: OnboardingScreen (Welcome)

**Files:** Replace `lib/screens/onboarding/onboarding_screen.dart`; Test `test/screens/onboarding/onboarding_screen_test.dart`

- [ ] **Step 1: Write the failing test**

`test/screens/onboarding/onboarding_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:daysoff_mobile/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('renders value prop and Get started enters the app', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
        GoRoute(path: '/', builder: (c, s) => const Scaffold(body: Text('HOME'))),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('daysoff'), findsOneWidget);
    expect(find.textContaining('longest break'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/screens/onboarding/onboarding_screen_test.dart` (stub has no 'Get started').

- [ ] **Step 3: Implement**

Replace `lib/screens/onboarding/onboarding_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../theme/colors.dart';

/// Value-first welcome. "Get started" enters the app immediately; the
/// secondary action lets the user choose their work country first.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DaysoffColors.brandTeal, DaysoffColors.sage],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                const Text('daysoff',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: DaysoffColors.cream)),
                const SizedBox(height: 16),
                const Text(
                  'Find the longest break for the fewest days off.',
                  style: TextStyle(
                      fontSize: 22,
                      height: 1.3,
                      color: DaysoffColors.creamSoft,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Built for 연차, बिदा, 有給休暇, and every other word for it.',
                  style: TextStyle(fontSize: 14, color: DaysoffColors.creamSoft),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: DaysoffColors.cream,
                      foregroundColor: DaysoffColors.brandTealDark,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                    ),
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Get started',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.countryPicker),
                    child: const Text('Choose your work country',
                        style: TextStyle(color: DaysoffColors.cream)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run → PASS** — `flutter test test/screens/onboarding/onboarding_screen_test.dart`
- [ ] **Step 5: Commit** — `git add lib/screens/onboarding/onboarding_screen.dart test/screens/onboarding/onboarding_screen_test.dart && git commit -m "feat(onboarding): real value-first Welcome screen"`

---

## Task 2: Make onboarding the entry route + fix boot tests

**Files:** Modify `lib/router/app_router.dart`, `test/widget_test.dart`, `test/router/app_shell_test.dart`

- [ ] **Step 1: Update the two boot tests first (they will fail until the route + screen are wired together)**

In `test/widget_test.dart` — after `pumpWidget(... DaysoffApp ...)` and an initial `pumpAndSettle()`, the app now starts on Onboarding; tap into the app, THEN assert Home + nav bar. Replace the test body's post-pump section so it reads:
```dart
    await tester.pumpAndSettle();
    // App opens on the Welcome screen; enter the app.
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('No holidays for this year.'), findsOneWidget);
```
(Keep the existing `ProviderScope` + `holidaysProvider` override wrapper unchanged.)

In `test/router/app_shell_test.dart` — same: after the initial `pumpAndSettle()`, tap "Get started" before asserting the nav bar / tapping Settings:
```dart
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    // ...rest of the existing assertions unchanged...
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/widget_test.dart test/router/app_shell_test.dart`
Expected: FAIL — app still starts at Home (no 'Get started' to tap) because `initialLocation` is still `/`.

- [ ] **Step 3: Implement — flip the initial route**

In `lib/router/app_router.dart`, change the `GoRouter` `initialLocation` from `AppRoutes.home` to `AppRoutes.onboarding`. (Leave everything else — the shell branches, the onboarding GoRoute, the picker route — unchanged.)

- [ ] **Step 4: Run → PASS + full gate**

Run: `flutter test test/widget_test.dart test/router/app_shell_test.dart`
Expected: PASS. Then:
Run: `flutter test && flutter analyze`
Expected: all tests pass; analyzer clean.

- [ ] **Step 5: Commit** — `git add lib/router/app_router.dart test/widget_test.dart test/router/app_shell_test.dart && git commit -m "feat(onboarding): make Welcome the initial route; update boot tests"`

---

## Self-review
- **Coverage:** real Welcome screen ✓ (T1); set as entry route + value-first "Get started" + country shortcut + boot-test updates ✓ (T2).
- **Placeholder scan:** none — full code. Hero is a gradient (no bundled photo, noted out-of-scope).
- **Type consistency:** `OnboardingScreen` StatelessWidget; `context.go(AppRoutes.home)` / `context.push(AppRoutes.countryPicker)`; `initialLocation: AppRoutes.onboarding`.
- **Test-safety:** boot tests now tap "Get started" to reach Home, preserving their Home/nav-bar assertions; the holidays override still applies once on Home.

## Done when
`flutter test && flutter analyze` clean; launching the app shows the Welcome screen, "Get started" enters the 4-tab app on Home (KR/2026 live data), and "Choose your work country" opens the searchable picker. (It appears each launch until first-run persistence is added.)
