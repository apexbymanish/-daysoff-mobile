# Upcoming Holidays + Tap-to-Calendar — Design

**Date:** 2026-06-05 · **Status:** Approved (design)

## Goal
On the Holidays tab: (1) the **list** view shows only **upcoming** holidays — from today up to the end
of the **longest planned break** (capped at year-end) — and (2) **tapping a holiday opens the calendar**
focused on that date, with the header toggle to go back.

## Part 1 — Upcoming-only list, capped at the longest planned break
The list view (`_HolidaysList` in `home_screen.dart`) currently groups ALL holidays for the year.
Change it to a date-bounded window:
- **Lower bound:** today (`DateTime(now.year, now.month, now.day)`). (For a future selected year, all
  its holidays are after today → all show; for a past year → none.)
- **Upper bound (cap):** the **end date of the longest planned break** for the current prefs, else
  Dec 31 of the selected year. Compute by watching `planProvider(PlanQuery(country, year, budget,
  minLength: range.min, maxLength: range.max, workweek: weekend))` (same query the Plan screen builds)
  and, on `data`, taking the `breakEnd` of the trip with the largest `breakLength` across
  `resultsByLength`. On loading/error, cap = `DateTime(year, 12, 31)`.
- The filtered, month-grouped list = `holidays.where((h) => !h.date.isBefore(lower) && !h.date.isAfter(cap))`.
- Empty state: "No upcoming holidays." The hero (`NextBreakHero`) still uses `upcoming.first` as today.
- The **calendar** view is unchanged (it renders full months for the year).

## Part 2 — Tap a holiday → calendar (focused + selected), with back
- New `calendarFocusProvider = StateProvider<DateTime?>((ref) => null)` (lib/providers/holidays_view_provider.dart, alongside `holidaysViewProvider`).
- `HolidayCard` gains an optional `VoidCallback? onTap` (wrap its content in an `InkWell`).
- In `_HolidaysList`, each `HolidayCard.onTap` → `ref.read(calendarFocusProvider.notifier).state = h.date;`
  then `ref.read(holidaysViewProvider.notifier).state = HolidaysView.calendar;`.
- `HolidayCalendarView` (ConsumerStatefulWidget): in `initState`, read `calendarFocusProvider`; if
  non-null, seed `_focused` and `_selected` to it (so the calendar opens on that month with the day
  selected and its summary card shown), then clear the provider in a post-frame callback
  (`ref.read(calendarFocusProvider.notifier).state = null`) so a later manual open uses the default.
- **Back:** the existing list/calendar header toggle returns to the list (no new control needed). When
  toggling back to list, also clear `calendarFocusProvider` (defensive).

## Testing
- **List filter:** with a `holidaysProvider` override (holidays incl. a past date, an in-window date,
  and one after the cap) + a `planProvider`/`apiClientProvider` fake whose longest break ends mid-year,
  the list shows only today..cap holidays (past hidden; post-cap hidden). With no plan (error), cap =
  Dec 31 (all upcoming shown).
- **Tap → calendar:** tapping a holiday card sets `calendarFocusProvider` + flips to calendar; the
  calendar opens with that day selected (the `DaySummaryCard` shows that holiday). Use the Home test
  harness (fake `apiClientProvider`).
- **Back:** toggling the header control returns to the list.
- Regression: full `flutter test` + `flutter analyze` clean; existing Home/hero/toggle tests still pass
  (the hero still uses `upcoming.first`; default view still list).

## Out of scope
Server-side `from_today` (client filter used); changing the calendar to hide past months; a dedicated
back button (the toggle suffices).

## Files
```
lib/providers/holidays_view_provider.dart            MODIFY: + calendarFocusProvider
lib/screens/home/home_screen.dart                    MODIFY: list window (today..longest-break cap) + HolidayCard onTap
lib/screens/home/widgets/holiday_card.dart           MODIFY: + optional onTap (InkWell)
lib/screens/home/widgets/holiday_calendar_view.dart  MODIFY: seed focus/selection from calendarFocusProvider
tests: home list-window + tap-to-calendar + back      ADD/MODIFY
```
