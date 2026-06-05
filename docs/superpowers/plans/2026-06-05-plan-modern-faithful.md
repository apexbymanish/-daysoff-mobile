# Faithful 6.6 Plan (length-buffet) Rebuild

> REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** Rebuild the Plan screen to closely match Stitch `6.6` — a horizontal **card carousel** with big numerals, "N PTO used" pills, large **ribbon blocks** (H/P/W), a rotated "Best Value" badge on the highlighted card, restyled **filter chips**, an **olive "Best value" banner**, and a **balance banner**.

**Source of truth:** `/tmp/stitch-6.6.html` — OPEN AND FOLLOW IT (light theme).

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/plan-modern-faithful`**. Baseline: 84 tests, analyzer clean. New color tokens already added: `DaysoffColors.indigo` (#4858AB), `indigoContainer` (#96A5FF), `olive` (#2B3218), `oliveFixed` (#DEE7C0), `redContainer` (#FFDAD6), `onRedContainer` (#93000A), `surfaceContainerHigh` (#E7E8E8), `surfaceContainerLow` (#F3F4F3), plus existing `brandTeal`, `outlineVariant`, `neutral500/700`. Caps labels use `labelCaps()` from `lib/theme/typography.dart`.

## Color/structure mapping (HTML → Flutter)
- **Card:** `bg white`, `outlineVariant` border, `rounded 28`, card-shadow (`BoxShadow(color: brandTeal.withValues(alpha:0.08), blur 30, offset (0,8))`). The **best-value** card: `border: 2px brandTeal` + a rotated "BEST VALUE" badge (top-right, `Transform.rotate(0.785)`, `brandTeal` bg, cream/`primary-fixed` text, caps).
- **Numeral:** `brandTeal`, ~52–60px, w700; "days" `brandTeal` ~20px beside it. Date range: `neutral500` 14px.
- **"N PTO used" pill** (top-right): `ptoCost == 0` → bg `redContainer`, text `onRedContainer`, label `"0 PTO used"`; else bg `oliveFixed`, text `olive`, label `"$ptoCost PTO used"`. Caps (`labelCaps(fontSize: 10, fontWeight: w700)`), rounded 8.
- **Ribbon blocks** (one per break day, `Expanded`, height 40, rounded 8, centered letter, Manrope 14 w700): `classifyBreakDay` → H (holiday) = bg `indigoContainer.withValues(alpha:0.35)` text `indigo`; P (pto) = bg `oliveFixed` text `olive`; W (weekend) = bg `surfaceContainerHigh` text `neutral700`.
- **Footer:** top border (`outlineVariant` @0.3), an anchor icon (`Icons.flag_outlined`) + anchor name (`neutral700` 14 w500); the best-value card also shows a **"Details ›"** `TextButton` (brandTeal, w800) → `context.push(AppRoutes.breakDetail, extra: trip)`.
- **Filter chips:** white, `outlineVariant` border, rounded ~20, `shadow-sm`, font w600 14. Order: country (flag + **full country name** — use `countryName(code)` if available, else the code), year, "{weekend} off", "{budget} days". Tapping → same targets as today (country→picker, year→stepper dialog, weekend/budget→editor).
- **Best value banner:** bg `oliveFixed`, rounded 24, a white circle with `Icons.auto_awesome` (`olive`), "Best value found" (bold `olive`) + "{breakLength}-day break for just {ptoCost} PTO day(s)" (`olive` @0.8, 14).
- **Balance banner:** bg `surfaceContainerLow`, rounded 28, border. Left: an 80×80 rounded scenery thumbnail (`Image.asset(sceneryForDate(DateTime(year,1,1)))`, errorBuilder → teal box). Text: "Balance: {budget} days left" (bold `brandTeal`) + "Optimized for {year}. These plans maximize long weekends while keeping your PTO budget intact." (`neutral700` 12).
- **Pagination dots** under the carousel: active = wide brandTeal bar, inactive = `outlineVariant` dots.

## Layout (`plan_screen.dart` `_Buffet`)
A scrollable column: filter chips → best-value banner → **carousel** (`PageView.builder`, `controller: PageController(viewportFraction: 0.85, initialPage: <index of best-value trip>)`, height ~ 300; track the page in a `StatefulWidget`/`StateProvider`; non-active pages dimmed via `AnimatedScale`/opacity) → pagination dots → balance banner. Keep the empty ("No breaks fit this budget…"), loading, and error states. The carousel item is the redesigned card (rebuild `BreakCard`).

## Preserve
- `PlanScreen`/`_Buffet` still build the query from providers and watch `planProvider`; `_bestPerLength` ordering; navigation to break detail via `AppRoutes.breakDetail` with the `PlanTrip` extra.
- Keep `PlanFilterChips`, `BestValueBanner`, `DayRibbon`, `bestValueTrip` (restyle them in place; keep their public APIs/keys).
- The "Adjust" entry: replace the app-bar Adjust button with an `edit` icon next to a "Plan your year" title (→ `showPreferencesEditor`), per the mockup; OR keep the Adjust button. Either is fine — the chips already open the editor.

## Tasks
- [ ] **T1 — ribbon blocks:** restyle `day_ribbon.dart` to the big `ribbon-block` look (Expanded, h40, rounded8, H/P/W letters, indigo/olive/gray). Keep `DayRibbon(trip:)` API. Update `day_ribbon_test.dart` if needed (still finds 'P'/'W'). Run + commit.
- [ ] **T2 — card redesign:** rebuild `break_card.dart` to the carousel card (numeral, PTO-used pill, ribbon blocks, anchor footer, optional Details button + `isBestValue` flag for the highlight/badge). Add `BreakCard({trip, onTap, isBestValue = false})`. Test render. Run + commit.
- [ ] **T3 — chips + banners:** restyle `plan_filter_chips.dart` (white bordered pills, full country name) and `best_value_banner.dart` (olive). Keep tests green (update label assertions only if text changed). Run + commit.
- [ ] **T4 — carousel + balance + assemble:** rebuild `_Buffet` (chips → banner → PageView carousel with dimming + pagination dots → balance banner), wire `isBestValue` to `bestValueTrip`, Details → break detail. Update `plan_screen_test.dart` (it asserts `find.byType(BreakCard)` + '3 days'/'5 days'/'Retry' — with a PageView only some cards build; change to `findsWidgets`/assert the best-value card + the error 'Retry' path; report changes). Full gate: `flutter test` + `flutter analyze`. Commit.

## Out of scope
The wordmark/menu sticky header (keep a simple "Plan your year" app bar); per-anchor icons (use one icon); the 3-tab nav (that's 6.7).

## Done when
`flutter test && flutter analyze` clean; Plan shows the restyled chips, olive best-value banner, a swipeable carousel of redesigned cards (big numerals, PTO-used pills, ribbon blocks, best-value highlight + badge, Details→break detail), pagination dots, and a balance banner — matching `/tmp/stitch-6.6.html`.
