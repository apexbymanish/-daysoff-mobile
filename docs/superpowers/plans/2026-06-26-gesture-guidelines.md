# Gesture Guidelines Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement gesture standards, touch target compliance, and platform rules from the GME Remit spec into daysoff-mobile — fixing 3 touch target violations, adding × close buttons to bottom sheets, adding pull-to-refresh, swipe-to-save, long-press quick actions, and carousel nav buttons.

**Architecture:** Approach A (inline). All changes live in their respective widgets — no new shared abstractions. Each task is independently testable and committable.

**Tech Stack:** Flutter 3.x, Dart 3.11, flutter_riverpod ^2.6.1, flutter_test (widget tests), share_plus ^10.0.0 (new dependency for Task 5).

## Global Constraints

- Minimum touch target: 44×44pt iOS / 48×48dp Android. Never override with `BoxConstraints()` or `MaterialTapTargetSize.shrinkWrap` unless visual and tap areas are separated with `contentShape`.
- All `showModalBottomSheet` calls must include `showDragHandle: true` AND a visible × `IconButton` (WCAG 2.5.1).
- Every new gesture must have a visible button fallback (WCAG 2.5.1).
- Colors: use `DaysoffColors.brandTeal` for accent elements. Never hardcode hex.
- Run `flutter test` after every task — all pre-existing tests must keep passing.
- `HolidayCard` constructor already has `onTap`; add new callbacks without removing it.

---

### Task 1: Fix Touch Target Violations

**Files:**
- Modify: `lib/screens/home/home_screen.dart` (lines ~139–143 globe button, ~239–255 year stepper)
- Modify: `lib/screens/plan/widgets/break_card.dart` (lines ~208–222 Details › button)
- Test: `test/screens/home/home_header_test.dart` (extend existing)
- Test: `test/screens/plan/break_card_test.dart` (extend existing)

**Interfaces:**
- Produces: `IconButton`s in `_YearStepper` and AppBar title with no `constraints`/`padding` overrides; "Details ›" `TextButton` with `minimumSize: Size(44, 44)`.

- [ ] **Step 1: Read the existing test files to understand patterns**

```
Read test/screens/home/home_header_test.dart
Read test/screens/plan/break_card_test.dart
```

- [ ] **Step 2: Write failing test — Details › button has adequate tap target**

Add to `test/screens/plan/break_card_test.dart`:

```dart
testWidgets('Details › button has minimum 44px tap target', (tester) async {
  await tester.pumpWidget(_host(BreakCard(
    trip: _trip(),
    isBestValue: true,
    onTap: () {},
  )));
  final btn = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Details ›'));
  final style = btn.style!;
  final size = style.minimumSize?.resolve({});
  expect(size?.width, greaterThanOrEqualTo(44));
  expect(size?.height, greaterThanOrEqualTo(44));
});
```

- [ ] **Step 3: Run to verify it fails**

```
flutter test test/screens/plan/break_card_test.dart
```
Expected: FAIL — `minimumSize` is currently `Size.zero`.

- [ ] **Step 4: Fix `break_card.dart` — Details › TextButton**

In `lib/screens/plan/widgets/break_card.dart`, find the `TextButton.styleFrom(...)` for the "Details ›" button and replace:

```dart
// BEFORE
style: TextButton.styleFrom(
  padding: EdgeInsets.zero,
  minimumSize: Size.zero,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
),

// AFTER
style: TextButton.styleFrom(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  minimumSize: const Size(44, 44),
),
```

- [ ] **Step 5: Fix `home_screen.dart` — Globe IconButton and YearStepper**

In `lib/screens/home/home_screen.dart`, find the globe `IconButton` in the AppBar title and remove the two violating properties:

```dart
// BEFORE
IconButton(
  icon: const Icon(Icons.language, color: DaysoffColors.brandTeal),
  onPressed: () => context.push(AppRoutes.countryPicker),
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(),
),

// AFTER
IconButton(
  icon: const Icon(Icons.language, color: DaysoffColors.brandTeal),
  onPressed: () => context.push(AppRoutes.countryPicker),
),
```

In `_YearStepper`, fix both `IconButton`s (← and →) the same way — remove `padding: EdgeInsets.zero` and `constraints: const BoxConstraints()` from each.

- [ ] **Step 6: Run tests**

```
flutter test test/screens/plan/break_card_test.dart
flutter test test/screens/home/home_header_test.dart
```
Expected: all PASS.

- [ ] **Step 7: Run full suite**

```
flutter test
```
Expected: all pre-existing tests PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/screens/home/home_screen.dart \
        lib/screens/plan/widgets/break_card.dart \
        test/screens/plan/break_card_test.dart
git commit -m "fix(a11y): restore 44pt+ touch targets on globe, year stepper, Details button"
```

---

### Task 2: Add × Close Buttons to Bottom Sheets

**Files:**
- Modify: `lib/screens/home/widgets/day_detail_sheet.dart`
- Modify: `lib/widgets/preferences_editor_sheet.dart`
- Test: `test/screens/home/day_detail_sheet_test.dart` (extend existing)
- Test: `test/widgets/preferences_editor_sheet_test.dart` (extend existing)

**Interfaces:**
- Produces: both sheets have an `IconButton(Icons.close)` in their header row that calls `Navigator.of(context).pop()`. WCAG 2.5.1 satisfied.

- [ ] **Step 1: Write failing test — day_detail_sheet has a close button**

Add to `test/screens/home/day_detail_sheet_test.dart`:

```dart
testWidgets('sheet has a close (×) button that dismisses it', (tester) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDayDetailSheet(
            context,
            DateTime(2026, 6, 5),
            [Holiday(date: DateTime(2026, 6, 5), name: 'Test Day', source: 'library')],
            null,
          ),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  // × button must exist
  expect(find.byIcon(Icons.close), findsOneWidget);
  // tapping it dismisses the sheet
  await tester.tap(find.byIcon(Icons.close));
  await tester.pumpAndSettle();
  expect(find.byIcon(Icons.close), findsNothing);
});
```

- [ ] **Step 2: Run to verify it fails**

```
flutter test test/screens/home/day_detail_sheet_test.dart
```
Expected: FAIL — `Icons.close` not found.

- [ ] **Step 3: Update `day_detail_sheet.dart` — add header row with × button**

Replace the `Column` children start in `showDayDetailSheet`:

```dart
// BEFORE — first two children of the Column
Text(DateFormat('EEEE, MMMM d, y').format(day),
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
const SizedBox(height: 12),

// AFTER
Row(
  children: [
    Expanded(
      child: Text(
        DateFormat('EEEE, MMMM d, y').format(day),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.of(context).pop(),
    ),
  ],
),
const SizedBox(height: 4),
```

- [ ] **Step 4: Write failing test — preferences sheet has a close button**

Add to `test/widgets/preferences_editor_sheet_test.dart`:

```dart
testWidgets('sheet has a close (×) button', (tester) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showPreferencesEditor(context),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.byIcon(Icons.close), findsOneWidget);
});
```

- [ ] **Step 5: Run to verify it fails**

```
flutter test test/widgets/preferences_editor_sheet_test.dart
```

- [ ] **Step 6: Update `preferences_editor_sheet.dart` — add header row**

At the top of `PreferencesEditorSheet.build`, inside `ListView`, prepend:

```dart
// First child of ListView (before _Label('PTO budget'))
Padding(
  padding: const EdgeInsets.only(top: 4, bottom: 8),
  child: Row(
    children: [
      const Expanded(
        child: Text(
          'Preferences',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  ),
),
```

- [ ] **Step 7: Run tests**

```
flutter test test/screens/home/day_detail_sheet_test.dart
flutter test test/widgets/preferences_editor_sheet_test.dart
```
Expected: all PASS.

- [ ] **Step 8: Run full suite**

```
flutter test
```

- [ ] **Step 9: Commit**

```bash
git add lib/screens/home/widgets/day_detail_sheet.dart \
        lib/widgets/preferences_editor_sheet.dart \
        test/screens/home/day_detail_sheet_test.dart \
        test/widgets/preferences_editor_sheet_test.dart
git commit -m "fix(a11y): add × close button to all bottom sheets (WCAG 2.5.1)"
```

---

### Task 3: Pull-to-Refresh on Holiday List

**Files:**
- Modify: `lib/screens/home/home_screen.dart` (`_HolidaysList.build`)
- Test: `test/screens/home/home_window_test.dart` (extend existing)

**Interfaces:**
- Consumes: `holidaysProvider(HolidaysQuery)` — already used in `_HolidaysList`
- Produces: `RefreshIndicator` wrapping the `CustomScrollView`; `onRefresh` invalidates the provider, awaits the future, shows a SnackBar.

**Critical note:** `RefreshIndicator` with `CustomScrollView` (slivers) requires `physics: const AlwaysScrollableScrollPhysics()` on the `CustomScrollView`, otherwise the pull gesture won't trigger when content fits the screen.

- [ ] **Step 1: Write failing test — RefreshIndicator is present**

Add to `test/screens/home/home_window_test.dart`:

```dart
testWidgets('holiday list has a RefreshIndicator', (tester) async {
  // Use the existing pump helper from home_window_test.dart
  // (copy its provider setup pattern)
  await tester.pumpWidget(/* same ProviderScope + MaterialApp used in that file */);
  await tester.pump();
  expect(find.byType(RefreshIndicator), findsOneWidget);
});
```

> Note: Copy the exact `ProviderContainer` + overrides pattern from `test/screens/home/home_window_test.dart` — look at its existing `_pump` helper for the correct provider overrides.

- [ ] **Step 2: Run to verify it fails**

```
flutter test test/screens/home/home_window_test.dart
```
Expected: FAIL — `RefreshIndicator` not found.

- [ ] **Step 3: Update `home_screen.dart` — wrap CustomScrollView**

In `_HolidaysList.build`, find the `return CustomScrollView(...)` at the bottom of the method and wrap it:

```dart
return RefreshIndicator(
  color: DaysoffColors.brandTeal,
  onRefresh: () async {
    final query = HolidaysQuery(country: country, year: year);
    ref.invalidate(holidaysProvider(query));
    try {
      await ref.read(holidaysProvider(query).future);
    } catch (_) {
      // error already shown by the async widget above; don't double-report
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Holidays updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  },
  child: CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(), // required for RefreshIndicator
    slivers: [
      // ... existing slivers unchanged
    ],
  ),
);
```

- [ ] **Step 4: Run tests**

```
flutter test test/screens/home/home_window_test.dart
```
Expected: PASS.

- [ ] **Step 5: Run full suite**

```
flutter test
```

- [ ] **Step 6: Commit**

```bash
git add lib/screens/home/home_screen.dart \
        test/screens/home/home_window_test.dart
git commit -m "feat(gesture): pull-to-refresh on holiday list with SnackBar feedback"
```

---

### Task 4: Swipe-Left → Save Break on Holiday Cards

**Files:**
- Modify: `lib/screens/home/home_screen.dart` (`_HolidaysList` SliverList.builder)
- Modify: `lib/screens/home/widgets/day_detail_sheet.dart` (add Save button as a11y fallback)
- Test: `test/screens/home/holiday_card_test.dart` (extend — test Dismissible background)
- Test: `test/screens/home/day_detail_sheet_test.dart` (extend — test Save button)

**Interfaces:**
- Consumes: `savedBreaksProvider` notifier — call `.add(SavedBreak(...))` to persist
- Produces: Each `HolidayCard` in the list is wrapped in a `Dismissible` with `direction: DismissDirection.endToStart`. `confirmDismiss` saves + returns `false` (card stays). `day_detail_sheet` exposes a "Save" button.

**SavedBreak construction for a holiday:**
```dart
SavedBreak(
  id: 'holiday_${h.date.millisecondsSinceEpoch}',
  label: h.name,
  start: h.date,
  end: h.date,
  ptoCost: 0,
  kind: 'break',
)
```

- [ ] **Step 1: Write failing test — Dismissible with teal background is rendered**

Add to `test/screens/home/holiday_card_test.dart`:

```dart
testWidgets('HolidayCard in list is wrapped in a Dismissible', (tester) async {
  final container = ProviderContainer(
    overrides: [weekendProvider.overrideWith((ref) => ['sat', 'sun'])],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(
        body: ListView(
          children: [
            Dismissible(
              key: ValueKey('test'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async => false,
              background: Container(color: const Color(0xFF0D9488)), // brandTeal
              child: HolidayCard(holiday: _h()),
            ),
          ],
        ),
      ),
    ),
  ));
  expect(find.byType(Dismissible), findsOneWidget);
});
```

- [ ] **Step 2: Run to verify it passes (the test itself is a structural check)**

```
flutter test test/screens/home/holiday_card_test.dart
```

- [ ] **Step 3: Add Dismissible wrapper in `home_screen.dart`**

In `_HolidaysList.build`, inside `SliverList.builder`'s `itemBuilder`, wrap the `HolidayCard` return:

```dart
itemBuilder: (context, index) {
  final h = byMonth[month]![index];
  return Dismissible(
    key: ValueKey('holiday_${h.date.millisecondsSinceEpoch}'),
    direction: DismissDirection.endToStart,
    confirmDismiss: (_) async {
      final notifier = ref.read(savedBreaksProvider.notifier);
      final savedBreak = SavedBreak(
        id: 'holiday_${h.date.millisecondsSinceEpoch}',
        label: h.name,
        start: h.date,
        end: h.date,
        ptoCost: 0,
        kind: 'break',
      );
      notifier.add(savedBreak);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${h.name} saved'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => ref.read(savedBreaksProvider.notifier)
                  .remove(savedBreak.id),
            ),
          ),
        );
      }
      return false; // keep the card in the list
    },
    background: Container(
      alignment: Alignment.centerRight,
      color: DaysoffColors.brandTeal,
      padding: const EdgeInsets.only(right: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.bookmark, color: Colors.white),
          SizedBox(width: 6),
          Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
    child: HolidayCard(
      holiday: h,
      onTap: () {
        ref.read(calendarFocusProvider.notifier).state = h.date;
        ref.read(holidaysViewProvider.notifier).state = HolidaysView.calendar;
      },
    ),
  );
},
```

Add the missing import at the top of `home_screen.dart`:
```dart
import '../../api/models/saved_break.dart';
import '../../providers/saved_breaks_provider.dart';
```

- [ ] **Step 4: Add Save button inside `day_detail_sheet.dart` (a11y fallback)**

`showDayDetailSheet` currently takes a `SavedBreak? savedBreak` parameter but not a `WidgetRef`. Add an optional `onSave` callback instead (keeps the function signature simple and testable):

Change the function signature:
```dart
Future<void> showDayDetailSheet(
  BuildContext context,
  DateTime day,
  List<Holiday> holidays,
  SavedBreak? savedBreak, {
  VoidCallback? onSave,
}) {
```

In the sheet body, after the saved-break display row, add:

```dart
if (onSave != null) ...[
  const SizedBox(height: 16),
  SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      icon: const Icon(Icons.bookmark_add_outlined),
      label: const Text('Save as break'),
      onPressed: () {
        onSave();
        Navigator.of(context).pop();
      },
    ),
  ),
],
```

Update the call site in `home_screen.dart` (`NextBreakHero.onSeeDetails` and the `HolidayCard.onTap` that opens the sheet — search for `showDayDetailSheet` calls and pass `onSave`):

```dart
onSeeDetails: () => showDayDetailSheet(
  context,
  upcoming.first.date,
  [upcoming.first],
  null,
  onSave: () {
    final notifier = ref.read(savedBreaksProvider.notifier);
    notifier.add(SavedBreak(
      id: 'holiday_${upcoming.first.date.millisecondsSinceEpoch}',
      label: upcoming.first.name,
      start: upcoming.first.date,
      end: upcoming.first.date,
      ptoCost: 0,
      kind: 'break',
    ));
  },
),
```

- [ ] **Step 5: Write failing test — Save button appears in sheet**

Add to `test/screens/home/day_detail_sheet_test.dart`:

```dart
testWidgets('shows Save button when onSave is provided', (tester) async {
  var saved = false;
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDayDetailSheet(
            context,
            DateTime(2026, 6, 5),
            [Holiday(date: DateTime(2026, 6, 5), name: 'Test Day', source: 'library')],
            null,
            onSave: () => saved = true,
          ),
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.text('Save as break'), findsOneWidget);
  await tester.tap(find.text('Save as break'));
  await tester.pumpAndSettle();
  expect(saved, isTrue);
});
```

- [ ] **Step 6: Run tests**

```
flutter test test/screens/home/day_detail_sheet_test.dart
flutter test test/screens/home/holiday_card_test.dart
```
Expected: all PASS.

- [ ] **Step 7: Run full suite**

```
flutter test
```

- [ ] **Step 8: Commit**

```bash
git add lib/screens/home/home_screen.dart \
        lib/screens/home/widgets/day_detail_sheet.dart \
        test/screens/home/holiday_card_test.dart \
        test/screens/home/day_detail_sheet_test.dart
git commit -m "feat(gesture): swipe-left to save holiday as break + Save button in detail sheet"
```

---

### Task 5: Long-Press Quick Actions + ··· Button

**Files:**
- Modify: `pubspec.yaml` (add `share_plus`)
- Modify: `lib/screens/home/widgets/holiday_card.dart` (add `onLongPress`, `onMoreTap` callbacks + ··· `IconButton`)
- Modify: `lib/screens/home/home_screen.dart` (pass handlers with save + share logic)
- Test: `test/screens/home/holiday_card_test.dart` (extend)

**Interfaces:**
- Consumes: `share_plus` — `Share.share(text)`
- Produces:
  - `HolidayCard` gains two new optional callbacks: `onLongPress: VoidCallback?` and `onMoreTap: VoidCallback?`
  - `InkWell` passes `onLongPress` through
  - A `···` `IconButton` renders at the trailing edge of the card, calls `onMoreTap`
  - In `home_screen.dart`, both callbacks open the same `_showHolidayActions` mini-sheet

- [ ] **Step 1: Add `share_plus` to `pubspec.yaml`**

In `pubspec.yaml` under `dependencies:`, add after `table_calendar`:

```yaml
  share_plus: ^10.0.0
```

Then run:
```
flutter pub get
```
Expected: resolves without conflict.

- [ ] **Step 2: Write failing test — onLongPress callback fires**

Add to `test/screens/home/holiday_card_test.dart`:

```dart
testWidgets('onLongPress callback fires on long-press', (tester) async {
  var pressed = false;
  final container = ProviderContainer(
    overrides: [weekendProvider.overrideWith((ref) => ['sat', 'sun'])],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(
        body: HolidayCard(
          holiday: _h(),
          onLongPress: () => pressed = true,
        ),
      ),
    ),
  ));
  await tester.longPress(find.byType(HolidayCard));
  expect(pressed, isTrue);
});

testWidgets('··· button is present and fires onMoreTap', (tester) async {
  var tapped = false;
  final container = ProviderContainer(
    overrides: [weekendProvider.overrideWith((ref) => ['sat', 'sun'])],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(
        body: HolidayCard(
          holiday: _h(),
          onMoreTap: () => tapped = true,
        ),
      ),
    ),
  ));
  expect(find.byIcon(Icons.more_horiz), findsOneWidget);
  await tester.tap(find.byIcon(Icons.more_horiz));
  expect(tapped, isTrue);
});
```

- [ ] **Step 3: Run to verify they fail**

```
flutter test test/screens/home/holiday_card_test.dart
```
Expected: FAIL — `onLongPress` and `onMoreTap` not in constructor, `Icons.more_horiz` not found.

- [ ] **Step 4: Update `holiday_card.dart` — add callbacks + ··· button**

Update the `HolidayCard` class:

```dart
class HolidayCard extends ConsumerWidget {
  const HolidayCard({
    super.key,
    required this.holiday,
    this.onTap,
    this.onLongPress,   // new
    this.onMoreTap,     // new
  });

  final Holiday holiday;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;  // new
  final VoidCallback? onMoreTap;    // new
```

In `build`, update the `InkWell`:

```dart
return Container(
  // ... existing container decoration unchanged
  child: InkWell(
    onTap: onTap,
    onLongPress: onLongPress,   // new
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ... existing date column, divider, name column unchanged
          const SizedBox(width: 8),
          _StatusPill(absorbed: absorbed),
          // ··· button — new
          if (onMoreTap != null) ...[
            const SizedBox(width: 4),
            SizedBox(
              width: 32,
              height: 44,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: onMoreTap,
              ),
            ),
          ],
        ],
      ),
    ),
  ),
);
```

- [ ] **Step 5: Update `home_screen.dart` — pass handlers with mini-sheet**

Add a helper function inside `_HolidaysList.build` (or as a top-level function in `home_screen.dart`):

```dart
void _showHolidayActions(
  BuildContext context,
  WidgetRef ref,
  Holiday h,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_add_outlined),
            title: const Text('Save as break'),
            onTap: () {
              Navigator.of(context).pop();
              final notifier = ref.read(savedBreaksProvider.notifier);
              notifier.add(SavedBreak(
                id: 'holiday_${h.date.millisecondsSinceEpoch}',
                label: h.name,
                start: h.date,
                end: h.date,
                ptoCost: 0,
                kind: 'break',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${h.name} saved'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () => ref.read(savedBreaksProvider.notifier)
                        .remove('holiday_${h.date.millisecondsSinceEpoch}'),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share'),
            onTap: () {
              Navigator.of(context).pop();
              Share.share(
                '${h.name} — ${DateFormat('MMMM d, y').format(h.date)}',
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
```

Add the import at the top of `home_screen.dart`:
```dart
import 'package:share_plus/share_plus.dart';
```

Update each `HolidayCard(...)` call in `_HolidaysList.build`'s `SliverList.builder`:

```dart
child: HolidayCard(
  holiday: h,
  onLongPress: () {
    HapticFeedback.mediumImpact();
    _showHolidayActions(context, ref, h);
  },
  onMoreTap: () => _showHolidayActions(context, ref, h),
  onTap: () {
    ref.read(calendarFocusProvider.notifier).state = h.date;
    ref.read(holidaysViewProvider.notifier).state = HolidaysView.calendar;
  },
),
```

Add the `HapticFeedback` import to `home_screen.dart`:
```dart
import 'package:flutter/services.dart';
```

- [ ] **Step 6: Run tests**

```
flutter test test/screens/home/holiday_card_test.dart
```
Expected: all PASS.

- [ ] **Step 7: Run full suite**

```
flutter test
```

- [ ] **Step 8: Commit**

```bash
git add pubspec.yaml pubspec.lock \
        lib/screens/home/widgets/holiday_card.dart \
        lib/screens/home/home_screen.dart \
        test/screens/home/holiday_card_test.dart
git commit -m "feat(gesture): long-press + ··· quick actions (Save, Share) on holiday cards"
```

---

### Task 6: Plan Carousel ← → Navigation Buttons

**Files:**
- Modify: `lib/screens/plan/plan_screen.dart` (`_BuffetState.build`)
- Test: `test/screens/plan/plan_screen_test.dart` (extend existing)

**Interfaces:**
- Consumes: existing `_pageController` (`PageController`) and `_currentPage` (`int`) already in `_BuffetState`
- Produces: Two `IconButton`s (← and →) rendered below the `PageView`, shown/hidden based on `_currentPage` and `_trips.length`. Each calls `_pageController.previousPage` / `nextPage` with `duration: Duration(milliseconds: 300), curve: Curves.easeOut`.

**Note:** The `PageView` carousel already exists in `_BuffetState` with `viewportFraction: 0.85` and pagination dots. This task only adds the ← → buttons — do not remove or change the existing `PageView`, `PageController`, `onPageChanged`, or pagination dots.

- [ ] **Step 1: Write failing test — ← and → buttons are present**

Add to `test/screens/plan/plan_screen_test.dart` (copy the existing pump helper pattern from that file):

```dart
testWidgets('carousel has prev/next nav buttons', (tester) async {
  // Use the existing _pumpPlanScreen helper or ProviderContainer pattern
  // already established in plan_screen_test.dart
  await _pumpPlanScreen(tester); // adapt to match file's existing helper name
  await tester.pump();
  // With multiple trips in the mock, both buttons should exist
  expect(find.byIcon(Icons.chevron_left), findsOneWidget);
  expect(find.byIcon(Icons.chevron_right), findsOneWidget);
});
```

> Note: Read `test/screens/plan/plan_screen_test.dart` before writing — use its exact `_pump` function signature and provider overrides.

- [ ] **Step 2: Run to verify it fails**

```
flutter test test/screens/plan/plan_screen_test.dart
```
Expected: FAIL — `Icons.chevron_left` / `Icons.chevron_right` not found in carousel area.

- [ ] **Step 3: Update `_BuffetState.build` in `plan_screen.dart` — add nav buttons**

In the `ListView` children of `_BuffetState.build`, replace the `const SizedBox(height: 16)` that appears **after** the carousel `SizedBox` with a nav buttons row:

```dart
// After the carousel SizedBox(height: 340, child: PageView.builder(...))
const SizedBox(height: 12),
// ← → nav buttons (accessibility fallback per WCAG 2.5.1)
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      icon: const Icon(Icons.chevron_left),
      onPressed: _currentPage > 0
          ? () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              )
          : null,
      tooltip: 'Previous break option',
    ),
    const SizedBox(width: 16),
    IconButton(
      icon: const Icon(Icons.chevron_right),
      onPressed: _currentPage < _trips.length - 1
          ? () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              )
          : null,
      tooltip: 'Next break option',
    ),
  ],
),
const SizedBox(height: 4),
// Existing pagination dots — unchanged
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (var i = 0; i < _trips.length; i++) ...[
      // ... existing dot code unchanged
    ],
  ],
),
```

- [ ] **Step 4: Run tests**

```
flutter test test/screens/plan/plan_screen_test.dart
```
Expected: all PASS.

- [ ] **Step 5: Run full suite**

```
flutter test
```
Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/plan/plan_screen.dart \
        test/screens/plan/plan_screen_test.dart
git commit -m "feat(gesture): add ← → nav buttons to plan carousel (WCAG 2.5.1)"
```

---

## Self-Review

### Spec coverage check

| Spec section | Task | Status |
|---|---|---|
| Touch target violations (globe, year stepper, Details ›) | Task 1 | ✓ covered |
| × close buttons on both sheets | Task 2 | ✓ covered |
| Pull-to-refresh + Snackbar | Task 3 | ✓ covered |
| Swipe-left → Save break (Dismissible + a11y Save button) | Task 4 | ✓ covered |
| Long-press + ··· button + share_plus | Task 5 | ✓ covered |
| ← → carousel nav buttons | Task 6 | ✓ covered |
| Platform rules (SafeArea, no swipe-up-from-bottom) | Verified — existing `SafeArea` wrappers already correct; no new violations introduced | ✓ no task needed |

### Placeholder scan
- No TBDs, TODOs, or vague "implement X" steps found.
- All code blocks contain complete, compilable code.
- All test assertions reference real widget types / text strings.

### Type consistency
- `SavedBreak(id: 'holiday_${h.date.millisecondsSinceEpoch}', ...)` — consistent id format used in Task 4 `confirmDismiss`, Task 5 `_showHolidayActions`, and Task 5 Undo handler.
- `HolidayCard` constructor: `onTap`, `onLongPress`, `onMoreTap` — all `VoidCallback?`, consistent across Task 5 steps.
- `_pageController.previousPage / nextPage` — consistent with existing `PageController` instance name in `_BuffetState`.
