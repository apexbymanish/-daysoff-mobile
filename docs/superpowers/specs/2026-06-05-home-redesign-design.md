# Home 6.1 Redesign — Design (Sub-project B)

**Date:** 2026-06-05
**Status:** Approved (design)

## Goal

Bring the Holidays tab closer to the Stitch "6.1 · Home timeline" design: a **scenery next-break hero**,
**native-language holiday names** (using the `name_local` field sub-project A added), and **weekend-aware
FREE/ABSORBED chips**.

## Decisions (from brainstorming)

- **Hero images:** 4 user-provided destination photos, already optimized into `assets/scenery/`
  (`kyoto.jpg`, `alps.jpg`, `cinque_terre.jpg`, `marrakech.jpg`). The hero shows one **aspirational,
  rotating** image picked deterministically per next-break date — independent of work country (so KR/NP
  users get a photo too). A teal→sage gradient is the fallback if an asset is missing.
- **Keep** the 4-tab IA and the functional country chip + year stepper (6.1's bare wordmark would remove
  country switching).
- Calendar view (built earlier) is untouched; this changes only the **list** view.

## Components

### 1. `Holiday` model — `lib/api/models/holiday.dart`
Add `@JsonKey(name: 'name_local') String? nameLocal` to the freezed `Holiday`. Run build_runner.
Backward compatible: API returns `name_local` (Korean for KR, null for English/untranslated).

### 2. Status helper — `lib/core/holiday_status.dart` (new)
```
const kWeekdayInts = {'mon':1,...,'sun':7};
bool isAbsorbed(DateTime date, List<String> weekend)  // date.weekday ∈ weekend → absorbed
```
A holiday on a working day is FREE; on a weekend day it's ABSORBED (already a day off).

### 3. `HolidayCard` — `lib/screens/home/widgets/holiday_card.dart`
- Becomes a `ConsumerWidget`; the status badge reads `weekendProvider` and uses `isAbsorbed(...)`
  instead of the hardcoded Sat/Sun check.
- Adds a **native-name** line under the English name when `holiday.nameLocal` is non-null and differs
  from `holiday.name` (e.g. *설날*), in `label-caps`/muted style.

### 4. Scenery picker — `lib/screens/home/widgets/scenery.dart` (new)
```
const kScenery = ['assets/scenery/kyoto.jpg','.../alps.jpg','.../cinque_terre.jpg','.../marrakech.jpg'];
String sceneryForDate(DateTime d) => kScenery[(d.month * 31 + d.day) % kScenery.length];
```
Deterministic per date → stable per next-break, varies across breaks.

### 5. `NextBreakHero` — `lib/screens/home/widgets/next_break_hero.dart` (new)
`NextBreakHero({required Holiday next, VoidCallback? onSeeDetails})`:
- Full-width rounded card (height ~180) with the scenery image (`Image.asset`, `BoxFit.cover`,
  `errorBuilder` → teal→sage gradient) under a dark bottom scrim for text legibility.
- Overlay: label "NEXT BREAK IN", big day count (`next.date - today`), holiday name (+ native name if
  present), formatted date, and a "See details" `TextButton` → `onSeeDetails`.

### 6. `home_screen.dart` (modify)
- In the **list** branch, replace `DaysUntilBanner(next: upcoming.first)` with
  `NextBreakHero(next: upcoming.first, onSeeDetails: () => showDayDetailSheet(context, upcoming.first.date, [upcoming.first], null))`.
- `DaysUntilBanner` is removed (its file + its only usage). The calendar branch is unchanged.

### 7. `day_detail_sheet.dart` (modify)
- Under each holiday's name, show its `nameLocal` (when present and different) — consistency with the
  rows. (Status chip in the sheet is out of scope; the sheet already conveys the date.)

## Testing

- **Holiday model:** `Holiday.fromJson` parses `name_local` → `nameLocal`; absent → null.
- **`holiday_status`:** `isAbsorbed(Sat, ['sat','sun'])` true; `isAbsorbed(Fri, ['sat','sun'])` false;
  `isAbsorbed(Fri, ['fri'])` true.
- **`HolidayCard`:** shows the native name when present; status badge flips with a `weekendProvider`
  override (Fri holiday → FREE with default weekend, ABSORBED when weekend includes 'fri').
- **`scenery`:** `sceneryForDate` returns a path from `kScenery`; deterministic for a fixed date.
- **`NextBreakHero`:** renders the day count + holiday name; "See details" triggers the callback.
- **`home_screen`:** list view shows `NextBreakHero` (not `DaysUntilBanner`); calendar view still works.
- **Regression:** full `flutter test` green, `flutter analyze` clean. Existing Home tests that asserted
  the banner text must be updated to the hero (only those).

## Out of scope

Device-calendar/reminders; the 6.x "modern"/destinations screens; per-country hero mapping (rotating
instead); animating the hero.

## File summary
```
assets/scenery/{kyoto,alps,cinque_terre,marrakech}.jpg   NEW (already optimized)
pubspec.yaml                                             MODIFY: register assets/scenery/
lib/api/models/holiday.dart (+ generated)                MODIFY: nameLocal
lib/core/holiday_status.dart                             NEW: isAbsorbed + weekday map
lib/screens/home/widgets/scenery.dart                    NEW: kScenery + sceneryForDate
lib/screens/home/widgets/next_break_hero.dart            NEW: scenery hero
lib/screens/home/widgets/holiday_card.dart               MODIFY: native name + weekend-aware status
lib/screens/home/widgets/days_until_banner.dart          DELETE (replaced by hero)
lib/screens/home/widgets/day_detail_sheet.dart           MODIFY: native name line
lib/screens/home/home_screen.dart                        MODIFY: use NextBreakHero in list view
tests: holiday model, holiday_status, holiday_card, scenery, next_break_hero, home list   ADD/MODIFY
```
