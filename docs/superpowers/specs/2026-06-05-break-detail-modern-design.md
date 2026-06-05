# Break Detail Modern (6.2) — Design

**Date:** 2026-06-05 · **Status:** Approved (design)

## Goal
Redesign the break detail screen toward Stitch "6.2 · Break detail (modern)": a **scenery hero**, a
**value callout**, and a **day-by-day breakdown** with color-coded type tags and native holiday names.

## Decisions
- Reuse the rotating scenery assets (`sceneryForDate`) for the hero — same destinations as the home hero.
- Native holiday names come from `holidaysProvider` (the `name_local` field from sub-project A), looked
  up by date **client-side**, degrading gracefully (no native name while loading/error).
- Preserve the existing **Save this break** action and the texts/keys the current test relies on
  (`'5-day break'`, `textContaining('… PTO')`, day rows keyed `break-day-row`, `'Save this break'`).

## Layout (rewrite `lib/screens/plan/break_detail_screen.dart`)
`CustomScrollView`:
- **`SliverAppBar`** (expandedHeight ~200, pinned): `FlexibleSpaceBar` title "Break Details" over a
  `sceneryForDate(trip.breakStart)` `Image.asset` (cover, errorBuilder → teal fill) + a top→bottom dark
  scrim. White foreground.
- **Body `SliverList`**:
  - `"{breakLength}-day break"` (kept) + `"{Mon d} – {Mon d} · anchored on {anchor}"`.
  - **Value callout** (sage): ✦ + `"{ptoCost} PTO day(s) → {breakLength} days off"` (contains "… PTO").
  - `DAY-BY-DAY` overline.
  - One `_DayRow` per day (`key: ValueKey('break-day-row')`): left = date (`EEE MMM d`) with the native
    holiday name beneath when the day is the anchoring holiday and a localized name exists; right = a
    colored **type tag** — `PTO` (sage) / `Weekend` (neutral) / the holiday name (peach).
  - **Save this break** `FilledButton.icon` — unchanged logic (adds the same `SavedBreak`, shows the
    same SnackBar).

## Data
- `country = selectedCountryProvider`, `year = selectedYearProvider`;
  `ref.watch(holidaysProvider(HolidaysQuery(country, year)))` → `.maybeWhen(data: build a
  Map<date-only, Holiday>, orElse: {})`. For a holiday-kind day, look up the `Holiday` by date for its
  `name`/`nameLocal`. `classifyBreakDay(day, trip.ptoDates)` gives the kind.

## Testing
- **Existing 2 tests stay green** (rewrite preserves their texts/keys): day-rows count = 5, `'5-day
  break'`, `textContaining('1 PTO')`, Save adds to `savedBreaksProvider`.
- **New:** with an `apiClientProvider` fake returning a Chuseok holiday on 2026-09-24 (`name:'Chuseok',
  name_local:'추석'`), the holiday day row shows `추석`. Type tags `PTO` and `Weekend` render. The
  scenery `SliverAppBar` is present.
- Regression: full `flutter test` + `flutter analyze` clean.

## Out of scope
Backend native anchor names on `/v1/plan` (client lookup used instead); share button; the bottom-nav
restyle from the mockup.

## Files
```
lib/screens/plan/break_detail_screen.dart   REWRITE (hero + callout + day-by-day + native names)
test/screens/plan/break_detail_test.dart     MODIFY (keep 2; add native-name + tags + hero cases)
```
