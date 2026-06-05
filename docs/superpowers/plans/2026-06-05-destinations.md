# Faithful 6.3 Destinations (Find Your Escape)

> REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** A faithful "Find Your Escape" destinations showcase (Stitch 6.3) using the 4 bundled scenery photos — reached by tapping the Home scenery hero. Decorative/visual (no destinations backend): search + chips filter a static curated list; bookmark is a local visual toggle.

**Source of truth:** `/tmp/stitch-6.3.html` (OPEN IT, light theme).

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/destinations`**. Baseline 95 tests, analyzer clean. Assets: `assets/scenery/{kyoto,alps,cinque_terre,marrakech}.jpg`. Tokens: `brandTeal`(primary), `oliveFixedDim`(#C1CBA6), `indigoContainer`(#96A5FF, secondary-container), `outlineVariant`, `surfaceContainerLow`, `neutral500/700`. `labelCaps()` (lib/theme/typography.dart). Route pattern: top-level `GoRoute(parentNavigatorKey: _rootNavigatorKey)` (see `saved`).

## Task 1: DestinationsScreen + route + hero entry
**Files:** new `lib/screens/destinations/destinations_screen.dart`; modify `lib/router/app_router.dart` (+ `AppRoutes.destinations = '/destinations'` and a root-navigator GoRoute → `DestinationsScreen`); modify `lib/screens/home/widgets/next_break_hero.dart` (+ optional `onTap`) and `lib/screens/home/home_screen.dart` (hero `onTap` → `context.push(AppRoutes.destinations)`). Test `test/screens/destinations/destinations_screen_test.dart`.

**Screen** (`DestinationsScreen` StatefulWidget, reference the HTML):
- AppBar: leading back arrow (auto), centered "daysoff" wordmark (brandTeal) OR title "Find Your Escape" — use a simple AppBar with a back button + title "Find Your Escape".
- Body `ListView`, container-margin padding:
  - Header: "Find Your Escape" (headline-lg brandTeal) + "Curated trips for your next available window." (body-sm neutral700).
  - **Search field** (visual): a rounded `surfaceContainerLow` `TextField` with a `search` prefix icon, placeholder "Search destinations…". On change, filter the static list by title (case-insensitive). (Functional-but-local; fine.)
  - **Category chips** (horizontal scroll): All Ideas (default selected, brandTeal filled) / Beach (`beach_access`) / Forest (`forest`) / Mountains (`terrain`) / Culture (`temple_buddhist`). `labelCaps`. Selecting filters the list by the destination's `category`; "All Ideas" shows all.
  - **Destination cards** (vertical stack — adapt the bento grid to a single column): one card per destination — a rounded-24 image (`Image.asset`, ~16:9 / taller for the wide one) with a bottom black gradient, a top-right bookmark button (local toggle: `bookmark_border`↔`bookmark`), and bottom overlay: a small tag pill (colored) + title (white, headline) + optional subtitle (white70). Use this static data:
    1. `cinque_terre.jpg` — "Cinque Terre, Italy" / "Coastal charm with pastel villas and turquoise waters." / tag "Chuseok Break · 5 days" (`oliveFixedDim`/`olive`) / category Beach.
    2. `kyoto.jpg` — "Arashiyama, Kyoto" / tag "Weekend Trip · 3 days" (`indigoContainer`/`indigo`) / category Forest.
    3. `marrakech.jpg` — "Marrakech, Morocco" / tag "Annual Leave · 7 days" (`brandTeal`/white) / category Culture.
    4. `alps.jpg` — "Grindelwald, Swiss Alps" / "Best in Dec–Feb." / tag "Recommended for Winter" (white/brandTeal) / category Mountains (wider/taller hero card).
  - **Trip Collections**: a "Trip Collections" header (headline-md brandTeal) + 3 cards (`surfaceContainerLow`, border, rounded): icon circle + title + blurb — "Nature Retreats" (`local_florist`), "Cultural Journeys" (`history_edu`), "Culinary Trips" (`restaurant`). Static/decorative.
- A `_Destination` model (image, title, subtitle?, tag, tagBg, tagFg, category) — a `const` list in the file.

**Wire:** `NextBreakHero` gains an optional `VoidCallback? onTap` (wrap the card in `InkWell`/`GestureDetector`); the "See details" pill keeps its own `onSeeDetails` (stopPropagation not needed — button is separate). In `home_screen.dart`, pass `onTap: () => context.push(AppRoutes.destinations)`.

**Tests:** DestinationsScreen renders "Find Your Escape" + the 4 titles ("Cinque Terre, Italy" etc.) + "Trip Collections"; tapping the "Mountains" chip filters to "Grindelwald, Swiss Alps" (and hides others, e.g. "Arashiyama, Kyoto" gone); a search query "kyoto" shows Arashiyama only. (Pump in a `MaterialApp` — no providers needed; it's static.) Optionally a Home test that tapping the hero pushes Destinations (use the existing home test harness with a router, OR skip if fiddly and just test the screen).

- Run `flutter test` + `flutter analyze` (clean). Commit.

## Out of scope
Real destinations data/booking; persisting bookmarks; the bento multi-column desktop grid (single-column stack on mobile is fine); per-destination detail screens.

## Done when
`flutter test && flutter analyze` clean; tapping the Home hero opens a "Find Your Escape" screen with the 4 scenery destination cards, working category-chip + search filtering (over the static list), a local bookmark toggle, and a Trip Collections section — matching `/tmp/stitch-6.3.html`.
