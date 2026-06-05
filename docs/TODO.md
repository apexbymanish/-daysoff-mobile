# daysoff-mobile — TODO / Roadmap

Updated 2026-06-05. The app is built, tested (**106 tests**), and pushed to `main`. Core surface:
Onboarding · Holidays (timeline **+ calendar**, upcoming-only window, tap→calendar) · Plan
(length-buffet carousel **+ Sandwich-days toggle**, longest-first top-8 options) · Break detail ·
Saved breaks · Settings · selectable country/year · prefs (budget/length/weekend) · persistence ·
light/dark. **Full faithful Stitch 6.x redesign done** (typography Manrope + JetBrains Mono; 6.1 Home,
6.2 Break detail, 6.3 Destinations, 6.4 Calendar, 6.6 Plan, 6.7 3-tab nav + Sandwich merge, 6.8
Settings). Riverpod + go_router + freezed.

## Pending — UI follow-ups (from the 2026-06-05 data review)

### 1. News-detected ("tentative") holidays — mark or hide (depends on backend TODO #1)
The backend currently returns unconfirmed `source == 'news'` holidays (e.g. KR 2026 Jun 5 / Jun 8
`임시공휴일 (news-detected)`). The calendar + list mark them **identically to official days off** (same
sun marker / FREE pill) — misleading. Once the backend is switched to the official source (see
`daysoff-api/docs/TODO.md` #1) these vanish. If any "tentative" source remains, surface it distinctly:
a different calendar marker + a "tentative · from news" tag in the day-summary card / list row, OR
filter them out client-side. (The `Holiday` model already carries `source`; it's just not surfaced
in the UI.)

### 2. Calendar — selection should follow month navigation
On the Holidays calendar, the inline day-summary card shows the **last-selected day even after you page
to another month** (e.g. grid on June 2026 but card reads "Fri Jul 17"). Fix: on month change
(`onPageChanged`) reset/retarget the selected day to the visible month (or only show the summary card
when the selected day is within the focused month). `holiday_calendar_view.dart`
(`_focused`/`_selected`).

### 3. (Optional) Commemorative days that aren't days off
e.g. 제헌절 (Constitution Day, Jul 17) is a real Korean commemorative day but **not a public holiday**
since 2008 — the `holidays` library doesn't carry it, so the app (correctly, for a *days-off* planner)
omits it. If "completeness" is wanted, add a small curated "observed (not a day off)" list, clearly
labeled and visually distinct from days off. Low priority (adds noise to a days-off planner).

## Deferred — needs device / backend (unchanged)
- **Calendar write-back** (`device_calendar`) + **reminders** (`flutter_local_notifications`) — need a
  real device to verify permission flows.
- **Auth / Profile (6.5)** — blocked on the backend auth tier (`daysoff-api` is public; see its TODO).
- **Onboarding hero photo** — gradient placeholder for now.

## Done (do not redo)
- Plan preferences, holiday calendar, saved breaks, persistence, polish.
- Localized holiday names (`name_local`) — backend + mobile display.
- Full faithful 6.x redesign + typography + macOS desktop scaffold (committed).
- Upcoming-only Holidays list capped at the longest **upcoming** break; tap→calendar; Plan options
  sorted longest-first (top 8).
