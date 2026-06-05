# Upcoming Holidays + Tap-to-Calendar Plan

> REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** Holidays list shows today→(longest planned break end, capped at year-end); tapping a holiday opens the calendar focused/selected on it, with the header toggle to go back.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/upcoming-holidays`**. Baseline 98 tests, analyzer clean. Spec: `docs/superpowers/specs/2026-06-05-upcoming-holidays-design.md`.
Context: `_HolidaysList` (in `home_screen.dart`) is a `ConsumerWidget` receiving `holidays`, `country`, `year`; it computes `upcoming` + `byMonth` (currently from ALL holidays) and watches `holidaysViewProvider`. `PlanQuery`/`planProvider` (lib/providers/plan_provider.dart). Prefs providers: `ptoBudgetProvider`, `breakLengthProvider` (BreakLengthRange{min,max}), `weekendProvider`. `HolidayCalendarView` is a `ConsumerStatefulWidget` (`_focused`, `_selected`, `_defaultSelected()`). `holidaysViewProvider` + `HolidaysView{list,calendar}` in `lib/providers/holidays_view_provider.dart`.

## Task 1: calendarFocusProvider + HolidayCard onTap
**Files:** `lib/providers/holidays_view_provider.dart` (+ provider); `lib/screens/home/widgets/holiday_card.dart` (+ onTap); test.
- Add to `holidays_view_provider.dart`: `final calendarFocusProvider = StateProvider<DateTime?>((ref) => null);`
- `HolidayCard`: add `final VoidCallback? onTap;` to the constructor (`HolidayCard({super.key, required this.holiday, this.onTap})`); wrap the card's outer container in `InkWell(onTap: onTap, borderRadius: ..., child: ...)` (keep the existing visuals). When `onTap` is null it's inert.
- Test (`test/screens/home/holiday_card_test.dart`, add a case): tapping a `HolidayCard` with an `onTap` fires the callback. Keep existing card tests passing (onTap is optional/additive).
- Run + commit.

## Task 2: list window (today → longest-break cap)
**Files:** `lib/screens/home/home_screen.dart` (`_HolidaysList`); test.
- In `_HolidaysList.build`, build the plan query from prefs and watch it:
```dart
final budget = ref.watch(ptoBudgetProvider);
final lenRange = ref.watch(breakLengthProvider);
final weekend = ref.watch(weekendProvider);
final planAsync = ref.watch(planProvider(PlanQuery(
  country: country, year: year, budget: budget,
  minLength: lenRange.min, maxLength: lenRange.max, workweek: weekend)));
final now = DateTime.now();
final lower = DateTime(now.year, now.month, now.day);
DateTime cap = DateTime(year, 12, 31);
planAsync.whenData((resp) {
  PlanTrip? longest;
  for (final list in resp.resultsByLength.values) {
    for (final t in list) {
      if (longest == null || t.breakLength > longest.breakLength) longest = t;
    }
  }
  if (longest != null) cap = longest.breakEnd;
});
```
  (import `../../api/models/plan_trip.dart`, `../../providers/plan_provider.dart`, `../../providers/preferences_provider.dart` if not already.)
- Filter the list (used for `byMonth`/`months`) to the window:
```dart
final windowed = holidays.where((h) =>
    !h.date.isBefore(lower) && !h.date.isAfter(cap)).toList();
```
  Build `byMonth`/`months` from `windowed` (NOT all `holidays`). Keep `upcoming` (for the hero) computed from all `holidays` as today.
- Empty state when `windowed` is empty: "No upcoming holidays." (only in the LIST branch; the calendar branch is unchanged and still uses the full `holidays`).
- Test (`test/screens/home/home_window_test.dart`, new): with a fake `apiClientProvider` returning holidays at a past date, an in-window date, and a date after the longest break, plus a plan whose longest break ends mid-window → the list shows only the in-window holiday(s); past + post-cap hidden. (If wiring a plan fake is heavy, at minimum assert past holidays are hidden and a near-future one shows, with the plan erroring → cap = year end.)
- Run + commit.

## Task 3: calendar seeds from focus + wire tap + back
**Files:** `lib/screens/home/widgets/holiday_calendar_view.dart`; `lib/screens/home/home_screen.dart`; test.
- `HolidayCalendarView.initState`: after the existing defaults, read the focus:
```dart
final focus = ref.read(calendarFocusProvider);
if (focus != null && !focus.isBefore(DateTime(widget.year,1,1)) && !focus.isAfter(DateTime(widget.year,12,31))) {
  _focused = focus; _selected = focus;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(calendarFocusProvider.notifier).state = null;
  });
}
```
  (ConsumerState can `ref.read` in initState.)
- In `_HolidaysList`, pass `onTap` to each `HolidayCard`:
```dart
HolidayCard(
  holiday: h,
  onTap: () {
    ref.read(calendarFocusProvider.notifier).state = h.date;
    ref.read(holidaysViewProvider.notifier).state = HolidaysView.calendar;
  },
)
```
- Back: in the header toggle's "list" button (`toggle-list`) onPressed, also clear focus: `ref.read(calendarFocusProvider.notifier).state = null;` before setting view to list.
- Test (`test/screens/home/tap_to_calendar_test.dart`, new): with a fake holidays response (one upcoming holiday), tapping its `HolidayCard` flips to the calendar view (`find.byKey(const Key('holiday-calendar'))` appears) and the `DaySummaryCard` shows that holiday's name; tapping the `toggle-list` header button returns to the list. Use the Home test harness (fake `apiClientProvider`, future-safe pumps).
- Full gate: `flutter test` + `flutter analyze` clean. Existing Home/hero/toggle/calendar tests must still pass.
- Run + commit.

## Self-review
- Coverage: upcoming window capped at longest break (T2); calendarFocusProvider + card onTap (T1); calendar seeds from focus + tap wiring + back-clears-focus (T3).
- Types: `calendarFocusProvider: StateProvider<DateTime?>`; `HolidayCard({holiday, onTap?})`; PlanQuery from prefs; `HolidaysView` toggle reused.
- The calendar view still shows full months (only the LIST is windowed).

## Done when
`flutter test && flutter analyze` clean; the Holidays list shows only today→longest-break holidays; tapping one opens the calendar on that day (summary shown); the header toggle returns to the list.
