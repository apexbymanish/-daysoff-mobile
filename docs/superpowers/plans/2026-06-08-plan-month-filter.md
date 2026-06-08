# Plan Month Filter (buffet + sandwich)

> REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** A horizontal month strip on the Plan screen (`All · Jan … Dec`) that filters BOTH the Length-buffet options (by break start month) and the Sandwich days (by PTO-date month). Client-side; default All.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/plan-month-filter`**. Baseline 106 tests, analyzer clean. Plan screen structure: `PlanScreen` builds a Column → `PlanFilterChips` → `_ViewToggle` (planViewProvider) → `_BuffetView` (watches `planProvider`, `data: (resp) => _Buffet(response: resp)`) or `_SandwichView` (watches `sandwichesProvider`, renders `SandwichCard`s + `EfficiencyInsight`). `_Buffet` (StatefulWidget) computes `_bestPerLength(response)` (longest-first top-8). `PlanTrip{breakStart, breakLength, ptoCost, ...}`, `SandwichRecord{ptoDate, ...}`. `planViewProvider`/`PlanView` in `lib/providers/plan_view_provider.dart`. Colors `DaysoffColors`; `labelCaps()` in `lib/theme/typography.dart`; `intl` available.

## Task 1: planMonthProvider + month strip
**Files:** `lib/providers/plan_view_provider.dart` (+ provider); new `lib/screens/plan/widgets/month_strip.dart`; test.
- Add `final planMonthProvider = StateProvider<int?>((ref) => null);` (null = All; 1..12 otherwise).
- `MonthStrip` (ConsumerWidget): a horizontally-scrollable `Row`/`ListView` of chips — "All" then Jan…Dec (`DateFormat('MMM').format(DateTime(2000, m))`). Selected chip = filled `brandTeal` (white text); others = `outlineVariant`-bordered white. Labels via `labelCaps`. Tapping sets `planMonthProvider` (All → null). Key the chips e.g. `Key('month-all')`, `Key('month-3')` for testing.
- Test (`test/screens/plan/month_strip_test.dart`): renders "All" + month chips; tapping "Mar" sets `planMonthProvider == 3`; tapping "All" resets to null. (UncontrolledProviderScope + container.)
- Run + commit.

## Task 2: apply the filter to both views
**Files:** `lib/screens/plan/plan_screen.dart`; test.
- Insert `const MonthStrip()` in `PlanScreen.build` between the `_ViewToggle` and the view content (visible for both views).
- **Buffet:** make `_BuffetView` read `final month = ref.watch(planMonthProvider);` and pass it to `_Buffet(response: resp, month: month)`. In `_Buffet`, add `final int? month;`; in `_bestPerLength` (now an instance method or keep static taking month), filter trips to `month == null || t.breakStart.month == month` BEFORE the existing longest-first sort + `.take(8)`. If the filtered result is empty, show an empty state ("No break options in {monthName}." or, for All, the existing "No breaks fit this budget…").
- **Sandwich:** in `_SandwichView`, read `planMonthProvider`; filter `resp.sandwiches` to `month == null || s.ptoDate.month == month` before rendering the `SandwichCard`s + `EfficiencyInsight(records: filtered)`. Empty filtered → "No sandwich days in {monthName}." (keep the existing all-empty message when month == null).
- `monthName(m) = DateFormat('MMMM').format(DateTime(2000, m))`.
- Test (`test/screens/plan/plan_month_filter_test.dart`): with a fake `apiClientProvider` returning plan trips in different months + sandwiches in different months, selecting a month shows only that month's options/sandwiches; "All" shows everything; a month with none shows the empty message. Use the Home/plan test harness (fake ApiClient overriding getPlan + getSandwiches; future-safe pumps).
- Full gate: `flutter test` + `flutter analyze` clean. Keep existing plan tests green (default All = current behavior; if a test asserted a specific card count it still holds under All).
- Run + commit.

## Out of scope
Server-side month param (client filter); filtering the Holidays tab by month (this is Plan only); persisting the month choice.

## Done when
`flutter test && flutter analyze` clean; the Plan screen shows an All/Jan…Dec month strip that filters both the break-options carousel and the sandwich list to the chosen month, with per-view empty states, default All.
