# daysoff-mobile — TODO / Roadmap

Status as of 2026-06-04. The MVP app surface is **built, tested (44 tests), and merged to `main`**:
Onboarding · Holidays · Plan (+ break detail) · Sandwich · Saved breaks · Settings (+ dark mode) ·
selectable country/year · local persistence. Clean Riverpod + go_router + freezed architecture.

The items below were **deliberately deferred** — each needs something this codebase/sandbox can't
provide yet (a backend tier, a native plugin, or a real device to verify permission flows). They are
recorded here so nothing is silently dropped.

---

## Deferred — needs a real device to verify

### 1. Calendar write-back
Save a planned break / sandwich day straight into the device calendar (reversible).
- **Plugin:** `device_calendar` (new dependency).
- **Native config:** iOS `Info.plist` `NSCalendarsUsageDescription`; Android `READ_CALENDAR`/`WRITE_CALENDAR`.
- **Hook point:** `SavedBreak` already carries `start`/`end`/`label` — add an "Add to calendar" action on
  `saved_screen.dart` and/or `break_detail_screen.dart` that creates an event and stores the returned
  event id on the `SavedBreak` so it can be removed later.
- **Why deferred:** permission grant + actual event creation can only be confirmed on a physical device.

### 2. Reminders / local notifications
Notify before a saved break starts (this is the "remind" half of the old "Save + remind" label, which
currently ships as save-only).
- **Plugin:** `flutter_local_notifications` (+ `timezone`).
- **Native config:** iOS notification permission prompt; Android 13+ `POST_NOTIFICATIONS`, exact-alarm setup.
- **Hook point:** on `SavedBreaksNotifier.add`, schedule a notification N days before `start`; cancel it
  on `remove`.
- **Why deferred:** scheduling + delivery must be verified on a device; can't be unit-tested meaningfully.

---

## Blocked — needs backend work first

### 3. Auth / user accounts
- **Blocker:** `daysoff-api` is currently **public with no auth tier** (see its README — auth is a parked
  backend follow-up). There is nothing to authenticate against yet.
- **Order of work:** build the backend auth tier first, then add the mobile auth client + a gated profile
  area. A local-only stub would be theater and is intentionally NOT built.

---

## Cosmetic / nice-to-have

### 4. Onboarding hero asset
`onboarding_screen.dart` uses a teal→sage gradient placeholder. Swap in a real scenic photo asset
(bundle under `assets/`, register in `pubspec.yaml`) when art is available.

---

## Done (for reference — do not redo)
- ✅ Phase 3 Plan feature, Sandwich feature, app shell + Settings, dark mode
- ✅ Country selection (searchable picker) + year stepper, flowing into all features
- ✅ Onboarding (value-first Welcome), first-launch-only via persisted `onboardingSeen`
- ✅ Persistence (country / year / theme / onboarding / saved breaks) via `get_storage`,
  `storageReady`-guarded for zero test ripple
- ✅ Polish (per-country flags, dashed sandwich border, shared `classifyBreakDay`)
- ✅ Saved breaks (local) — save/remove breaks + sandwich days
