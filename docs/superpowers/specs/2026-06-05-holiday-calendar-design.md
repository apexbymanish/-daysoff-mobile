# Holiday Calendar View — Design

**Date:** 2026-06-05
**Status:** Approved (design, Approach A)

## Goal

Add a month-grid **calendar** view to the Holidays tab, toggleable with the existing timeline list.
The grid marks public holidays, news/temp holidays, weekend (days-off) columns, and saved-break date
ranges, and shows a detail sheet when a day is tapped.

## Problem

The Holidays tab renders only a month-grouped timeline list (`home_screen.dart`). There is no calendar
grid anywhere in the app, no calendar package, and none in git history. Users expect to *see* their
year at a glance on a calendar.

## Approach

**A — `table_calendar` package + a list/calendar toggle.** A calendar grid is the textbook case for a
well-tested dependency (week alignment, month math, swipe, leap years). `table_calendar` (^3.x,
Dart-3 compatible) provides `eventLoader`, `calendarBuilders`, `weekendDays`, and `onDaySelected` —
everything the markers need. We style it on-brand with `DaysoffColors`. (A zero-dep custom grid was
considered and rejected for code volume / date edge-case risk.)

## State

- `HolidaysView` enum `{list, calendar}`.
- `holidaysViewProvider` = `StateProvider<HolidaysView>` defaulting to **`HolidaysView.list`**.
  Session-only (NOT persisted) — keeping the default `list` means every existing Home test, which
  asserts the timeline list, passes unchanged; the calendar is opt-in via the toggle. (YAGNI: no
  persistence of the view choice.)

## Data (all already in the app — no new API calls)

- **Holidays:** `holidaysProvider(HolidaysQuery(country, year))` → `HolidaysResponse.holidays`
  (`Holiday{date: DateTime, name: String, source: String}`). Built into a
  `Map<DateTime, List<Holiday>>` keyed by date-only (`DateTime(y,m,d)`), for the `eventLoader`.
  `source == 'news'` flags a news/temp holiday (distinct marker).
- **Saved breaks:** `savedBreaksProvider` → `List<SavedBreak>` (`{start: DateTime, end: DateTime,
  label, kind, ...}`). A day is "in a saved break" if `start <= day <= end` (date-only compare).
- **Weekend:** `weekendProvider` → `List<String>` (e.g. `['sat','sun']`). Map each key to its
  `DateTime.weekday` int (`mon`→1 … `sun`→7) to feed `TableCalendar.weekendDays` and to mute those
  columns.

## Components

### `lib/providers/holidays_view_provider.dart` (new)
`enum HolidaysView { list, calendar }` + `final holidaysViewProvider = StateProvider<HolidaysView>((ref) => HolidaysView.list);`

### `lib/screens/home/widgets/holiday_calendar_view.dart` (new)
A `ConsumerWidget` rendering `TableCalendar` for the selected year:
- `firstDay: DateTime(year, 1, 1)`, `lastDay: DateTime(year, 12, 31)`, `focusedDay` kept within range
  (held in local `StatefulWidget` state seeded from `DateTime(year, 1, 1)` or today if in-year).
- `calendarFormat: CalendarFormat.month`, `headerStyle` with `formatButtonVisible: false`.
- `weekendDays:` the mapped ints from `weekendProvider`.
- `eventLoader:` returns the holiday list for a normalized day.
- `calendarBuilders`:
  - `markerBuilder`: confirmed holiday → small `DaysoffColors.brandTeal` dot; if any holiday that day
    has `source == 'news'` → a `DaysoffColors.sand` marker (distinct shape/color).
  - `defaultBuilder` / `todayBuilder`: if the day falls in a saved-break range, wrap the day number in
    a `DaysoffColors.sage`-tinted rounded cell (range fill).
- `onDaySelected: (selected, focused)` → `showDayDetailSheet(context, day, holidaysForDay, savedBreakForDay)`.

Because the year stepper lives in the app bar (shared), when `selectedYearProvider` changes the widget
rebuilds with new `firstDay/lastDay/focusedDay` for that year.

### `lib/screens/home/widgets/day_detail_sheet.dart` (new)
`Future<void> showDayDetailSheet(BuildContext, DateTime day, List<Holiday> holidays, SavedBreak? savedBreak)`
→ `showModalBottomSheet` showing the formatted date, each holiday name (with a "temporary
(news-detected)" tag when `source=='news'`), and the saved break label if present. Empty-ish days show
"Nothing on this day."

### `lib/screens/home/home_screen.dart` (modify)
- Watch `holidaysViewProvider`.
- Add a compact **list/calendar toggle** to the `SliverAppBar` `actions` (a `SegmentedButton<HolidaysView>`
  with list/calendar icons, or two `IconButton`s) before the existing bookmark `IconButton`.
- Keep the existing `CustomScrollView` + `SliverAppBar` (so the country chip, year stepper, toggle,
  and bookmark stay shared). In the `data:` branch, branch the *body slivers* on the view: when
  `calendar`, emit a single `SliverToBoxAdapter(child: HolidayCalendarView(...))`; when `list`, emit
  the existing `DaysUntilBanner` + month-section slivers exactly as today. (`DaysUntilBanner` shows in
  list view only.)

## Testing

- **`holidays_view_provider_test.dart`** (new): default is `HolidaysView.list`.
- **`holiday_calendar_view_test.dart`** (new): given a `holidaysProvider` override returning a known
  holiday (e.g. KR 2026 New Year Jan 1), the calendar renders that month and a marker is present;
  tapping a holiday day opens the detail sheet showing the holiday name; a `weekendProvider` of
  `['sat','sun']` mutes Sat/Sun; a `savedBreaksProvider` override with a range highlights those days.
  Use a fake `ApiClient` + provider overrides (existing test idiom — no mocktail).
- **`home_screen` toggle test**: tapping the calendar toggle switches from the list to
  `HolidayCalendarView`; tapping list switches back. Default view is list (existing Home tests
  unaffected).
- **Regression:** full `flutter test` green, `flutter analyze` clean.

## Out of scope

Writing events to the device calendar; reminders/notifications (device-dependent); editing/adding
holidays; week/2-week calendar formats; persisting the view toggle.

## File summary

```
pubspec.yaml                                          MODIFY: + table_calendar (flutter pub add)
lib/providers/holidays_view_provider.dart             NEW: HolidaysView enum + provider
lib/screens/home/widgets/holiday_calendar_view.dart   NEW: TableCalendar + markers
lib/screens/home/widgets/day_detail_sheet.dart        NEW: showDayDetailSheet
lib/screens/home/home_screen.dart                     MODIFY: toggle + conditional view
test/providers/holidays_view_provider_test.dart       NEW
test/screens/home/holiday_calendar_view_test.dart     NEW
test/screens/home/home_toggle_test.dart               NEW
```
