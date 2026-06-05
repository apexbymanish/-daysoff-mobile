# Editable Plan Preferences Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users edit PTO budget, break length (min–max), and weekend (days off) from a shared editor sheet reachable from Settings and Plan; persist them and thread them into `/v1/plan` and `/v1/sandwiches`.

**Architecture:** Three `storageReady`-guarded `StateProvider`s (mirroring `selection_provider.dart`) hold the prefs. A shared `lib/core/storage_io.dart` exposes the read/write helpers (used by the new providers and the existing selection providers). `PlanQuery`/`SandwichesQuery` gain a `workweek` field; the screens build their queries from the providers. One `PreferencesEditorSheet` is shown from both Settings rows and a Plan "Adjust" button.

**Tech Stack:** Flutter, flutter_riverpod (StateProvider + `ref.listenSelf`), get_storage, go_router.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`), branch **`feat/plan-preferences`** (commit there, never switch). Baseline green: full app on main, 44 tests, analyzer clean. The spec lives at `docs/superpowers/specs/2026-06-05-plan-preferences-design.md`. Coded defaults (15 / 3–10 / sat,sun) must stay identical so existing tests are unaffected.

## Out of scope
Country/year editing (already done), per-trip overrides, server-side persistence, onboarding-time setup.

---

## File Structure
```
lib/core/storage_io.dart                         NEW: storageRead<T>/storageWrite helpers
lib/core/storage_keys.dart                       MODIFY: + ptoBudget/breakMin/breakMax/weekend keys
lib/providers/preferences_provider.dart          NEW: BreakLengthRange, 3 providers, weekday consts, formatWeekend
lib/providers/selection_provider.dart            MODIFY: use shared storage_io helpers
lib/providers/plan_provider.dart                 MODIFY: PlanQuery.workweek; pass to getPlan
lib/providers/sandwiches_provider.dart           MODIFY: SandwichesQuery.workweek; pass to getSandwiches
lib/api/api_client.dart                          MODIFY: getPlan gains workweek param
lib/widgets/preferences_editor_sheet.dart        NEW: editor + showPreferencesEditor()
lib/screens/settings/settings_screen.dart        MODIFY: tappable rows, relabel, + break row
lib/screens/plan/plan_screen.dart                MODIFY: query from providers; Adjust button
lib/screens/sandwich/sandwich_screen.dart        MODIFY: query with weekend
test/providers/preferences_provider_test.dart    NEW
test/widgets/preferences_editor_sheet_test.dart  NEW
test/screens/settings/settings_screen_test.dart  NEW
test/screens/plan/plan_adjust_test.dart          NEW
```

---

## Task 1: Shared storage IO + preference providers

**Files:**
- Create: `lib/core/storage_io.dart`, `lib/providers/preferences_provider.dart`, `test/providers/preferences_provider_test.dart`
- Modify: `lib/core/storage_keys.dart`, `lib/providers/selection_provider.dart`

- [ ] **Step 1: Write the failing test** — `test/providers/preferences_provider_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/providers/preferences_provider.dart';

void main() {
  // storageReady defaults to false in tests → providers return coded defaults.
  test('providers expose coded defaults (15 / 3-10 / sat,sun)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(ptoBudgetProvider), 15);
    expect(c.read(breakLengthProvider), const BreakLengthRange(min: 3, max: 10));
    expect(c.read(weekendProvider), const ['sat', 'sun']);
  });

  test('BreakLengthRange equality + copyWith', () {
    const r = BreakLengthRange(min: 3, max: 10);
    expect(r.copyWith(max: 7), const BreakLengthRange(min: 3, max: 7));
    expect(r, const BreakLengthRange(min: 3, max: 10));
    expect(r == const BreakLengthRange(min: 4, max: 10), false);
  });

  test('formatWeekend orders by week and labels', () {
    expect(formatWeekend(const ['sun', 'sat']), 'Sat, Sun');
    expect(formatWeekend(const ['fri']), 'Fri');
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/providers/preferences_provider_test.dart` (file/types undefined).

- [ ] **Step 3a: Create `lib/core/storage_io.dart`**:
```dart
import 'package:get_storage/get_storage.dart';

import 'storage_keys.dart';

/// Reads a value from get_storage, tolerating an uninitialized store.
/// Returns null when [storageReady] is false so callers use coded defaults.
T? storageRead<T>(String key) {
  if (!storageReady) return null;
  try {
    return GetStorage().read<T>(key);
  } catch (_) {
    return null;
  }
}

/// Writes to get_storage only when [storageReady] is true (a no-op in tests
/// that never call GetStorage.init() — no async flush, no file I/O).
void storageWrite(String key, Object value) {
  if (!storageReady) return;
  try {
    GetStorage().write(key, value);
  } catch (_) {/* silently ignored */}
}
```

- [ ] **Step 3b: Add keys** — in `lib/core/storage_keys.dart`, inside the `StorageKeys` class after the `savedBreaks` line, add:
```dart
  static const ptoBudget = 'pto_budget';
  static const breakMin = 'break_min';
  static const breakMax = 'break_max';
  static const weekend = 'weekend';
```

- [ ] **Step 3c: Create `lib/providers/preferences_provider.dart`**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage_io.dart';
import '../core/storage_keys.dart';

/// Day-of-week keys in week order; values match the API's workweek tokens.
const kWeekdayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
const kWeekdayLabels = {
  'mon': 'Mon', 'tue': 'Tue', 'wed': 'Wed', 'thu': 'Thu',
  'fri': 'Fri', 'sat': 'Sat', 'sun': 'Sun',
};

/// "Sat, Sun" — week-ordered, ignoring the stored order.
String formatWeekend(List<String> days) =>
    kWeekdayKeys.where(days.contains).map((d) => kWeekdayLabels[d]).join(', ');

/// Inclusive min/max break length (days) for the plan buffet.
class BreakLengthRange {
  const BreakLengthRange({required this.min, required this.max});
  final int min;
  final int max;

  BreakLengthRange copyWith({int? min, int? max}) =>
      BreakLengthRange(min: min ?? this.min, max: max ?? this.max);

  @override
  bool operator ==(Object other) =>
      other is BreakLengthRange && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

final ptoBudgetProvider = StateProvider<int>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => storageWrite(StorageKeys.ptoBudget, next));
  return storageRead<int>(StorageKeys.ptoBudget) ?? 15;
});

final breakLengthProvider = StateProvider<BreakLengthRange>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) {
    storageWrite(StorageKeys.breakMin, next.min);
    storageWrite(StorageKeys.breakMax, next.max);
  });
  return BreakLengthRange(
    min: storageRead<int>(StorageKeys.breakMin) ?? 3,
    max: storageRead<int>(StorageKeys.breakMax) ?? 10,
  );
});

final weekendProvider = StateProvider<List<String>>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => storageWrite(StorageKeys.weekend, next));
  // get_storage returns a List<dynamic>; cast to List<String>.
  final stored = storageRead<List>(StorageKeys.weekend);
  return stored?.cast<String>() ?? const ['sat', 'sun'];
});
```

- [ ] **Step 3d: Refactor `lib/providers/selection_provider.dart`** to use the shared helpers. Replace its top (the imports, `_read`, `_write`) with:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage_io.dart';
import '../core/storage_keys.dart';
```
and update the two providers to call `storageRead`/`storageWrite` instead of `_read`/`_write`:
```dart
final selectedCountryProvider = StateProvider<String>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => storageWrite(StorageKeys.country, next));
  return storageRead<String>(StorageKeys.country) ?? 'KR';
});

final selectedYearProvider = StateProvider<int>((ref) {
  // ignore: deprecated_member_use
  ref.listenSelf((_, next) => storageWrite(StorageKeys.year, next));
  return storageRead<int>(StorageKeys.year) ?? 2026;
});
```
(Delete the now-unused private `_read`/`_write` and the `get_storage` import from this file.)

- [ ] **Step 4: Run → PASS** — `flutter test test/providers/preferences_provider_test.dart` and `flutter test test/` to confirm no regression in selection-related tests.

- [ ] **Step 5: Commit**:
```bash
git add lib/core/storage_io.dart lib/core/storage_keys.dart lib/providers/preferences_provider.dart lib/providers/selection_provider.dart test/providers/preferences_provider_test.dart
git commit -m "feat(prefs): persisted budget/break-length/weekend providers + shared storage_io"
```

---

## Task 2: Thread workweek through the API layer

**Files:** Modify `lib/api/api_client.dart`, `lib/providers/plan_provider.dart`, `lib/providers/sandwiches_provider.dart`; Test `test/providers/preferences_provider_test.dart` (append)

- [ ] **Step 1: Append failing tests** to `test/providers/preferences_provider_test.dart` (inside `main()`):
```dart
  test('PlanQuery includes workweek in equality', () {
    const a = PlanQuery(country: 'KR', year: 2026, workweek: ['sat', 'sun']);
    const b = PlanQuery(country: 'KR', year: 2026, workweek: ['fri', 'sat']);
    expect(a == b, false);
    expect(a == const PlanQuery(country: 'KR', year: 2026, workweek: ['sat', 'sun']), true);
  });

  test('SandwichesQuery includes workweek in equality', () {
    const a = SandwichesQuery(country: 'KR', year: 2026, workweek: ['sat', 'sun']);
    expect(a == const SandwichesQuery(country: 'KR', year: 2026, workweek: ['fri']), false);
    expect(a == const SandwichesQuery(country: 'KR', year: 2026, workweek: ['sat', 'sun']), true);
  });
```
Add the imports at the top of the test file:
```dart
import 'package:daysoff_mobile/providers/plan_provider.dart';
import 'package:daysoff_mobile/providers/sandwiches_provider.dart';
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/providers/preferences_provider_test.dart` (no `workweek` param on the queries).

- [ ] **Step 3a: `lib/api/api_client.dart`** — add a `workweek` param to `getPlan` (currently lines 48–66). Replace the method with:
```dart
  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
    List<String>? workweek,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.plan,
      queryParameters: {
        'country': country,
        'year': year,
        'budget': budget,
        'min_length': minLength,
        'max_length': maxLength,
        if (workweek != null && workweek.isNotEmpty) 'workweek': workweek.join(','),
      },
    );
    return PlanResponse.fromJson(response.data!);
  }
```

- [ ] **Step 3b: `lib/providers/plan_provider.dart`** — add a `workweek` field to `PlanQuery` and pass it through. Replace the whole file with:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/plan_response.dart';
import 'api_provider.dart';

/// Args for the plan query.
class PlanQuery {
  const PlanQuery({
    required this.country,
    required this.year,
    this.budget = 15,
    this.minLength = 3,
    this.maxLength = 10,
    this.workweek = const [],
  });

  final String country;
  final int year;
  final int budget;
  final int minLength;
  final int maxLength;
  final List<String> workweek;

  @override
  bool operator ==(Object other) =>
      other is PlanQuery &&
      other.country == country &&
      other.year == year &&
      other.budget == budget &&
      other.minLength == minLength &&
      other.maxLength == maxLength &&
      _listEq(other.workweek, workweek);

  @override
  int get hashCode =>
      Object.hash(country, year, budget, minLength, maxLength, Object.hashAll(workweek));
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Fetches /v1/plan for the given query.
final planProvider = FutureProvider.family<PlanResponse, PlanQuery>((ref, q) {
  final api = ref.watch(apiClientProvider);
  return api.getPlan(
    country: q.country,
    year: q.year,
    budget: q.budget,
    minLength: q.minLength,
    maxLength: q.maxLength,
    workweek: q.workweek,
  );
});
```

- [ ] **Step 3c: `lib/providers/sandwiches_provider.dart`** — add `workweek` and pass it. Replace the whole file with:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models/sandwiches_response.dart';
import 'api_provider.dart';

/// Args for the sandwiches query.
class SandwichesQuery {
  const SandwichesQuery({
    required this.country,
    required this.year,
    this.workweek = const [],
  });

  final String country;
  final int year;
  final List<String> workweek;

  @override
  bool operator ==(Object other) =>
      other is SandwichesQuery &&
      other.country == country &&
      other.year == year &&
      _listEq(other.workweek, workweek);

  @override
  int get hashCode => Object.hash(country, year, Object.hashAll(workweek));
}

bool _listEq(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Fetches /v1/sandwiches for a country + year + weekend.
final sandwichesProvider =
    FutureProvider.family<SandwichesResponse, SandwichesQuery>((ref, q) {
  final api = ref.watch(apiClientProvider);
  return api.getSandwiches(country: q.country, year: q.year, workweek: q.workweek);
});
```

- [ ] **Step 4: Run → PASS** — `flutter test test/providers/preferences_provider_test.dart`, then `flutter test test/screens/plan test/screens/sandwich` to confirm the existing plan/sandwich tests still pass (they inject a fake ApiClient + override the providers, so the new param doesn't affect them).

- [ ] **Step 5: Commit**:
```bash
git add lib/api/api_client.dart lib/providers/plan_provider.dart lib/providers/sandwiches_provider.dart test/providers/preferences_provider_test.dart
git commit -m "feat(prefs): thread workweek into PlanQuery/SandwichesQuery + getPlan"
```

---

## Task 3: PreferencesEditorSheet widget

**Files:** Create `lib/widgets/preferences_editor_sheet.dart`, `test/widgets/preferences_editor_sheet_test.dart`

- [ ] **Step 1: Write the failing test** — `test/widgets/preferences_editor_sheet_test.dart`:
```dart
import 'package:flutter/material.dart';
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
      child: const MaterialApp(home: Scaffold(body: PreferencesEditorSheet())),
    ));
    return c;
  }

  testWidgets('renders the three controls', (tester) async {
    await pump(tester);
    expect(find.text('PTO budget'), findsOneWidget);
    expect(find.text('Break length'), findsOneWidget);
    expect(find.text('Weekend (days off)'), findsOneWidget);
    expect(find.byType(RangeSlider), findsOneWidget);
    // 7 day chips
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
    // start sat,sun → remove sat, then removing sun should be blocked
    await tester.tap(find.text('Sat'));
    await tester.pump();
    await tester.tap(find.text('Sun'));
    await tester.pump();
    expect(c.read(weekendProvider).isNotEmpty, true);
  });
}
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/widgets/preferences_editor_sheet_test.dart`.

- [ ] **Step 3: Implement** — `lib/widgets/preferences_editor_sheet.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/preferences_provider.dart';
import '../theme/colors.dart';

/// Shows the shared preference editor as a modal bottom sheet.
Future<void> showPreferencesEditor(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: PreferencesEditorSheet(),
    ),
  );
}

/// Editor for PTO budget, break-length range and weekend (days off).
/// Each control writes to its provider immediately.
class PreferencesEditorSheet extends ConsumerWidget {
  const PreferencesEditorSheet({super.key});

  static const _minLen = 2;
  static const _maxLen = 21;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(ptoBudgetProvider);
    final range = ref.watch(breakLengthProvider);
    final weekend = ref.watch(weekendProvider);

    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        children: [
          const _Label('PTO budget'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const Key('budget_dec'),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: budget > 0
                    ? () => ref.read(ptoBudgetProvider.notifier).state = budget - 1
                    : null,
              ),
              Text('$budget days',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(
                key: const Key('budget_inc'),
                icon: const Icon(Icons.add_circle_outline),
                onPressed: budget < 40
                    ? () => ref.read(ptoBudgetProvider.notifier).state = budget + 1
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Label('Break length  (${range.min}–${range.max} days)'),
          RangeSlider(
            min: _minLen.toDouble(),
            max: _maxLen.toDouble(),
            divisions: _maxLen - _minLen,
            labels: RangeLabels('${range.min}', '${range.max}'),
            values: RangeValues(range.min.toDouble(), range.max.toDouble()),
            onChanged: (v) {
              var lo = v.start.round();
              var hi = v.end.round();
              if (lo > hi) lo = hi;
              ref.read(breakLengthProvider.notifier).state =
                  BreakLengthRange(min: lo, max: hi);
            },
          ),
          const SizedBox(height: 8),
          const _Label('Weekend (days off)'),
          Wrap(
            spacing: 8,
            children: [
              for (final key in kWeekdayKeys)
                FilterChip(
                  label: Text(kWeekdayLabels[key]!),
                  selected: weekend.contains(key),
                  onSelected: (sel) {
                    final next = [...weekend];
                    if (sel) {
                      if (next.length >= 6) return; // keep >=1 working day
                      if (!next.contains(key)) next.add(key);
                    } else {
                      if (next.length <= 1) return; // keep >=1 day off
                      next.remove(key);
                    }
                    ref.read(weekendProvider.notifier).state = next;
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DaysoffColors.neutral700)),
    );
  }
}
```

- [ ] **Step 4: Run → PASS** — `flutter test test/widgets/preferences_editor_sheet_test.dart`.

- [ ] **Step 5: Commit**:
```bash
git add lib/widgets/preferences_editor_sheet.dart test/widgets/preferences_editor_sheet_test.dart
git commit -m "feat(prefs): shared PreferencesEditorSheet (budget/length/weekend)"
```

---

## Task 4: Settings rows reflect + open the editor

**Files:** Modify `lib/screens/settings/settings_screen.dart`; Test `test/screens/settings/settings_screen_test.dart`

- [ ] **Step 1: Write the failing test** — `test/screens/settings/settings_screen_test.dart`:
```dart
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
```

- [ ] **Step 2: Run → FAIL** — `flutter test test/screens/settings/settings_screen_test.dart`.

- [ ] **Step 3: Implement** — replace `lib/screens/settings/settings_screen.dart` with:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/preferences_provider.dart';
import '../../providers/theme_mode_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/preferences_editor_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final budget = ref.watch(ptoBudgetProvider);
    final range = ref.watch(breakLengthProvider);
    final weekend = ref.watch(weekendProvider);
    void openEditor() => showPreferencesEditor(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            const _SectionHeader('PREFERENCES'),
            const _ValueRow(label: 'Country of work', value: '🇰🇷 South Korea'),
            _ValueRow(label: 'Weekend', value: formatWeekend(weekend), onTap: openEditor),
            _ValueRow(label: 'PTO budget', value: '$budget days', onTap: openEditor),
            _ValueRow(
                label: 'Break length',
                value: '${range.min}–${range.max} days',
                onTap: openEditor),
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
  const _ValueRow({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value,
          style: const TextStyle(color: DaysoffColors.neutral700)),
      onTap: onTap,
    );
  }
}
```

- [ ] **Step 4: Run → PASS** — `flutter test test/screens/settings/settings_screen_test.dart`.

- [ ] **Step 5: Commit**:
```bash
git add lib/screens/settings/settings_screen.dart test/screens/settings/settings_screen_test.dart
git commit -m "feat(prefs): Settings rows reflect + open the editor; relabel Weekend"
```

---

## Task 5: Plan + Sandwich build queries from providers; Plan "Adjust" button

**Files:** Modify `lib/screens/plan/plan_screen.dart`, `lib/screens/sandwich/sandwich_screen.dart`; Test `test/screens/plan/plan_adjust_test.dart`

- [ ] **Step 1: Write the failing test** — `test/screens/plan/plan_adjust_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/plan_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/plan/plan_screen.dart';
import 'package:daysoff_mobile/widgets/preferences_editor_sheet.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<PlanResponse> getPlan({
    required String country,
    required int year,
    int budget = 15,
    int minLength = 3,
    int maxLength = 10,
    List<String>? workweek,
  }) async =>
      const PlanResponse(
        country: 'KR',
        year: 2026,
        budget: 15,
        workweek: ['sat', 'sun'],
        workweekSource: 'user',
        resultsByLength: {},
      );
}

void main() {
  testWidgets('Adjust button opens the preferences editor', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: const MaterialApp(home: PlanScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adjust'));
    await tester.pumpAndSettle();
    expect(find.byType(PreferencesEditorSheet), findsOneWidget);
  });
}
```
> Note: confirm the `PlanResponse` constructor field names by reading `lib/api/models/plan_response.dart` first; adjust the fake's returned object to match (the empty `resultsByLength: {}` yields the "No breaks fit this budget" empty state, which is fine for this test).

- [ ] **Step 2: Run → FAIL** — `flutter test test/screens/plan/plan_adjust_test.dart` (no "Adjust" text yet).

- [ ] **Step 3a: `lib/screens/plan/plan_screen.dart`** — build the query from the providers and add the Adjust button. Apply these edits:

Add imports (after the existing `selection_provider.dart` import):
```dart
import '../../providers/preferences_provider.dart';
import '../../widgets/preferences_editor_sheet.dart';
```

Replace the build body's query construction (lines 19–21) with:
```dart
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final budget = ref.watch(ptoBudgetProvider);
    final range = ref.watch(breakLengthProvider);
    final weekend = ref.watch(weekendProvider);
    final query = PlanQuery(
      country: country,
      year: year,
      budget: budget,
      minLength: range.min,
      maxLength: range.max,
      workweek: weekend,
    );
```

Replace the `AppBar` (line 24) with one that carries the Adjust action:
```dart
      appBar: AppBar(
        title: const Text('Plan your year'),
        actions: [
          TextButton.icon(
            onPressed: () => showPreferencesEditor(context),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Adjust'),
          ),
        ],
      ),
```

- [ ] **Step 3b: `lib/screens/sandwich/sandwich_screen.dart`** — build the query with the weekend. Add import (after `selection_provider.dart`):
```dart
import '../../providers/preferences_provider.dart';
```
Replace the query construction (lines 15–17) with:
```dart
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final weekend = ref.watch(weekendProvider);
    final query = SandwichesQuery(country: country, year: year, workweek: weekend);
```

- [ ] **Step 4: Run → PASS** — `flutter test test/screens/plan/plan_adjust_test.dart`.

- [ ] **Step 5: Full gate** — `flutter test && flutter analyze` (all pass; analyzer clean).

- [ ] **Step 6: Commit**:
```bash
git add lib/screens/plan/plan_screen.dart lib/screens/sandwich/sandwich_screen.dart test/screens/plan/plan_adjust_test.dart
git commit -m "feat(prefs): Plan/Sandwich build queries from prefs; Plan Adjust button"
```

---

## Self-review
- **Spec coverage:** 3 persisted providers ✓ (T1); workweek threaded into PlanQuery/SandwichesQuery/getPlan ✓ (T2); shared editor sheet ✓ (T3); Settings tappable rows + relabel + break row ✓ (T4); Plan query-from-prefs + Adjust button + Sandwich weekend ✓ (T5). DRY storage helpers ✓ (T1). Defaults unchanged (15/3–10/sat,sun) ✓.
- **Placeholder scan:** none — full code in every step. The one "confirm field names" note (T5 fake `PlanResponse`) is a read-first instruction, not a placeholder; the engineer reads `plan_response.dart` and matches the constructor.
- **Type consistency:** `BreakLengthRange{min,max}` used identically in provider, editor, settings; `formatWeekend(List<String>)→String`; `PlanQuery.workweek`/`SandwichesQuery.workweek` are `List<String>` with `const []` default and list-equality; `getPlan(...workweek)` mirrors `getSandwiches`; `showPreferencesEditor(BuildContext)` + `PreferencesEditorSheet` used by both Settings and Plan.

## Done when
`flutter test && flutter analyze` clean; editing budget / break-length / weekend from either Settings or the Plan "Adjust" sheet updates the Plan buffet and Sandwich list live, persists across launches, and the Settings "Weekend" row shows the chosen days off.
```
