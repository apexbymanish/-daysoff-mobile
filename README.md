# daysoff-mobile

Flutter client for the [daysoff-api](../daysoff-api) — a multi-source
holiday aggregator and vacation planner for office workers in Asia.

> **Status:** scaffold. Home screen is wired end-to-end to
> `GET /v1/holidays`; the other 8 screens are stubs that point at the
> Stitch design specs under `../daysoff-api/docs/stitch/screens/`.

## Quick start

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate freezed + json_serializable code
dart run build_runner build --delete-conflicting-outputs

# 3. Start the daysoff-api somewhere reachable from the simulator
#    (in a separate terminal, from the daysoff-api repo):
#    python3 -m uvicorn api.main:app --host 127.0.0.1 --port 8080

# 4. Run the app, pointing at the local API
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

The default `API_BASE_URL` is `http://127.0.0.1:8080` if you omit the
`--dart-define` flag, so step 4 can be just `flutter run` for the
local case.

## Tech stack

| Concern | Package | Notes |
|---|---|---|
| State | `flutter_riverpod` | `FutureProvider.family` for the API queries |
| Routing | `go_router` | Declarative, deep-link ready |
| HTTP | `dio` | Base URL via `--dart-define=API_BASE_URL=...` |
| Models | `freezed` + `json_serializable` | Codegen — re-run after changing models |
| Dates | `intl` | Month/weekday formatting |
| Theme | Material 3 + `ColorScheme.fromSeed` | Seed = deep teal brand |

## Project layout

```
lib/
├── main.dart                 entry, wraps app in ProviderScope
├── app.dart                  MaterialApp.router + theme wiring
├── theme/
│   ├── colors.dart           DaysoffColors tokens
│   └── app_theme.dart        light + dark ThemeData
├── router/
│   └── app_router.dart       GoRouter config
├── api/
│   ├── api_client.dart       dio + getHolidays()
│   ├── endpoints.dart        path constants
│   └── models/
│       ├── holiday.dart      freezed Holiday
│       └── holidays_response.dart
├── providers/
│   ├── api_provider.dart     apiClientProvider
│   └── holidays_provider.dart  FutureProvider.family<HolidaysResponse, HolidaysQuery>
└── screens/
    ├── home/                 ← implemented (Screen 3 from Stitch pack)
    │   ├── home_screen.dart
    │   └── widgets/
    │       ├── holiday_card.dart
    │       ├── month_section.dart
    │       └── days_until_banner.dart
    ├── onboarding/           stub
    ├── plan/                 stub
    ├── sandwich/             stub
    └── settings/             stub
```

## What works today

- App launches at Home (no auth gate — onboarding is stubbed).
- Hardcoded country/year: **KR / 2026** (country picker comes later).
- Live `GET /v1/holidays` against the local daysoff-api.
- Loading, error (with retry), and empty states.
- Month-grouped vertical scrolling timeline.
- "X days until {next holiday}" hero banner.
- Each holiday row: date stack + name + "free"/"absorbed" badge
  (absorbed = Sat/Sun under the standard workweek).

## What's next

Each unimplemented screen has a Stitch spec in the api repo:

| Screen | Stitch spec | Status |
|---|---|---|
| Onboarding (4 cards incl. auth) | `../daysoff-api/docs/stitch/screens/01-onboarding.md` | stub |
| Forgot password | `../daysoff-api/docs/stitch/screens/02-forgot-password.md` | stub |
| Holiday detail sheet | `../daysoff-api/docs/stitch/screens/04-holiday-detail-sheet.md` | not started |
| Plan — length buffet | `../daysoff-api/docs/stitch/screens/05-plan-length-buffet.md` | stub |
| Break detail | `../daysoff-api/docs/stitch/screens/06-break-detail.md` | not started |
| Sandwich tab | `../daysoff-api/docs/stitch/screens/07-sandwich-tab.md` | stub |
| Settings | `../daysoff-api/docs/stitch/screens/08-settings.md` | stub |
| Connect calendar | `../daysoff-api/docs/stitch/screens/09-connect-calendar.md` | not started |

Other next steps:

- Country picker (sheet) + year stepper so Home isn't hardcoded.
- Bottom tab bar (`Holidays / Plan / Sandwich / Settings`).
- Dark mode polish — the theme is wired but only light is enabled in `app.dart`.
- Firebase Auth for the required-signup flow (master spec calls for
  email/password + Google + Apple).
- Apple Calendar integration via `device_calendar` for the
  read+write events overlay (see Screen 9).
- i18n: Korean (한글), Nepali (नेपाली), Japanese (日本語), Hindi,
  Filipino. Strings should land in `lib/l10n/` via the `intl` ARB
  workflow.

## Tests

```bash
flutter test
```

The one smoke test overrides `holidaysProvider` so no real network
call happens — it verifies the app builds and the empty state renders.

## Conventions

- All API calls go through `ApiClient` (single dio instance).
- Provider-family args are explicit value types (see `HolidaysQuery`)
  so equality works for Riverpod's caching.
- Screen widgets stay thin; reusable pieces go in `widgets/` (per
  feature) or at `lib/widgets/` (shared).
- Re-run `dart run build_runner build --delete-conflicting-outputs`
  after editing any `@freezed` class.
