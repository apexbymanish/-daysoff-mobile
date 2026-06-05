# Plan Modern (6.6) — Design

**Date:** 2026-06-05 · **Status:** Approved (design)

## Goal
Bring the Plan screen toward Stitch "6.6 · Plan length buffet (modern)": a **filter-chip row** for the
plan prefs, a **"Best value" callout**, and **day-type pill labels** on the break cards.

## Decisions
- Keep the existing data/providers (country, year, budget, break length, weekend). No new API.
- **Balance bar** from the mockup is OUT (it needs PTO-usage tracking the app doesn't have).
- The "Adjust" app-bar button stays (the chips are an additional, more visible entry point).

## Components

### 1. `lib/core/plan_value.dart` (new)
`PlanTrip? bestValueTrip(List<PlanTrip> trips)` — the trip with the best days-off-per-PTO ratio:
maximize `breakLength / (ptoCost == 0 ? 0.5 : ptoCost)` (so 0-PTO breaks rank highest); tie-break by
fewer `ptoCost`, then longer `breakLength`. Returns null for an empty list. Pure + unit-tested.

### 2. `lib/screens/plan/widgets/plan_filter_chips.dart` (new)
`PlanFilterChips` (ConsumerWidget) — a `Wrap` of `ActionChip`s reflecting current prefs:
- **country** (`countryFlag + code`) → `context.push(AppRoutes.countryPicker)`
- **year** (`$year`) → a small year stepper `AlertDialog` (− / value / +) writing `selectedYearProvider`
- **weekend** (`"Sat, Sun off"` via `formatWeekend`) → `showPreferencesEditor(context)`
- **budget** (`"$budget days"`) → `showPreferencesEditor(context)`

### 3. Day-type pills — upgrade `lib/screens/plan/widgets/day_ribbon.dart`
Replace the thin color bars with a row of small rounded **letter pills**, one per break day:
`classifyBreakDay` → `P` (PTO, sage) / `W` (weekend, teal) / `H` (holiday, peach). Keeps the same
class name `DayRibbon(trip:)` (only used by `break_card.dart`), so its call site is unchanged.

### 4. `lib/screens/plan/widgets/best_value_banner.dart` (new)
`BestValueBanner(trip:)` — a sage-tinted rounded banner: a ✦ icon + "Best value found" +
"{breakLength}-day break for {ptoCost == 0 ? 'no' : ptoCost} PTO day(s)".

### 5. `lib/screens/plan/plan_screen.dart` (modify `_Buffet`)
Replace the plain "KR · 2026 · budget…" subtitle with `PlanFilterChips`. Above the break cards, when
`bestValueTrip(trips)` is non-null, show `BestValueBanner(trip: best)`. The card list is unchanged
(each `BreakCard` now renders pill labels via the upgraded `DayRibbon`).

## Testing
- `plan_value`: best-value pick for a known set (0-PTO 3-day beats 2-PTO 5-day; tie-break by fewer PTO);
  empty → null.
- `PlanFilterChips`: renders country/year/weekend/budget chips; tapping budget opens the editor; tapping
  the year chip opens the stepper dialog and `+` bumps `selectedYearProvider`.
- `DayRibbon`: renders one pill per day with the right letters for a known trip (e.g. PTO + weekend).
- `BestValueBanner`: shows the length + PTO text.
- `plan_screen`: list view shows `PlanFilterChips` + a `BestValueBanner` (fake plan provider).
- Regression: full `flutter test` + `flutter analyze` clean. The existing plan screen test (overrides
  `planProvider`) still passes; update it only if it asserted the old subtitle text.

## Out of scope
Balance bar; the carousel/horizontal-paging layout (keep the vertical list); merging Sandwich (that's 6.7).

## Files
```
lib/core/plan_value.dart                              NEW
lib/screens/plan/widgets/plan_filter_chips.dart       NEW
lib/screens/plan/widgets/best_value_banner.dart       NEW
lib/screens/plan/widgets/day_ribbon.dart              MODIFY (color bars → letter pills)
lib/screens/plan/plan_screen.dart                     MODIFY (_Buffet: chips + best-value)
test/core/plan_value_test.dart                        NEW
test/screens/plan/plan_filter_chips_test.dart         NEW
test/screens/plan/day_ribbon_test.dart                NEW
test/screens/plan/best_value_banner_test.dart         NEW
```
