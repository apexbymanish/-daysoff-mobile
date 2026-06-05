# Plan Modern (6.6) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Filter-chip row + "Best value" callout + day-type pill labels on the Plan screen.

**Architecture:** A pure `bestValueTrip` helper; a `PlanFilterChips` ConsumerWidget (country→picker, year→stepper dialog, weekend/budget→editor); `DayRibbon` upgraded from color bars to letter pills; a `BestValueBanner`; `_Buffet` in `plan_screen.dart` wires chips + banner.

**Tech Stack:** Flutter, flutter_riverpod, intl. **Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/plan-modern`** (commit there, never switch). Baseline: 71 tests, analyzer clean. `PlanTrip{breakStart,breakEnd,breakLength,ptoDates,ptoCost,anchors}`. `classifyBreakDay(day, ptoDates)→BreakDayKind{pto,weekend,holiday}` in `lib/core/break_days.dart`. Prefs providers in `lib/providers/preferences_provider.dart` (`ptoBudgetProvider`, `weekendProvider`, `formatWeekend`); `selectedCountryProvider`/`selectedYearProvider` in `lib/providers/selection_provider.dart`. `showPreferencesEditor(context)` in `lib/widgets/preferences_editor_sheet.dart`. `AppRoutes.countryPicker` in `lib/router/app_router.dart`. `countryFlag(code)` in `lib/core/country_flag.dart`. Colors `DaysoffColors` (sage, brandTeal, peach, cream, neutral300, neutral700, neutral900).

## Out of scope
Balance bar; carousel layout; Sandwich merge (6.7).

---

## Task 1: bestValueTrip helper

**Files:** Create `lib/core/plan_value.dart`, `test/core/plan_value_test.dart`

- [ ] **Step 1: failing test** — `test/core/plan_value_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/core/plan_value.dart';

PlanTrip _t(int len, int pto) => PlanTrip(
      breakStart: DateTime(2026, 1, 1),
      breakEnd: DateTime(2026, 1, len),
      breakLength: len,
      ptoDates: const [],
      ptoCost: pto,
      anchors: const ['X'],
    );

void main() {
  test('null for empty', () => expect(bestValueTrip(const []), isNull));

  test('a 0-PTO 3-day beats a 2-PTO 5-day', () {
    final best = bestValueTrip([_t(5, 2), _t(3, 0)]);
    expect(best!.breakLength, 3);
    expect(best.ptoCost, 0);
  });

  test('tie on ratio → fewer PTO wins', () {
    // 4 days/2 PTO = 2.0 vs 2 days/1 PTO = 2.0 → fewer PTO (1) wins
    final best = bestValueTrip([_t(4, 2), _t(2, 1)]);
    expect(best!.ptoCost, 1);
  });
}
```

- [ ] **Step 2: run → FAIL.**

- [ ] **Step 3: implement** — `lib/core/plan_value.dart`:
```dart
import '../api/models/plan_trip.dart';

/// The trip with the best "days off per PTO day" value. A 0-PTO break counts
/// as half a PTO day so it ranks above any paid break. Ties break toward fewer
/// PTO days, then a longer break.
PlanTrip? bestValueTrip(List<PlanTrip> trips) {
  if (trips.isEmpty) return null;
  double ratio(PlanTrip t) => t.breakLength / (t.ptoCost == 0 ? 0.5 : t.ptoCost);
  PlanTrip best = trips.first;
  for (final t in trips.skip(1)) {
    final r = ratio(t);
    final rb = ratio(best);
    if (r > rb ||
        (r == rb && t.ptoCost < best.ptoCost) ||
        (r == rb && t.ptoCost == best.ptoCost && t.breakLength > best.breakLength)) {
      best = t;
    }
  }
  return best;
}
```

- [ ] **Step 4: run → PASS.**
- [ ] **Step 5: commit** — `git add lib/core/plan_value.dart test/core/plan_value_test.dart && git commit -m "feat(plan): bestValueTrip helper"`

---

## Task 2: DayRibbon → letter pills

**Files:** Modify `lib/screens/plan/widgets/day_ribbon.dart`; Create `test/screens/plan/day_ribbon_test.dart`

- [ ] **Step 1: failing test** — `test/screens/plan/day_ribbon_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/screens/plan/widgets/day_ribbon.dart';

void main() {
  testWidgets('renders a letter pill per day (P for PTO, W for weekend)',
      (tester) async {
    // Sat 2026-01-03 (weekend) + Mon 2026-01-05 as PTO; break 3..5 Jan.
    final trip = PlanTrip(
      breakStart: DateTime(2026, 1, 3),
      breakEnd: DateTime(2026, 1, 5),
      breakLength: 3,
      ptoDates: [DateTime(2026, 1, 5)],
      ptoCost: 1,
      anchors: const ['X'],
    );
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: DayRibbon(trip: trip))),
    );
    expect(find.text('P'), findsWidgets); // at least the PTO day
    expect(find.text('W'), findsWidgets); // at least one weekend day
  });
}
```

- [ ] **Step 2: run → FAIL** (current ribbon has no text).

- [ ] **Step 3: replace `lib/screens/plan/widgets/day_ribbon.dart`**:
```dart
import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../core/break_days.dart';
import '../../../theme/colors.dart';

/// A row of small letter pills, one per break day: P (PTO), W (weekend),
/// H (the anchoring holiday).
class DayRibbon extends StatelessWidget {
  const DayRibbon({super.key, required this.trip});
  final PlanTrip trip;

  ({String label, Color color}) _pill(DateTime day) =>
      switch (classifyBreakDay(day, trip.ptoDates)) {
        BreakDayKind.pto => (label: 'P', color: DaysoffColors.sage),
        BreakDayKind.weekend => (label: 'W', color: DaysoffColors.brandTeal),
        BreakDayKind.holiday => (label: 'H', color: DaysoffColors.peach),
      };

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return Row(
      children: [
        for (final d in days)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: () {
              final p = _pill(d);
              return Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.color.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(p.label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DaysoffColors.neutral900)),
              );
            }(),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: run → PASS** — `flutter test test/screens/plan/day_ribbon_test.dart`. Confirm `break_card` still compiles (same `DayRibbon(trip:)` API).
- [ ] **Step 5: commit** — `git add lib/screens/plan/widgets/day_ribbon.dart test/screens/plan/day_ribbon_test.dart && git commit -m "feat(plan): day-type letter pills (P/W/H) in DayRibbon"`

---

## Task 3: PlanFilterChips

**Files:** Create `lib/screens/plan/widgets/plan_filter_chips.dart`, `test/screens/plan/plan_filter_chips_test.dart`

- [ ] **Step 1: failing test** — `test/screens/plan/plan_filter_chips_test.dart`:
```dart
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
```

- [ ] **Step 2: run → FAIL.**

- [ ] **Step 3: implement** — `lib/screens/plan/widgets/plan_filter_chips.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country_flag.dart';
import '../../../providers/preferences_provider.dart';
import '../../../providers/selection_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/preferences_editor_sheet.dart';

/// Horizontal chip row reflecting the plan prefs; each chip opens its editor.
class PlanFilterChips extends ConsumerWidget {
  const PlanFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final budget = ref.watch(ptoBudgetProvider);
    final weekend = ref.watch(weekendProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ActionChip(
            avatar: Text(countryFlag(country)),
            label: Text(country),
            onPressed: () => context.push(AppRoutes.countryPicker),
          ),
          ActionChip(
            label: Text('$year'),
            onPressed: () => _showYearDialog(context, ref, year),
          ),
          ActionChip(
            label: Text('${formatWeekend(weekend)} off'),
            onPressed: () => showPreferencesEditor(context),
          ),
          ActionChip(
            label: Text('$budget days'),
            onPressed: () => showPreferencesEditor(context),
          ),
        ],
      ),
    );
  }

  void _showYearDialog(BuildContext context, WidgetRef ref, int year) {
    var temp = year;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Year'),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                key: const Key('year_dec'),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() => temp -= 1),
              ),
              Text('$temp', style: const TextStyle(fontSize: 20)),
              IconButton(
                key: const Key('year_inc'),
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => temp += 1),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(selectedYearProvider.notifier).state = temp;
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
```
> Note: the year stepper writes `selectedYearProvider` on each `+`/`-` immediately (so the test sees 2027 right after tapping `+`), then "Done" closes. (The `temp`/setState drives the dialog label; the provider write happens in the button handlers — adjust so `+`/`-` both `setState` AND `ref.read(...).state = temp`.) Implement the `+`/`-` handlers as:
```dart
                onPressed: () { temp += 1; ref.read(selectedYearProvider.notifier).state = temp; setState(() {}); },
```
and similarly for `-`. Keep "Done" just popping.

- [ ] **Step 4: run → PASS** — `flutter test test/screens/plan/plan_filter_chips_test.dart`.
- [ ] **Step 5: commit** — `git add lib/screens/plan/widgets/plan_filter_chips.dart test/screens/plan/plan_filter_chips_test.dart && git commit -m "feat(plan): PlanFilterChips (country/year/weekend/budget)"`

---

## Task 4: BestValueBanner + wire into _Buffet

**Files:** Create `lib/screens/plan/widgets/best_value_banner.dart`, `test/screens/plan/best_value_banner_test.dart`; Modify `lib/screens/plan/plan_screen.dart`

- [ ] **Step 1: failing test** — `test/screens/plan/best_value_banner_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/plan_trip.dart';
import 'package:daysoff_mobile/screens/plan/widgets/best_value_banner.dart';

void main() {
  testWidgets('shows the length + PTO text', (tester) async {
    final t = PlanTrip(
      breakStart: DateTime(2026, 9, 23),
      breakEnd: DateTime(2026, 9, 27),
      breakLength: 5,
      ptoDates: const [],
      ptoCost: 1,
      anchors: const ['Chuseok'],
    );
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: BestValueBanner(trip: t))));
    expect(find.textContaining('Best value'), findsOneWidget);
    expect(find.textContaining('5-day'), findsOneWidget);
  });
}
```

- [ ] **Step 2: run → FAIL.**

- [ ] **Step 3: implement** — `lib/screens/plan/widgets/best_value_banner.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../api/models/plan_trip.dart';
import '../../../theme/colors.dart';

/// Sage callout highlighting the best-value break.
class BestValueBanner extends StatelessWidget {
  const BestValueBanner({super.key, required this.trip});
  final PlanTrip trip;

  @override
  Widget build(BuildContext context) {
    final pto = trip.ptoCost == 0 ? 'no' : '${trip.ptoCost}';
    final unit = trip.ptoCost == 1 ? 'PTO day' : 'PTO days';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DaysoffColors.sage.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 18, color: DaysoffColors.brandTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Best value found',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text('${trip.breakLength}-day break for $pto $unit',
                    style: const TextStyle(
                        fontSize: 13, color: DaysoffColors.neutral700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: run → PASS** — `flutter test test/screens/plan/best_value_banner_test.dart`.

- [ ] **Step 5: wire into `_Buffet`** in `lib/screens/plan/plan_screen.dart`. Add imports:
```dart
import '../../core/plan_value.dart';
import 'widgets/plan_filter_chips.dart';
import 'widgets/best_value_banner.dart';
```
In `_Buffet.build`, replace the leading subtitle `Padding(...Text('${countryFlag...} budget ... days'))` child of the ListView with `const PlanFilterChips()`, and insert the banner right after it:
```dart
    final trips = _bestPerLength;
    // ... existing empty check ...
    final best = bestValueTrip(trips);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        const PlanFilterChips(),
        if (best != null) BestValueBanner(trip: best),
        for (final t in trips)
          BreakCard(trip: t, onTap: () => context.push(AppRoutes.breakDetail, extra: t)),
        const SizedBox(height: 32),
      ],
    );
```
Remove the now-unused `countryFlag` import if nothing else in the file uses it (check first).

- [ ] **Step 6: full gate** — `flutter test` (expect ~78: 71 + 7 new) and `flutter analyze` (clean). If the existing plan screen test asserted the old "KR · 2026 · budget" subtitle, update that assertion to the chips (e.g. find `PlanFilterChips`); otherwise leave it.

- [ ] **Step 7: commit** — `git add lib/screens/plan/widgets/best_value_banner.dart lib/screens/plan/plan_screen.dart test/screens/plan/best_value_banner_test.dart && git commit -m "feat(plan): best-value callout + filter chips in the buffet"`

---

## Self-review
- **Coverage:** filter chips ✓ (T3); best-value callout ✓ (T1+T4); day-type pills ✓ (T2); wired into Plan ✓ (T4). Balance bar intentionally out.
- **Placeholders:** none — full code. The year-dialog note clarifies the `+`/`-` handlers write the provider immediately.
- **Types:** `bestValueTrip(List<PlanTrip>)→PlanTrip?`; `DayRibbon(trip:)` API unchanged; `PlanFilterChips()`/`BestValueBanner(trip:)`; uses existing `showPreferencesEditor`, `AppRoutes.countryPicker`, `formatWeekend`, `countryFlag`.

## Done when
`flutter test && flutter analyze` clean; Plan shows pref filter chips (country→picker, year→stepper, weekend/budget→editor), a best-value callout, and break cards with P/W/H day pills.
