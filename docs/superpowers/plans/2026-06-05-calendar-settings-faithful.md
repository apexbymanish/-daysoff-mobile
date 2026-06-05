# Faithful 6.4 Calendar + 6.8 Settings

> REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** Match Stitch 6.4 (calendar grid with sun-marked holiday cells, selected ring, weekend dimming, a legend, and an inline selected-day summary card) and 6.8 (card-grouped Settings sections + disabled Calendar/Account placeholders + version footer).

**Sources of truth:** `/tmp/stitch-6.4.html` and `/tmp/stitch-6.8.html` (OPEN them, light theme).

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/calendar-settings-faithful`**. Baseline 88 tests, analyzer clean. Tokens available incl. `brandTeal`, `oliveFixed`(#DEE7C0), `oliveFixedDim`(#C1CBA6, holiday fill), `surfaceVariant`(#E2E3E2), `outlineVariant`, `surfaceContainerLow`, `neutral500/700`, `danger`. `labelCaps()` in `lib/theme/typography.dart`. `Holiday{date,name,nameLocal?,source}`, `holidaysProvider`, `weekendProvider`, `isAbsorbed(date,weekend)` (lib/core/holiday_status.dart), `classifyBreakDay`. `showPreferencesEditor`, `themeModeProvider`, prefs providers.

---

## Task 1: Faithful 6.4 calendar view
**Files:** `lib/screens/home/widgets/holiday_calendar_view.dart` (restyle); new `lib/screens/home/widgets/day_summary_card.dart`; tests.
Reference `/tmp/stitch-6.4.html`. Keep `HolidayCalendarView({holidays, year})` + the `holiday-calendar` key.
- **Day cells** (via `TableCalendar` `calendarBuilders`): a **holiday** day = a circular `oliveFixedDim`@0.4 fill + the day number + a small `Icons.wb_sunny` (12px, brandTeal) below; **weekend** day (per `weekendProvider`) = dimmed text (`neutral500`); **selected** day = a 2px `brandTeal` ring (use `selectedDayPredicate` + `onDaySelected` to track `_selected` in state); today subtle. Outside days dimmed (`neutral500`@0.4). (A "holiday" here = a day present in the `holidays` map; reuse the date→Holiday map.)
- **Legend** row under the calendar: `oliveFixedDim` dot + `wb_sunny` "free day"; `surfaceVariant` dot + `dark_mode` "absorbed"; ring "selected". Labels `labelCaps(10)`.
- **Inline `DaySummaryCard`** below the legend (replaces the bottom sheet for the calendar): shows the currently-selected day. If the day has a holiday: a `brandTeal`-container square (rounded) with `wb_sunny` icon + "{name} / {nameLocal}" (native in muted) + a pill ("Free Day" `oliveFixed`/`olive` if it's a working-day holiday, else "Absorbed" `surfaceVariant`/`neutral700` via `isAbsorbed`) + "{EEE MMM d} · Public Holiday" with a calendar icon. If no holiday: "{EEE MMM d}" + "Nothing on this day." Default the selected day to the first holiday of the focused year (or today if in-year), so the card isn't empty on open.
- `onDaySelected` updates `_selected` (setState) and the inline card — do NOT open `showDayDetailSheet` from the calendar anymore (the inline card replaces it). (Leave `day_detail_sheet.dart` in place; it's still used by the Home hero "See details".)
- Tests: calendar renders (`holiday-calendar` key); a holiday day shows a sun marker (`Key('holiday-marker')` or find the icon); tapping a holiday day updates the inline `DaySummaryCard` to show its name (override holidaysProvider with Chuseok 2026-09-24 / 추석 → tap 24 → card shows "추석" + "Public Holiday"); the legend renders ("free day"/"absorbed"/"selected").
- Run + commit.

## Task 2: Faithful 6.8 Settings
**Files:** rewrite `lib/screens/settings/settings_screen.dart`; tests `test/screens/settings/settings_screen_test.dart`.
Reference `/tmp/stitch-6.8.html`. Keep `SettingsScreen` (ConsumerWidget). A `ListView` of card-grouped sections; each row = a `_SettingsCard` (white bg, `outlineVariant` border, rounded 12, soft shadow, padding) with a **label** (body-lg medium) + a **value subtitle** below (body-sm `neutral700`) + a trailing `chevron_right` (for tappable rows). Section headers use `labelCaps` uppercase `outline`/`neutral500`.
- **PREFERENCES:** "Country of work" → "🇰🇷 South Korea" (tappable → country picker, `AppRoutes.countryPicker`); "Workweek" → `formatWeekend(weekend)` (→ editor); "PTO budget" → "$budget days" (→ editor); "Break length" → "${min}–${max} days" (→ editor). (Keep these editable — they're live.)
- **APPEARANCE:** keep the Theme control — render it inside a `_SettingsCard` as a row "Theme" + the existing `SegmentedButton<ThemeMode>` (System/Light/Dark) wired to `themeModeProvider` (PRESERVE — the `selecting Dark updates themeModeProvider` test must still pass).
- **CALENDAR & REMINDERS** (disabled placeholders, per the chosen scope): "Apple Calendar" → "Not connected" and "Default reminder" → "2 weeks before" — render as `_SettingsCard`s with reduced opacity (~0.5), `onTap: null`, no chevron (or a muted one). Add a tiny "Coming soon" affordance is optional.
- **ACCOUNT** (disabled placeholders): "Profile" (person icon) and "Sign out" (centered, `danger` text) — disabled (opacity ~0.5, `onTap: null`).
- **Footer:** centered `labelCaps` "daysoff v0.1.0 · {selectedCountry}" (muted).
- Tests: keep/adapt the existing — `'Weekend'` row + `formatWeekend` value + `'15 days'` + `'3–10 days'` still present; tapping "PTO budget" opens the editor; **the theme-toggle test (`selecting Dark updates themeModeProvider`) still passes**; the disabled rows render ("Apple Calendar", "Sign out") but do not navigate. Report any assertion changed.
- Run + commit. Full gate after: `flutter test` + `flutter analyze` clean.

## Out of scope
The 6.8 in-mockup country-pick sub-screen (we already have a picker); profile avatar image (use a placeholder icon); real calendar/auth wiring (placeholders only).

## Done when
`flutter test && flutter analyze` clean; the calendar view shows sun-marked holiday cells + selected ring + weekend dimming + a legend + an inline day-summary card; Settings shows card-grouped PREFERENCES (editable) + APPEARANCE (theme) + disabled CALENDAR & REMINDERS / ACCOUNT placeholders + a version footer — matching the HTML.
