# 6.7 — Merge Sandwich into Plan + 3-tab nav

> REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** Match Stitch 6.7: a 3-tab nav (Holidays/Plan/Settings), a "Length buffet | Sandwich days" toggle on the Plan screen, redesigned sandwich cards (4-cell day ribbon + "Save + remind"), and an Efficiency Insight bar.

**Source of truth:** `/tmp/stitch-6.7.html` (OPEN IT, light theme). Nav styling cross-refs `/tmp/stitch-6.1.html` / `6.6`.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/plan-sandwich-merge`**. Baseline 85 tests, analyzer clean. `SandwichRecord{ptoDate, weekday, breakStart, breakEnd, breakLength, ptoCost, context}`. `sandwichesProvider(SandwichesQuery(country,year,workweek))`. `savedBreaksProvider`/`SavedBreak`. `labelCaps()` in `lib/theme/typography.dart`. Colors: `brandTeal`(primary), `oliveFixed`/`olive`(tertiary pill), `surfaceContainer`≈`Color(0xFFEDEEED)`, `surfaceContainerHigh`, `outlineVariant`, `neutral500/700`, `danger`(red). Router: `app_router.dart` `StatefulShellRoute.indexedStack` has 4 branches (home/plan/sandwich/settings).

## Task 1: Redesign SandwichCard + EfficiencyInsight (pure widgets; nothing structural)
**Files:** rewrite `lib/screens/sandwich/widgets/sandwich_card.dart`; new `lib/screens/sandwich/widgets/efficiency_insight.dart`; tests.
- **SandwichCard** (match 6.7 card): a white `tactile-card` (white bg, `outlineVariant` border, rounded 24, soft shadow). Header row: `Icons.calendar_add_on` (brandTeal) + "Take {weekday} {MMM d} off" (headline-md brandTeal); subtitle = `record.context` (body-sm neutral700); right: an **olive "N PTO" pill** (`oliveFixed` bg, `olive` text, `Icons.bolt`, caps via `labelCaps`). **Day ribbon:** a Row of cells for each day `breakStart..breakEnd` (each `Expanded`, height ~72, rounded 16, border): weekday caps (`labelCaps` 10) + date number (headline-md). The **`ptoDate`** cell is highlighted: `brandTeal.withValues(alpha:0.06)` bg + 2px `brandTeal` border + brandTeal text. Other cells: `surfaceContainer.withValues(alpha:0.5)` bg + `outlineVariant` border + neutral700 text. Footer: top border + `Icons.location_on` + `record.context` (caps) + a **"Save + remind"** `FilledButton.icon` (brandTeal, rounded-full, `Icons.bookmark`) that does the SAME save as today: `savedBreaksProvider.notifier.add(SavedBreak(id:'sandwich-${record.ptoDate.toIso8601String()}', label:'${record.weekday} sandwich', start: record.breakStart, end: record.breakEnd, ptoCost: record.ptoCost, kind:'sandwich'))` + SnackBar 'Saved'. Keep `SandwichCard({required SandwichRecord record})` ConsumerWidget. (Drop the dashed border + PtoCostPill usage here.)
- **EfficiencyInsight** (`EfficiencyInsight({required List<SandwichRecord> records})`): `brandTeal.withValues(alpha:0.05)` card, rounded 24, `brandTeal`@0.2 border. Header: `Icons.analytics` + "EFFICIENCY INSIGHT" (`labelCaps`, brandTeal). A progress bar (`LinearProgressIndicator` or a sized container, value = min(ratio/5,1)) + "{ratio}:1" (headline-md brandTeal) where `ratio = totalBreakDays / max(totalPto,1)` rounded, over the records. Copy: "Your rest efficiency is high: 1 PTO day consumed for every {ratio} consecutive days of rest." Returns `SizedBox.shrink()` for empty records.
- Tests: SandwichCard renders "Take … off", the PTO pill, a highlighted ptoDate cell, and Save adds to `savedBreaksProvider`; EfficiencyInsight shows a ratio for known records.
- Run + commit.

## Task 2: Plan view toggle + sandwich view
**Files:** new `lib/providers/plan_view_provider.dart` (`enum PlanView{buffet,sandwich}` + `planViewProvider = StateProvider<PlanView>((_) => PlanView.buffet)`); modify `lib/screens/plan/plan_screen.dart`; tests.
- Add a **segmented control** below the title: "Length buffet | Sandwich days" (bg `surfaceContainer` rounded 12; active segment = white bg + brandTeal bold + shadow + `outlineVariant` border). Bind to `planViewProvider`.
- When `PlanView.buffet`: the existing carousel `_Buffet` (unchanged). When `PlanView.sandwich`: watch `sandwichesProvider(SandwichesQuery(country, year, workweek: weekend))`; render `.when(loading/error/data)`; on data → the subtitle "Single workdays wedged between days off — take one, gain a long weekend.", a column of redesigned `SandwichCard`s, then `EfficiencyInsight(records: ...)`. Empty → "No sandwich days this year."
- Keep the filter chips visible in both views (they configure both). Keep the app bar.
- Tests: toggling to "Sandwich days" shows `SandwichCard`s (fake `apiClientProvider` returning sandwiches); toggling back shows the carousel.
- Run + commit.

## Task 3: 3-tab nav + drop the Sandwich branch
**Files:** rewrite `lib/router/scaffold_with_nav_bar.dart`; modify `lib/router/app_router.dart`; update `test/router/app_shell_test.dart`, `test/widget_test.dart`, and relocate/remove `test/screens/sandwich/*` that pumped the standalone screen.
- **ScaffoldWithNavBar** → a custom 3-tab bar (NOT Material `NavigationBar`): a `Container` (surface bg, top `outlineVariant` border, soft top shadow, height ~80, SafeArea) with a Row of 3 tab items: **Holidays** (`Icons.calendar_today`), **Plan** (`Icons.auto_awesome`), **Settings** (`Icons.settings`). The selected tab shows a pill (`brandTeal.withValues(alpha:0.10)` rounded 16 behind the icon+label) + brandTeal color; unselected = `neutral700`. Labels via `labelCaps(fontSize: 10)` UPPERCASE. `onTap` → `navigationShell.goBranch(index, initialLocation: index == currentIndex)`.
- **app_router.dart**: remove the Sandwich `StatefulShellBranch` (the `/sandwich` → `SandwichScreen` branch) and its import → 3 branches (home/plan/settings). (Leave `AppRoutes.sandwich` const if referenced elsewhere, else remove.) The branch indices are now home=0, plan=1, settings=2.
- **Tests:** `app_shell_test` — change "4 nav destinations" → assert the 3 tabs (Holidays/Plan/Settings) and tapping Settings works; remove the `find.text('Sandwich')` nav assertion. `widget_test` boot — ensure it still reaches Home after "Get started"; update any nav-index assumptions. Delete or repoint `test/screens/sandwich/sandwich_card_test.dart` to the redesigned card (it's tested in Task 1 now) and remove any test that pumped the standalone `SandwichScreen` route. Report every test changed/removed and why. Optionally delete `lib/screens/sandwich/sandwich_screen.dart` if now unused (the Plan sandwich view replaced it) — confirm no refs first.
- Full gate: `flutter test` + `flutter analyze` clean.
- Commit.

## Preserve
- Sandwich save logic (id/label/kind 'sandwich') identical; the sandwiches query still uses the weekend pref; the break-detail route stays under the Plan branch.

## Done when
`flutter test && flutter analyze` clean; the app has 3 styled tabs; Plan has a Length-buffet/Sandwich-days toggle; the sandwich view shows the redesigned day-ribbon cards + an Efficiency Insight bar; saving a sandwich still works.
