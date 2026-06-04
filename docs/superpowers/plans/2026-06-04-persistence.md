# daysoff-mobile — Persistence Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Persist the user's choices across launches — selected country, year, theme mode — and gate the Welcome screen to first-launch only.

**Architecture:** Add `get_storage` (sync key-value store; `GetStorage.init()` in `main`). The existing `StateProvider`s seed their initial value from storage and persist on change via `ref.listenSelf`, all wrapped in `try/catch` so that **tests which don't initialize storage keep using the in-code defaults and persist-writes silently no-op** (zero churn to the 31 existing tests). Onboarding-seen is a stored flag read by a go_router `redirect` (also `try/catch`), so on relaunch the app skips Welcome straight to Home.

**Tech Stack:** Flutter, get_storage, flutter_riverpod, go_router. One new dep: `get_storage`.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`), branch **`feat/persistence`** (commit there, never switch). Baseline green: full app on main, 31 tests, analyzer clean. Current: `lib/main.dart` (`runApp(ProviderScope(child: DaysoffApp()))`), `lib/providers/selection_provider.dart` (`selectedCountryProvider`='KR', `selectedYearProvider`=2026, plain StateProviders), `lib/providers/theme_mode_provider.dart` (ThemeMode.light), `lib/router/app_router.dart` (`initialLocation: AppRoutes.onboarding`, StatefulShellRoute, onboarding/picker top-level), `lib/screens/onboarding/onboarding_screen.dart` ("Get started"→`context.go(home)`, "Choose your work country"→`context.push(countryPicker)`).

## Critical design rule (no test ripple)
Every storage read/write is wrapped in `try/catch`. With no `GetStorage.init()` (the state in existing tests), reads throw → caught → fall back to the in-code default (KR/2026/light/seen=false), and writes throw → caught → no-op. Therefore **do not modify any existing test**; only add new tests (which DO init storage to verify behavior).

## Out of scope
Migrating providers to Notifier; encrypting storage; syncing prefs to a backend.

---

## File Structure
```
pubspec.yaml                                  MODIFY: add get_storage
lib/core/storage_keys.dart                    NEW (key constants)
lib/main.dart                                 MODIFY: async + GetStorage.init()
lib/providers/selection_provider.dart         MODIFY: seed + persist (try/catch)
lib/providers/theme_mode_provider.dart        MODIFY: seed + persist (try/catch)
lib/router/app_router.dart                    MODIFY: redirect gating onboarding-seen
lib/screens/onboarding/onboarding_screen.dart MODIFY: write seen=true on proceed
test/providers/persistence_test.dart          NEW
test/router/onboarding_gate_test.dart         NEW
```

---

## Task 0: Add dependency + key constants + main init
**Files:** Modify `pubspec.yaml`, `lib/main.dart`; Create `lib/core/storage_keys.dart`

- [ ] **Step 1:** Add to `pubspec.yaml` dependencies (under the existing deps): `  get_storage: ^2.1.1` then run `flutter pub get` (expect "Got dependencies!").
- [ ] **Step 2:** Create `lib/core/storage_keys.dart`:
```dart
/// Keys for the on-device key-value store (get_storage).
class StorageKeys {
  StorageKeys._();
  static const country = 'selected_country';
  static const year = 'selected_year';
  static const themeMode = 'theme_mode';
  static const onboardingSeen = 'onboarding_seen';
}
```
- [ ] **Step 3:** Replace `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const ProviderScope(child: DaysoffApp()));
}
```
- [ ] **Step 4:** `flutter analyze` (clean). **Commit:** `git add pubspec.yaml pubspec.lock lib/core/storage_keys.dart lib/main.dart && git commit -m "chore(persistence): add get_storage, init in main, storage keys"`

---

## Task 1: Persist selection + theme

**Files:** Modify `lib/providers/selection_provider.dart`, `lib/providers/theme_mode_provider.dart`; Test `test/providers/persistence_test.dart`

- [ ] **Step 1: Write the failing test**

`test/providers/persistence_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:daysoff_mobile/core/storage_keys.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';
import 'package:daysoff_mobile/providers/theme_mode_provider.dart';

void main() {
  setUp(() async {
    await GetStorage.init();
    await GetStorage().erase();
  });

  test('selection seeds from storage and persists changes', () {
    GetStorage().write(StorageKeys.country, 'NP');
    GetStorage().write(StorageKeys.year, 2027);
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(selectedCountryProvider), 'NP');
    expect(c.read(selectedYearProvider), 2027);

    c.read(selectedCountryProvider.notifier).state = 'JP';
    expect(GetStorage().read(StorageKeys.country), 'JP');
  });

  test('theme seeds from storage and persists changes', () {
    GetStorage().write(StorageKeys.themeMode, 'dark');
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(themeModeProvider), ThemeMode.dark);

    c.read(themeModeProvider.notifier).state = ThemeMode.system;
    expect(GetStorage().read(StorageKeys.themeMode), 'system');
  });

  test('defaults hold when storage is empty', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(selectedCountryProvider), 'KR');
    expect(c.read(selectedYearProvider), 2026);
    expect(c.read(themeModeProvider), ThemeMode.light);
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/providers/persistence_test.dart` (current providers ignore storage).

- [ ] **Step 3: Implement**

Replace `lib/providers/selection_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import '../core/storage_keys.dart';

/// Reads a value from get_storage, tolerating an uninitialized store (tests).
T? _read<T>(String key) {
  try {
    return GetStorage().read<T>(key);
  } catch (_) {
    return null;
  }
}

void _write(String key, Object value) {
  try {
    GetStorage().write(key, value);
  } catch (_) {/* storage not initialized (tests) — no-op */}
}

final selectedCountryProvider = StateProvider<String>((ref) {
  ref.listenSelf((_, next) => _write(StorageKeys.country, next));
  return _read<String>(StorageKeys.country) ?? 'KR';
});

final selectedYearProvider = StateProvider<int>((ref) {
  ref.listenSelf((_, next) => _write(StorageKeys.year, next));
  return _read<int>(StorageKeys.year) ?? 2026;
});
```

Replace `lib/providers/theme_mode_provider.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import '../core/storage_keys.dart';

ThemeMode _readThemeMode() {
  String? stored;
  try {
    stored = GetStorage().read<String>(StorageKeys.themeMode);
  } catch (_) {
    stored = null;
  }
  return ThemeMode.values.firstWhere(
    (m) => m.name == stored,
    orElse: () => ThemeMode.light,
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  ref.listenSelf((_, next) {
    try {
      GetStorage().write(StorageKeys.themeMode, next.name);
    } catch (_) {/* no-op in tests */}
  });
  return _readThemeMode();
});
```

- [ ] **Step 4: Run → PASS** — `flutter test test/providers/persistence_test.dart`
- [ ] **Step 5: Full gate** — `flutter test && flutter analyze` (the other 31 tests still pass — they don't init storage, so defaults hold). 
- [ ] **Step 6: Commit** — `git add lib/providers/selection_provider.dart lib/providers/theme_mode_provider.dart test/providers/persistence_test.dart && git commit -m "feat(persistence): persist selected country/year + theme via get_storage"`

---

## Task 2: First-launch-only onboarding (stored flag + redirect)

**Files:** Modify `lib/router/app_router.dart`, `lib/screens/onboarding/onboarding_screen.dart`; Test `test/router/onboarding_gate_test.dart`

- [ ] **Step 1: Write the failing test**

`test/router/onboarding_gate_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/app.dart';
import 'package:daysoff_mobile/core/storage_keys.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';

void main() {
  setUp(() async {
    await GetStorage.init();
    await GetStorage().erase();
  });

  testWidgets('when onboarding already seen, app skips Welcome to Home',
      (tester) async {
    GetStorage().write(StorageKeys.onboardingSeen, true);

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

    // No Welcome CTA — we're on Home (inside the nav shell).
    expect(find.text('Get started'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/router/onboarding_gate_test.dart` (no redirect yet → Welcome shows → 'Get started' is found → expectation fails).

- [ ] **Step 3: Implement**

In `lib/router/app_router.dart`: add imports `import 'package:get_storage/get_storage.dart';` and `import '../core/storage_keys.dart';`, and add a `redirect` to the `GoRouter` (alongside `initialLocation`/`routes`):
```dart
  redirect: (context, state) {
    bool seen;
    try {
      seen = GetStorage().read<bool>(StorageKeys.onboardingSeen) ?? false;
    } catch (_) {
      seen = false;
    }
    final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
    if (seen && atOnboarding) return AppRoutes.home;   // skip Welcome on return visits
    if (!seen && !atOnboarding) return AppRoutes.onboarding; // force Welcome first-launch
    return null;
  },
```
(Leave `initialLocation: AppRoutes.onboarding` as-is; the redirect handles both directions.)

In `lib/screens/onboarding/onboarding_screen.dart`: add imports `import 'package:get_storage/get_storage.dart';` and `import '../../core/storage_keys.dart';`. Add a helper and call it before navigating in BOTH actions:
```dart
  void _markSeen() {
    try {
      GetStorage().write(StorageKeys.onboardingSeen, true);
    } catch (_) {/* no-op in tests */}
  }
```
- "Get started" `onPressed`: `() { _markSeen(); context.go(AppRoutes.home); }`
- "Choose your work country" `onPressed`: `() { _markSeen(); context.push(AppRoutes.countryPicker); }`

- [ ] **Step 4: Run → PASS + full gate**

Run: `flutter test test/router/onboarding_gate_test.dart`
Expected: PASS. Then:
Run: `flutter test && flutter analyze`
Expected: ALL pass (existing boot tests still start at Welcome because they don't init storage → `seen=false` → redirect keeps them on onboarding, and they already tap 'Get started'); analyzer clean.

- [ ] **Step 5: Commit** — `git add lib/router/app_router.dart lib/screens/onboarding/onboarding_screen.dart test/router/onboarding_gate_test.dart && git commit -m "feat(persistence): show onboarding only on first launch (stored flag + redirect)"`

---

## Self-review
- **Coverage:** get_storage init ✓ (T0); persist country/year/theme ✓ (T1); first-launch onboarding gate ✓ (T2).
- **No test ripple:** all reads/writes try/catch; existing tests (no `GetStorage.init()`) keep defaults — only NEW tests init storage. Verified by the "defaults hold when storage is empty" test + the full gate step.
- **Placeholder scan:** none — complete code.
- **Type consistency:** `StorageKeys.{country,year,themeMode,onboardingSeen}`; providers unchanged in TYPE (still `StateProvider<String/int/ThemeMode>`, so `.notifier.state` writes elsewhere keep working); redirect + `_markSeen` use the same keys.

## Done when
`flutter test && flutter analyze` clean; on a real device, choosing a country/year and a theme then force-quitting and relaunching restores them, and the Welcome screen appears only on the very first launch.
