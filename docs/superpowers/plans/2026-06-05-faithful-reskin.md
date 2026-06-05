# Faithful Reskin (6.1 Home + 6.2 Break detail) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Rebuild Home (6.1) and Break detail (6.2) to closely match the Stitch designs.

**Architecture:** The exact designs are in the downloaded Stitch HTML — implementers MUST open and follow them: `/tmp/stitch-6.1.html` (Home, light) and `/tmp/stitch-6.2.html` (Break detail, dark). Translate the markup to Flutter widgets using the color mapping below. Preserve existing provider wiring, the `holidaysViewProvider` toggle, the saved-breaks Save logic, and the test texts/keys.

**Tech Stack:** Flutter, flutter_riverpod, intl. **Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/faithful-reskin`** (commit there, never switch). Baseline: 80 tests, analyzer clean.

## Color mapping (Stitch HTML token → Flutter)
| HTML | Flutter |
|---|---|
| `#f9f9f9` background (Home) | `Color(0xFFF9F9F9)` |
| card `#ffffff` | `Colors.white` |
| `outline-variant #c0c8c8` | `Color(0xFFC0C8C8)` |
| `primary` / `primary-container` teal (`#003637`/`#1a4d4e`) | `DaysoffColors.brandTeal` |
| `on-surface #191c1c` | `DaysoffColors.neutral900` |
| `on-surface-variant #404848` | `DaysoffColors.neutral700` |
| `outline #707978` | `DaysoffColors.neutral500` |
| Free pill bg / text | `DaysoffColors.brandTeal.withValues(alpha: 0.10)` / `DaysoffColors.brandTeal` |
| Absorbed pill bg / text | `Color(0xFFE7E8E8)` / `DaysoffColors.neutral700` (≈60% opacity) |
| break-detail bg `#14171A` | `DaysoffColors.darkSurface` |
| sage `#8E9775` (6.2 PTO/pill/button) | `Color(0xFF8E9775)` |
| korea-red `#CD2E3A` (holiday tag) | `DaysoffColors.koreaRed` (added in Task 1) |
| weekend teal `#1a4d4e` | `DaysoffColors.brandTeal` |
| warm-cream `#FDFBF7` (6.2 tag text) | `Color(0xFFFDFBF7)` |

Fonts: titles/body = default (Manrope is the app font); the small caps labels use `letterSpacing` + uppercase (the app doesn't bundle JetBrains Mono — approximate with the default mono-ish caps style already used elsewhere, i.e. uppercase + `letterSpacing: 0.8–1.2`).

## Out of scope
3-tab nav + Sandwich merge (6.7); share-button action; multi-day "(N days)" grouping; bottom-nav restyle.

---

## Task 1: koreaRed color token
**Files:** Modify `lib/theme/colors.dart`
- [ ] Add after the `danger` tokens: `static const Color koreaRed = Color(0xFFCD2E3A);`
- [ ] `flutter analyze` (clean).
- [ ] Commit: `git add lib/theme/colors.dart && git commit -m "feat(theme): add koreaRed token for holiday tags"`

---

## Task 2: Home (6.1) faithful

**Files:** Modify `lib/screens/home/widgets/next_break_hero.dart`, `lib/screens/home/widgets/holiday_card.dart`, `lib/screens/home/widgets/month_section.dart`, `lib/screens/home/home_screen.dart`; Modify/extend `test/screens/home/holiday_card_test.dart`, add `test/screens/home/home_header_test.dart`.

**REFERENCE:** open `/tmp/stitch-6.1.html` and match it. Structure to reproduce:

1. **Header** (replace the current SliverAppBar `title`/`actions`). Left: a `language` (globe) `IconButton` → `context.push(AppRoutes.countryPicker)` (replaces the country chip), immediately followed by a **"daysoff"** wordmark `Text` (`fontSize: 24, fontWeight: w800, color: DaysoffColors.brandTeal, letterSpacing: -0.5`). Keep the **year stepper** (`_YearStepper`) — render it in the bottom area or as part of the title row per the HTML (chevron_left, `'$year'`, chevron_right). Right `actions`: a `calendar_today`/`calendar_view_month` `IconButton` keyed `toggle-calendar` that flips `holidaysViewProvider` between list/calendar (when in calendar view show `view_agenda` to go back, key `toggle-list`), then the existing bookmark `IconButton` → `/saved`. Give the app bar a white/`#f9f9f9` background and a bottom border (`outline-variant`).

2. **Hero** — restyle `NextBreakHero` to the 6.1 hero: height **240**, rounded 16, scenery image + a bottom-up scrim (`Colors.black.withValues(alpha:0.6)`→transparent at ~60%). Bottom-left text: `"NEXT BREAK IN"` (caps, white70, ~10px, letterSpacing 1.5), a baseline row of big `'$days'` (~44px white w700) + `"Days"` (white ~18px), then `"{name} · {date}"`. Bottom-**right**: a translucent **"See details" pill** — `TextButton` styled as a rounded `white.withValues(alpha:0.20)` chip with a `white.withValues(alpha:0.25)` border, white uppercase ~11px label → `onSeeDetails`. (Keep the `errorBuilder` gradient fallback + the existing `NextBreakHero({next, onSeeDetails})` API.)

3. **`holiday_card.dart`** — wrap as a **white card** (the screen groups a month's cards in one rounded-white container; simplest: make each `HolidayCard` a white, `outline-variant`-bordered, rounded-16 container with internal padding 16 — keep it a `ConsumerWidget`). Row: left `SizedBox(width: 56)` column = date numeral (`fontSize: 24, w800, color: DaysoffColors.brandTeal`) + weekday caps (`neutral700`, ~10px, letterSpacing 0.8, uppercase). Middle (Expanded, left padding + a left divider `Border(left:)` in `outline-variant`): name (`fontSize: 17–20, w600, neutral900`) + native subtitle (`nameLocal`, `fontSize: 14, neutral700`) when present & ≠ name. Right: the **status pill** — `Free` = `brandTeal.withValues(alpha:0.1)` bg, `brandTeal` text + `Icons.wb_sunny` (16) + `'Free'` uppercase caps w700; `Absorbed` = `Color(0xFFE7E8E8)` bg, `neutral700` text @ ~60% + `Icons.bedtime` + `'Absorbed'` caps. Status via `isAbsorbed(holiday.date, weekend)` (existing). Keep `Holiday` API.

4. **`month_section.dart`** — caps month name (`neutral700`, uppercase, letterSpacing 1.2) + a horizontal divider line (`outline-variant` at low opacity) filling the remaining width (Row: Text + Expanded(Divider)).

5. **`home_screen.dart`** — keep the list/calendar branch logic; in the **list** branch the month sections + cards stay (now restyled). Scaffold/list background `Color(0xFFF9F9F9)`.

### TDD steps
- [ ] **Step 1:** add `test/screens/home/home_header_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/api/api_client.dart';
import 'package:daysoff_mobile/api/models/holiday.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/providers/api_provider.dart';
import 'package:daysoff_mobile/screens/home/home_screen.dart';
import 'package:daysoff_mobile/screens/home/widgets/holiday_calendar_view.dart';

class _FakeApiClient extends ApiClient {
  @override
  Future<HolidaysResponse> getHolidays({required String country, required int year, bool fromToday = false}) async =>
      HolidaysResponse(country: 'KR', year: 2026, count: 1,
        holidays: [Holiday(date: DateTime(2026, 1, 1), name: "New Year's Day", source: 'library')]);
}

void main() {
  testWidgets('header shows the daysoff wordmark and calendar toggle flips views', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(_FakeApiClient())],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('daysoff'), findsOneWidget);
    expect(find.byKey(const Key('holiday-calendar')), findsNothing);
    await tester.tap(find.byKey(const Key('toggle-calendar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('holiday-calendar')), findsOneWidget);
  });
}
```
- [ ] **Step 2:** extend `test/screens/home/holiday_card_test.dart` — keep its existing 2 tests; they still assert `'설날'`, `'free'`, `'absorbed'`. IMPORTANT: the pills now render **uppercase** (`Free`/`Absorbed`), so update those two assertions to `find.text('Free')` / `find.text('Absorbed')` (capitalized). Keep the native-name assertion (`find.text('설날')`).
- [ ] **Step 3:** Run the two test files → FAIL.
- [ ] **Step 4:** Implement items 1–5 above (reference `/tmp/stitch-6.1.html`).
- [ ] **Step 5:** Run `flutter test test/screens/home/` then full `flutter test` + `flutter analyze` (clean). The existing `home_toggle_test`/`home_hero_test` must still pass — if they asserted the old `toggle-list`/`toggle-calendar` keys, those keys are preserved; if they asserted a country chip, update minimally and report.
- [ ] **Step 6:** Commit: `git add -A lib/screens/home test/screens/home && git commit -m "feat(home): faithful 6.1 reskin — wordmark header, hero pill, bordered cards, caps Free/Absorbed"`

---

## Task 3: Break detail (6.2) faithful dark

**Files:** Rewrite `lib/screens/plan/break_detail_screen.dart`; Modify `test/screens/plan/break_detail_test.dart`.

**REFERENCE:** open `/tmp/stitch-6.2.html` and match it. The whole screen is **dark** (`DaysoffColors.darkSurface` body) regardless of app theme.

Structure:
1. `Scaffold(backgroundColor: DaysoffColors.darkSurface)`, `extendBodyBehindAppBar: true`, transparent `AppBar` (gradient black→transparent feel) with white `arrow_back` (auto back), centered white **"Break Details"**, and a white `share` icon (no-op/`onPressed` shows a SnackBar "Coming soon" — out of scope action).
2. **Hero** (`SizedBox(height: 45% of screen)` or fixed ~320): scenery `Image.asset(sceneryForDate(trip.breakStart))` cover + a top→bottom scrim ending in `darkSurface`. Bottom overlay (padding 20, bottom 24): a row of `"{breakLength}-day break"` (white, ~22px w700) + a sage `"{ptoCost} PTO"` pill (`Color(0xFF8E9775)` bg, white, caps); then `"{Mon d} – {Mon d} • anchored on {anchor}"` (white70, 14px) with the `"{anchor}{ / native}"` portion in `Color(0xFF8E9775)`. (Anchor native: look up the first holiday-kind day's `nameLocal` from `holidaysProvider`; show "{anchor} / {native}" when present.)
3. **Body** (dark): `"DAY-BY-DAY"` caps (`neutral500`/outline). For each day (`key: ValueKey('break-day-row')`), a row: left = date (`EEE MMM d`, white) + an **overline** (`ORDINARY DAY` for PTO, `FESTIVAL` for holiday, `REST` for weekend — caps, ~11px, `Color(0xFF8B9197)`); right = a **tag pill** (`px 12 py 1`, rounded-full, tinted bg + subtle border, text `Color(0xFFFDFBF7)`, caps ~11px):
   - PTO → `Color(0xFF8E9775).withValues(alpha:0.12)` bg, label `PTO`
   - Holiday → `DaysoffColors.koreaRed.withValues(alpha:0.12)` bg, label `Holiday • {holidayName}` (use the matched holiday's `name`, else the anchor, else 'Holiday')
   - Weekend → `DaysoffColors.brandTeal.withValues(alpha:0.12)` bg, label `Weekend`
   Rows separated by a `white.withValues(alpha:0.05)` bottom border.
4. **Summary card** (`white.withValues(alpha:0.05)` bg, `white.withValues(alpha:0.10)` border, rounded 12, padding 16): a circular `event_available` icon (sage tint) + `"{ptoCost} PTO day(s) → {breakLength} days off"` (white) + `"Maximize your time with public holidays"` (`neutral500`, 12px).
5. **Save button** — full-width `FilledButton`/`SizedBox(height:56)`, bg `Color(0xFF8E9775)`, white text **"Save this break"**, rounded 12, placed in `Scaffold.bottomNavigationBar` (`SafeArea`). Unchanged save logic: `savedBreaksProvider.notifier.add(SavedBreak(id:'break-${trip.breakStart.toIso8601String()}', label:'${trip.breakLength}-day break', start, end, ptoCost, kind:'break'))` + SnackBar 'Saved'.

Data: `country/year` from `selectedCountryProvider`/`selectedYearProvider`; `ref.watch(holidaysProvider(HolidaysQuery(country, year))).maybeWhen(data: build Map<date-only, Holiday>, orElse: {})`; `classifyBreakDay(day, trip.ptoDates)` for kind.

### TDD steps
- [ ] **Step 1:** Update `test/screens/plan/break_detail_test.dart` — KEEP the existing tests' intent but adapt to the new structure. Required assertions after rewrite:
  - keep a `_FakeApiClient` returning Chuseok 2026-09-24 (`name:'Chuseok', nameLocal:'추석'`) and the `apiClientProvider` override on every test (the screen watches holidaysProvider).
  - `'5-day break'` still present (now in the hero overlay) → `find.text('5-day break')` findsOneWidget.
  - `textContaining('PTO')` present (hero pill "1 PTO" and/or summary) → keep a `find.textContaining('1 PTO')` OR `find.textContaining('PTO day')`.
  - 5 day rows: `find.byKey(const ValueKey('break-day-row'))` findsNWidgets(5).
  - holiday tag: `find.textContaining('Holiday • Chuseok')` findsWidgets.
  - overlines: `find.text('REST')` findsWidgets, `find.text('ORDINARY DAY')` findsWidgets.
  - Save: tapping `find.text('Save this break')` adds to `savedBreaksProvider` (length 1).
  Write these as the test set (2–3 `testWidgets`).
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Rewrite the screen (reference `/tmp/stitch-6.2.html`).
- [ ] **Step 4:** Run `flutter test test/screens/plan/break_detail_test.dart` → PASS, then full `flutter test` + `flutter analyze` (clean).
- [ ] **Step 5:** Commit: `git add lib/screens/plan/break_detail_screen.dart test/screens/plan/break_detail_test.dart && git commit -m "feat(plan): faithful 6.2 reskin — dark break detail with overlines + colored tags"`

---

## Self-review
- **Coverage:** koreaRed (T1); Home header/hero/cards/month faithful (T2); break detail dark with hero overlay, overlines, colored tags, summary card, sage save (T3).
- **Placeholders:** the implementer references the HTML files for exact layout — that's the source of truth, not a placeholder; tests pin the key text/keys.
- **Types:** `NextBreakHero({next,onSeeDetails})`, `HolidayCard(holiday:)`, `MonthSection(month:)`, `BreakDetailScreen(trip:)` APIs unchanged; `isAbsorbed`, `classifyBreakDay`, `sceneryForDate`, `holidaysProvider`, `savedBreaksProvider` reused; `DaysoffColors.koreaRed` added in T1 before T3 uses it.

## Done when
`flutter test && flutter analyze` clean; Home matches 6.1 (wordmark header, 240px hero with See-details pill, white bordered cards with teal numerals + native subtitles + caps Free/Absorbed pills, month dividers); Break detail matches 6.2 (dark, hero summary overlay, overline day rows + sage/red/teal tags, summary card, sage Save button); existing behavior (toggle, save, native names) preserved.
