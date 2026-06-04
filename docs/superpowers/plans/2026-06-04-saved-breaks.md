# daysoff-mobile — Saved Breaks (local) Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Let users save breaks (from break detail) and sandwich days (from the sandwich card) to a persisted "Saved" list, reachable from a bookmark on Home, with remove.

**Architecture:** A `SavedBreak` freezed model (JSON-serializable). A `savedBreaksProvider` (`NotifierProvider<SavedBreaksNotifier, List<SavedBreak>>`) loads/persists a JSON list via `get_storage`, guarded by the existing `storageReady` flag (no-op in tests → in-memory only, no ripple to storage). A `SavedScreen` lists/removes them; a `/saved` route (root navigator) reachable via a bookmark `IconButton` on Home. The break-detail screen + sandwich card gain working Save actions (they become `ConsumerWidget`s).

**Tech Stack:** Flutter, flutter_riverpod, go_router, freezed, get_storage. No new deps.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile` (package `daysoff_mobile`), branch **`feat/saved-breaks`** (commit there, never switch). Baseline green: full app on main, 38 tests, analyzer clean. `lib/core/storage_keys.dart` has `StorageKeys` + `storageReady` (set by `markStorageReady()` in main). Existing: `lib/screens/plan/break_detail_screen.dart` (StatelessWidget, `trip` of type `PlanTrip`), `lib/screens/sandwich/widgets/sandwich_card.dart` (StatelessWidget, `record` of type `SandwichRecord`, "Save + remind" OutlinedButton at line ~51 with no-op onPressed), `home_screen.dart` (`_HolidaysList` ConsumerWidget builds a `SliverAppBar`), router `StatefulShellRoute` + top-level routes (onboarding/picker, `_rootNavigatorKey`).

## Known ripple (allowed, minimal)
Wiring Riverpod into `break_detail_screen.dart` and `sandwich_card.dart` (→ `ConsumerWidget`) means their existing tests (`test/screens/plan/break_detail_test.dart`, `test/screens/sandwich/sandwich_card_test.dart`) must wrap the pumped widget in a `ProviderScope`. Those two test updates are expected; do not change other tests.

## Out of scope
Calendar write-back, local notifications/reminders (the "remind" half) — those need native plugins + a device; this is **save-only** ("Save + remind" becomes "Save"). Editing saved items.

---

## File Structure
```
lib/api/models/saved_break.dart              NEW (+ codegen)
lib/providers/saved_breaks_provider.dart      NEW (Notifier)
lib/screens/saved/saved_screen.dart           NEW
lib/router/app_router.dart                     MODIFY: /saved route
lib/core/storage_keys.dart                     MODIFY: add savedBreaks key
lib/screens/home/home_screen.dart              MODIFY: bookmark → /saved
lib/screens/plan/break_detail_screen.dart      MODIFY: ConsumerWidget + Save button
lib/screens/sandwich/widgets/sandwich_card.dart MODIFY: ConsumerWidget + wire Save
test/providers/saved_breaks_provider_test.dart NEW
test/screens/saved/saved_screen_test.dart      NEW
test/screens/plan/break_detail_test.dart       MODIFY: wrap in ProviderScope + save assertion
test/screens/sandwich/sandwich_card_test.dart  MODIFY: wrap in ProviderScope + save assertion
```

---

## Task 1: SavedBreak model + savedBreaksProvider

**Files:** Create `lib/api/models/saved_break.dart` (+codegen), `lib/providers/saved_breaks_provider.dart`; Modify `lib/core/storage_keys.dart`; Test `test/providers/saved_breaks_provider_test.dart`

- [ ] **Step 1:** Add to `StorageKeys` (in `lib/core/storage_keys.dart`): `static const savedBreaks = 'saved_breaks';`

- [ ] **Step 2: Failing test** — `test/providers/saved_breaks_provider_test.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';

SavedBreak _b(String id) => SavedBreak(
      id: id,
      label: '5-day break',
      start: DateTime(2026, 9, 23),
      end: DateTime(2026, 9, 27),
      ptoCost: 1,
      kind: 'break',
    );

void main() {
  test('starts empty, add then remove (in-memory; storage no-op in tests)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(savedBreaksProvider), isEmpty);

    c.read(savedBreaksProvider.notifier).add(_b('break-1'));
    expect(c.read(savedBreaksProvider).map((e) => e.id), ['break-1']);

    // de-dupes by id
    c.read(savedBreaksProvider.notifier).add(_b('break-1'));
    expect(c.read(savedBreaksProvider).length, 1);

    c.read(savedBreaksProvider.notifier).remove('break-1');
    expect(c.read(savedBreaksProvider), isEmpty);
  });

  test('SavedBreak JSON round-trips', () {
    final b = _b('x');
    expect(SavedBreak.fromJson(b.toJson()).id, 'x');
    expect(SavedBreak.fromJson(b.toJson()).start, DateTime(2026, 9, 23));
  });
}
```

- [ ] **Step 3: Run → FAIL**

- [ ] **Step 4: Implement**

`lib/api/models/saved_break.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_break.freezed.dart';
part 'saved_break.g.dart';

@freezed
class SavedBreak with _$SavedBreak {
  const factory SavedBreak({
    required String id,
    required String label,
    required DateTime start,
    required DateTime end,
    required int ptoCost,
    required String kind, // 'break' | 'sandwich'
  }) = _SavedBreak;

  factory SavedBreak.fromJson(Map<String, dynamic> json) =>
      _$SavedBreakFromJson(json);
}
```
Run `dart run build_runner build --delete-conflicting-outputs`.

`lib/providers/saved_breaks_provider.dart`:
```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../api/models/saved_break.dart';
import '../core/storage_keys.dart';

class SavedBreaksNotifier extends Notifier<List<SavedBreak>> {
  @override
  List<SavedBreak> build() => _load();

  List<SavedBreak> _load() {
    try {
      if (!storageReady) return [];
      final raw = GetStorage().read<String>(StorageKeys.savedBreaks);
      if (raw == null) return [];
      final list = (jsonDecode(raw) as List)
          .map((e) => SavedBreak.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  void _persist() {
    try {
      if (!storageReady) return;
      GetStorage().write(
        StorageKeys.savedBreaks,
        jsonEncode(state.map((e) => e.toJson()).toList()),
      );
    } catch (_) {/* no-op in tests */}
  }

  void add(SavedBreak b) {
    if (state.any((x) => x.id == b.id)) return;
    state = [...state, b];
    _persist();
  }

  void remove(String id) {
    state = state.where((x) => x.id != id).toList();
    _persist();
  }
}

final savedBreaksProvider =
    NotifierProvider<SavedBreaksNotifier, List<SavedBreak>>(
        SavedBreaksNotifier.new);
```

- [ ] **Step 5: Run → PASS**; then `flutter test && flutter analyze` (38 existing + new still green).
- [ ] **Step 6: Commit** — `git add lib/api/models/saved_break* lib/providers/saved_breaks_provider.dart lib/core/storage_keys.dart test/providers/saved_breaks_provider_test.dart && git commit -m "feat(saved): SavedBreak model + persisted savedBreaksProvider"`

---

## Task 2: SavedScreen + route + Home bookmark

**Files:** Create `lib/screens/saved/saved_screen.dart`; Modify `lib/router/app_router.dart`, `lib/screens/home/home_screen.dart`; Test `test/screens/saved/saved_screen_test.dart`

- [ ] **Step 1: Failing test** — `test/screens/saved/saved_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/models/saved_break.dart';
import 'package:daysoff_mobile/providers/saved_breaks_provider.dart';
import 'package:daysoff_mobile/screens/saved/saved_screen.dart';

void main() {
  testWidgets('empty state when nothing saved', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: SavedScreen()),
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
      child: const MaterialApp(home: SavedScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('5-day break'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('5-day break'), findsNothing);
  });
}
```

- [ ] **Step 2: Run → FAIL**

- [ ] **Step 3: Implement**

`lib/screens/saved/saved_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/saved_breaks_provider.dart';
import '../../theme/colors.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedBreaksProvider);
    final fmt = DateFormat('MMM d');
    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: SafeArea(
        child: saved.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Nothing saved yet — plan a break to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700)),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: saved.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final b = saved[i];
                  return ListTile(
                    leading: Icon(
                      b.kind == 'sandwich' ? Icons.bakery_dining : Icons.event_available,
                      color: DaysoffColors.sage,
                    ),
                    title: Text(b.label),
                    subtitle: Text(
                        '${fmt.format(b.start)} – ${fmt.format(b.end)} · ${b.ptoCost} PTO'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(savedBreaksProvider.notifier).remove(b.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
```
In `lib/router/app_router.dart`: add `static const saved = '/saved';` to `AppRoutes`, import `SavedScreen`, and add a top-level `GoRoute(path: AppRoutes.saved, parentNavigatorKey: _rootNavigatorKey, builder: (c, s) => const SavedScreen())` (sibling of the shell/onboarding/picker routes).

In `lib/screens/home/home_screen.dart`: the `SliverAppBar` (in `_HolidaysList`) — add an `actions:` with `IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () => context.push(AppRoutes.saved))`. Add imports `package:go_router/go_router.dart` and `../../router/app_router.dart` if not already present.

- [ ] **Step 4: Run → PASS** — `flutter test test/screens/saved/saved_screen_test.dart`; then `flutter analyze` clean.
- [ ] **Step 5: Commit** — `git add lib/screens/saved/saved_screen.dart lib/router/app_router.dart lib/screens/home/home_screen.dart test/screens/saved/saved_screen_test.dart && git commit -m "feat(saved): Saved screen + /saved route + Home bookmark entry"`

---

## Task 3: Wire the Save actions (break detail + sandwich card)

**Files:** Modify `lib/screens/plan/break_detail_screen.dart`, `lib/screens/sandwich/widgets/sandwich_card.dart`; Modify their tests `test/screens/plan/break_detail_test.dart`, `test/screens/sandwich/sandwich_card_test.dart`

- [ ] **Step 1: Update the two existing tests first** (they will fail once the widgets become ConsumerWidgets without a ProviderScope, and we add save assertions). READ each test; wrap the pumped widget in `ProviderScope(child: MaterialApp(...))` (or `UncontrolledProviderScope` with a container when asserting saves). Add to `break_detail_test.dart` a new case:
```dart
  testWidgets('Save this break adds to savedBreaksProvider', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final trip = PlanTrip(
      breakStart: DateTime(2026, 9, 23), breakEnd: DateTime(2026, 9, 27),
      breakLength: 5, ptoDates: [DateTime(2026, 9, 23)], ptoCost: 1,
      anchors: const ['Chuseok']);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: BreakDetailScreen(trip: trip)),
    ));
    await tester.tap(find.text('Save this break'));
    await tester.pump();
    expect(container.read(savedBreaksProvider).length, 1);
  });
```
(import `package:flutter_riverpod/flutter_riverpod.dart` + `package:daysoff_mobile/providers/saved_breaks_provider.dart`; wrap the EXISTING "day-by-day" test's pump in a plain `ProviderScope` so it still builds.)
Add the analogous case to `sandwich_card_test.dart` (tap 'Save', assert one item), and wrap its existing test's pump in `ProviderScope`.

- [ ] **Step 2: Run → FAIL** — `flutter test test/screens/plan/break_detail_test.dart test/screens/sandwich/sandwich_card_test.dart` (widgets aren't Consumers / no Save button yet).

- [ ] **Step 3: Implement**

`break_detail_screen.dart`: change `class BreakDetailScreen extends StatelessWidget` → `extends ConsumerWidget`, and `build(BuildContext context)` → `build(BuildContext context, WidgetRef ref)`. Add imports `package:flutter_riverpod/flutter_riverpod.dart`, `../../api/models/saved_break.dart`, `../../providers/saved_breaks_provider.dart`. After the day list (before the closing of the `ListView` children), add a Save button:
```dart
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: DaysoffColors.sage),
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Save this break'),
              onPressed: () {
                ref.read(savedBreaksProvider.notifier).add(SavedBreak(
                      id: 'break-${trip.breakStart.toIso8601String()}',
                      label: '${trip.breakLength}-day break',
                      start: trip.breakStart,
                      end: trip.breakEnd,
                      ptoCost: trip.ptoCost,
                      kind: 'break',
                    ));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved')));
              },
            ),
```

`sandwich_card.dart`: change to `ConsumerWidget` (`build(context, ref)`); imports as above. Replace the "Save + remind" button's `onPressed: () {}` with one that adds a SavedBreak and shows a SnackBar; relabel to `'Save'`:
```dart
              onPressed: () {
                ref.read(savedBreaksProvider.notifier).add(SavedBreak(
                      id: 'sandwich-${record.ptoDate.toIso8601String()}',
                      label: '${record.weekday} sandwich',
                      start: record.breakStart,
                      end: record.breakEnd,
                      ptoCost: record.ptoCost,
                      kind: 'sandwich',
                    ));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved')));
              },
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: const Text('Save'),
```
(Keep the existing `sandwich_card_test` content assertions valid — it asserted 'Take Monday...', '4-day break', context, '1 PTO'; the relabel from 'Save + remind' to 'Save' is fine as long as no test asserted that exact label. If a test asserted 'Save + remind', update it to 'Save'.)

- [ ] **Step 4: Run → PASS + FULL gate** — `flutter test && flutter analyze`. All pass, clean.
- [ ] **Step 5: Commit** — `git add lib/screens/plan/break_detail_screen.dart lib/screens/sandwich/widgets/sandwich_card.dart test/screens/plan/break_detail_test.dart test/screens/sandwich/sandwich_card_test.dart && git commit -m "feat(saved): wire Save actions on break detail + sandwich card"`

---

## Self-review
- **Coverage:** model + persisted notifier (storageReady-guarded) ✓ (T1); Saved screen + route + Home bookmark ✓ (T2); Save actions wired ✓ (T3).
- **Ripple:** only the two widget tests being Riverpod-wired get a ProviderScope wrapper (expected, noted). Storage is no-op in tests (storageReady false) → no storage ripple.
- **Placeholder scan:** none — complete code throughout.
- **Type consistency:** `SavedBreak`(id/label/start/end/ptoCost/kind); `savedBreaksProvider` NotifierProvider; `.notifier.add/remove`; `AppRoutes.saved='/saved'`; ids `break-<iso>` / `sandwich-<iso>`.

## Done when
`flutter test && flutter analyze` clean; saving a break (from break detail) or a sandwich day appears in the Saved screen (bookmark on Home), persists across relaunch, and can be removed.
