# Editable Plan Preferences — Design

**Date:** 2026-06-05
**Status:** Approved (design)

## Goal

Make **PTO budget**, **break length (min–max)**, and **weekend (days off)** user-editable and
persisted, replacing today's hardcoded `budget=15, min_length=3, max_length=10` and the
backend-default weekend. The chosen values flow into both `/v1/plan` and `/v1/sandwiches`.

## Problem

`plan_screen.dart` builds `PlanQuery(country, year, budget: 15)` with `minLength: 3, maxLength: 10`
defaults and no UI to change them. `sandwichesProvider` sends no `workweek`, so it uses the backend
default. Settings shows Country / Workweek / PTO budget as **display-only** rows. Result: every user
sees the same "budget 15, lengths 3–10, Sat/Sun" plan with no way to tune it.

## Semantics note (important)

The API's `workweek` parameter is documented (`api/main.py`) as a **"Comma list of OFF days,
e.g. sat,sun"** — i.e. it is the **weekend / days off**, not working days. The backend resolves it to
`weekend_set` / `weekend_names`. The current Settings label "Workweek: Sat, Sun" is therefore
mislabeled. This feature relabels it **"Weekend"** and the editor selects the user's days off.

## State — three persisted providers

Follow the existing pattern in `selection_provider.dart`: `StateProvider` seeded from `get_storage`
via `_read(key) ?? default`, persisted via `ref.listenSelf((_, next) => _write(key, next))`, all
guarded by `storageReady` so tests (which never `init()` storage) fall back to coded defaults with no
file I/O.

| Provider | Type | Default | Storage key(s) |
|---|---|---|---|
| `ptoBudgetProvider` | `StateProvider<int>` | `15` | `pto_budget` |
| `breakLengthProvider` | `StateProvider<BreakLengthRange>` | `(min: 3, max: 10)` | `break_min`, `break_max` |
| `weekendProvider` | `StateProvider<List<String>>` | `['sat','sun']` | `weekend` |

`BreakLengthRange` is a tiny immutable value class (`int min`, `int max`, `==`/`hashCode`,
`copyWith`). Persisted as two ints (get_storage stores primitives cleanly); the provider's
`listenSelf` writes both keys. `weekendProvider` stores a `List<String>` (get_storage supports lists).

New `StorageKeys`: `ptoBudget = 'pto_budget'`, `breakMin = 'break_min'`, `breakMax = 'break_max'`,
`weekend = 'weekend'`.

## Wiring into the API layer

- **`PlanQuery`** (`plan_provider.dart`): add `final List<String> workweek;` (default `const []`).
  Include it in `==`/`hashCode`. `planProvider` passes it to `getPlan`.
- **`getPlan`** (`api_client.dart`): add `List<String>? workweek` param; in `queryParameters` add
  `if (workweek != null && workweek.isNotEmpty) 'workweek': workweek.join(',')` (mirrors the existing
  `getSandwiches` treatment).
- **`SandwichesQuery`** (`sandwiches_provider.dart`): add `final List<String> workweek;`
  (default `const []`); include in `==`/`hashCode`. `sandwichesProvider` passes it.
  `getSandwiches` already accepts `workweek` — no client change needed there.
- **`plan_screen.dart`**: build `PlanQuery` from `ref.watch` of `selectedCountry`, `selectedYear`,
  `ptoBudget`, `breakLength`, `weekend` — no hardcoded `15`. Subtitle reflects the live budget.
- **`sandwich_screen.dart`**: build `SandwichesQuery` with `workweek` from `weekendProvider`.

## UI — one shared editor sheet, two entry points

**`PreferencesEditorSheet`** (`lib/widgets/preferences_editor_sheet.dart`), a `ConsumerWidget` shown
via `showModalBottomSheet`:
- **PTO budget**: a `−  value  +` stepper, clamped 0–40.
- **Break length**: a `RangeSlider` (2–21), values `min..max`; enforces `min ≤ max`.
- **Weekend (days off)**: seven `FilterChip`s Mon…Sun; toggling updates the list; require **1–6**
  selected (cannot pick 0 days off or all 7).

Each control writes to its provider immediately (consistent with the existing theme toggle). Because
`planProvider`/`sandwichesProvider` are `FutureProvider.family` keyed on the query, the screens
re-fetch automatically when a watched provider changes. The sheet has a "Done" button that just pops.

A helper `void showPreferencesEditor(BuildContext)` wraps `showModalBottomSheet`, used by both
entry points.

**Settings** (`settings_screen.dart`): replace the three static `_ValueRow`s with **tappable** rows
(use `onTap` on `ListTile`) that display current values and open the editor:
- Country of work — unchanged (display-only for now; country is edited via the picker elsewhere).
- **Weekend** — shows e.g. "Sat, Sun" (relabeled from "Workweek").
- **PTO budget** — shows e.g. "15 days".
- **Break length** — new row, shows e.g. "3–10 days".

**Plan** (`plan_screen.dart`): an **"Adjust"** `TextButton.icon` (tune icon) in the header area opens
the same sheet via `showPreferencesEditor(context)`.

## Defaults & test safety

Coded defaults are identical to today's behavior (15 / 3–10 / sat,sun). In tests `storageReady` is
`false`, so providers return those coded defaults. The break-length and budget values stay 3/10/15,
so the plan trips returned are identical; the only request-shape change is that **both** the plan and
sandwich requests will now include `workweek=sat,sun` (previously neither sent it, relying on the
backend default of the same value — so the responses are equivalent). Sandwich and plan widget tests
inject a fake `ApiClient` and override the relevant providers, asserting on the returned response
objects rather than query strings, so the added param does not ripple. The one mechanical touch-up: any test that
constructs `PlanQuery` must still compile after the new `workweek` field is added (it has a default,
so positional/named construction is unaffected).

## Testing

- **Unit** (`test/providers/`): each new provider returns its coded default when `storageReady` is
  false; `BreakLengthRange` equality/`copyWith`.
- **Widget** (`test/widgets/preferences_editor_sheet_test.dart`): sheet renders the three controls;
  tapping `+` raises budget; dragging/ setting the range updates `breakLength`; toggling a day chip
  updates `weekend`; the 1–6 weekend constraint holds.
- **Widget** (`test/screens/settings/`): the three rows show current provider values and open the
  sheet on tap; the row reads "Weekend" not "Workweek".
- **Widget** (`test/screens/plan/`): the "Adjust" button opens the sheet.
- **Regression**: full `flutter test` green, `flutter analyze` clean.

## Out of scope

Country/year editing (already handled: picker + year stepper). Per-trip overrides. Server-side
persistence of preferences. Validation beyond the simple bounds above. Onboarding-time preference
setup.

## File summary

```
lib/core/storage_keys.dart                          MODIFY: + ptoBudget/breakMin/breakMax/weekend keys
lib/providers/preferences_provider.dart             NEW: ptoBudget/breakLength/weekend providers + BreakLengthRange
lib/providers/plan_provider.dart                    MODIFY: PlanQuery.workweek; pass to getPlan
lib/providers/sandwiches_provider.dart              MODIFY: SandwichesQuery.workweek; pass to getSandwiches
lib/api/api_client.dart                             MODIFY: getPlan gains workweek param
lib/widgets/preferences_editor_sheet.dart           NEW: shared editor + showPreferencesEditor()
lib/screens/settings/settings_screen.dart           MODIFY: tappable rows, relabel, + break-length row
lib/screens/plan/plan_screen.dart                   MODIFY: build query from providers; Adjust button
lib/screens/sandwich/sandwich_screen.dart           MODIFY: build query with weekend
test/providers/preferences_provider_test.dart       NEW
test/widgets/preferences_editor_sheet_test.dart     NEW
test/screens/settings/settings_screen_test.dart     MODIFY/NEW: rows reflect + open sheet
test/screens/plan/… (Adjust opens sheet)            MODIFY/NEW
```
