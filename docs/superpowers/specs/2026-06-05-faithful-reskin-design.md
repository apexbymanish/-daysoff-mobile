# Faithful Reskin — Home (6.1) + Break Detail (6.2)

**Date:** 2026-06-05 · **Status:** Approved (faithful reskin)

## Goal
Rebuild the Home timeline (6.1) and Break detail (6.2) to closely match the Stitch HTML (the source of
truth), replacing the looser adaptations shipped earlier.

## Source-of-truth facts (from the screens' generated HTML)
**6.1 Home — light.** bg `#f9f9f9`; cards white `#ffffff` with `outline-variant #c0c8c8` border, rounded
`xl`, subtle shadow. Header (64px, border-bottom): **globe icon + "daysoff" wordmark** (Manrope 24px
bold, teal) on the left; **year stepper** `‹ 2026 ›` (chevrons) center; **calendar_today** icon right.
Hero (240px, rounded-xl): scenery image + bottom scrim; "NEXT BREAK IN" (caps), big "17" + "Days",
"{holiday} · {date}", a translucent **"See details" pill** (white/20, border, caps). Month sections:
caps month header + divider line; each card row = date numeral (teal, extrabold) + weekday caps (+ a
"–DD WDY" range hint for multi-day) | name (20px) + native subtitle (14px) | a **status pill**:
`Free` = teal-tinted with `wb_sunny`; `Absorbed` = neutral, dimmed, with `bedtime`. Nav (mockup) is
3-tab — deferred to 6.7; this pass keeps the current nav.

**6.2 Break detail — dark, intrinsic.** Whole screen dark (`#14171A`). Header: gradient black→transparent,
`arrow_back` + "Break Details" + `share` (white). Hero `45vh`: scenery image + bottom scrim →`#14171A`;
overlay: "{N}-day break" (white) + sage "**{n} PTO**" pill, then "Sep 23 – Sep 27 • anchored on
**Chuseok / 추석**" (the anchor in sage). Body `#14171A`, rounded-top: "DAY-BY-DAY" caps; per-day row =
date (white) + an **overline** (`ORDINARY DAY` for PTO, `FESTIVAL` for holiday, `REST` for weekend) |
a **tag pill**: PTO = sage-tinted "PTO"; holiday = **korea-red-tinted "Holiday • {anchor}"**; weekend =
teal-tinted "Weekend". A summary card (white/5): event icon + "{n} PTO day(s) → {N} days off" +
"Maximize your time with public holidays". A full-width sage **"Save this break"** button.

## Decisions
- **6.2 is always dark** (cinematic detail screen), independent of the app theme.
- Home keeps a small **bookmark** action (→ /saved) for function (not in the mockup) and the country
  switch moves to the **globe icon** (→ country picker), dropping the country chip.
- The `calendar_today` icon drives the existing `holidaysViewProvider` (list ⇄ calendar).
- Add a `DaysoffColors.koreaRed = #CD2E3A` token for holiday tags.
- Native names come from `Holiday.nameLocal`; the anchor's native (6.2 hero) is looked up from
  `holidaysProvider` (client-side, graceful).

## Components
- **`lib/theme/colors.dart`**: + `koreaRed`.
- **`lib/screens/home/widgets/next_break_hero.dart`**: restyle to the 6.1 hero (caps label, 240h,
  "See details" pill).
- **`lib/screens/home/widgets/holiday_card.dart`**: white bordered card; teal date numeral + weekday;
  name + native subtitle; caps `Free`(wb_sunny)/`Absorbed`(bedtime) pill (weekend-aware).
- **`lib/screens/home/widgets/month_section.dart`**: caps header + divider line.
- **`lib/screens/home/home_screen.dart`**: new header (globe→picker, wordmark, year stepper,
  calendar_today→toggle, bookmark→/saved); cards grouped inside a white container per month.
- **`lib/screens/plan/break_detail_screen.dart`**: full dark rebuild per the 6.2 HTML (gradient header,
  45vh hero w/ summary overlay, dark body, overline day rows + colored tags, summary card, sage Save
  button). Keep the Save logic + the texts/keys the existing test needs.

## Testing
- Home: hero "NEXT BREAK IN" + "See details"; wordmark "daysoff"; a card shows native name + caps
  `Free`/`Absorbed` (weekend-aware via override); calendar_today toggles to the calendar view.
- Break detail: dark bg; "Break Details"; hero "5-day break" + "1 PTO"; day overlines (`ORDINARY DAY`/
  `FESTIVAL`/`REST`); a holiday row shows "Holiday • Chuseok" + native (with holidaysProvider override);
  Save still adds to `savedBreaksProvider`; existing assertions preserved.
- Regression: full `flutter test` + `flutter analyze` clean.

## Out of scope
3-tab nav + Sandwich merge (6.7); share button action; the "(N days)" multi-day range grouping
(show native subtitle instead); bottom-nav restyle.

## Files
```
lib/theme/colors.dart                                MODIFY (+ koreaRed)
lib/screens/home/widgets/next_break_hero.dart        MODIFY (6.1 hero styling)
lib/screens/home/widgets/holiday_card.dart           MODIFY (6.1 card styling)
lib/screens/home/widgets/month_section.dart          MODIFY (caps + divider)
lib/screens/home/home_screen.dart                    MODIFY (6.1 header + card grouping)
lib/screens/plan/break_detail_screen.dart            REWRITE (6.2 dark)
tests: home_card / hero / home header / break_detail  ADD/MODIFY
```
