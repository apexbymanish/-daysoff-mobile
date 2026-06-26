# Gesture Guidelines — Design Spec
**Date:** 2026-06-26  
**Approach:** Inline (Approach A) — all changes in their respective widgets, no new shared abstractions  
**Source spec:** GME Remit Gesture & Drag Guidelines (gme-gestures.html)

---

## Scope

Implement gesture standards, touch target compliance, and platform rules from the GME Remit interaction spec into daysoff-mobile. Covers three categories of work:

1. **Fix existing violations** — touch targets below 44pt/48dp minimum, missing accessibility close buttons on bottom sheets
2. **Add new gestures** — pull-to-refresh, swipe-left to save, long-press quick actions, horizontal fling carousel
3. **Platform rules** — no system gesture conflicts introduced; all new gestures verified against the conflict table

---

## Section 1: Touch Target Fixes

### Violations

| Location | Widget | Violation | Fix |
|---|---|---|---|
| `home_screen.dart` `_YearStepper` | `IconButton` (← and →) | `padding: EdgeInsets.zero` + `constraints: BoxConstraints()` collapses hit area | Remove both properties; let Material default (48×48dp) apply |
| `home_screen.dart` AppBar title | Globe `IconButton` | Same as above | Remove both properties |
| `plan/widgets/break_card.dart` | "Details ›" `TextButton` | `tapTargetSize: MaterialTapTargetSize.shrinkWrap` + `minimumSize: Size.zero` | Remove `tapTargetSize`, set `minimumSize: Size(44, 44)` |

### Rule
Minimum touch target: **44×44pt (iOS)** / **48×48dp (Android)**. Never override with `BoxConstraints()` or `shrinkWrap` unless visual size and tap area are separated via `contentShape`.

---

## Section 2: Bottom Sheet Close Buttons

### Problem
Both sheets (`day_detail_sheet.dart`, `preferences_editor_sheet.dart`) have `showDragHandle: true` but no visible close button. Swipe-only dismiss fails **WCAG 2.5.1 (Pointer Gestures)**.

### Fix — `day_detail_sheet.dart`
Add a `Row` header at the top of the sheet body:
- Left: date string (existing)
- Right: `IconButton(Icons.close)` → `Navigator.of(context).pop()`

### Fix — `preferences_editor_sheet.dart`
Add a `Row` header at the top of `PreferencesEditorSheet.build`:
- Left: "Preferences" label
- Right: `IconButton(Icons.close)` → `Navigator.of(context).pop()`
- The existing "Done" `TextButton` at the bottom stays — two dismiss paths.

### Dismiss behaviour (no custom code needed)
Flutter's `showModalBottomSheet` already handles:
- Swipe-down dismiss (velocity-based) ✓
- Dim-tap dismiss ✓

---

## Section 3: Pull-to-Refresh

### Where
`home_screen.dart` — `_HolidaysList`, wrapping the existing `CustomScrollView`.

### Implementation
```
RefreshIndicator(
  color: DaysoffColors.brandTeal,
  onRefresh: () async {
    ref.invalidate(holidaysProvider(query));
    await ref.read(holidaysProvider(query).future);
    ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Holidays updated'), duration: Duration(seconds: 2)));
  },
  child: CustomScrollView(...),
)
```

### Feedback
- Spinner visible during load (platform-native: overscroll indicator on iOS, circular on Android)
- On success: `SnackBar` "Holidays updated", auto-dismisses after 2s

### Conflict check
Pull-down refresh: **Safe** on both platforms. ✓

---

## Section 4: Swipe-Left → Save Break on Holiday Cards

### Where
`home_screen.dart` — each `HolidayCard` in `SliverList.builder`, wrapped in `Dismissible`.

### Implementation
```
Dismissible(
  key: ValueKey(h.date),
  direction: DismissDirection.endToStart,
  confirmDismiss: (_) async {
    // save the holiday as a break
    // show SnackBar "Break saved" with Undo
    return false; // keep card in list — holidays are read-only
  },
  background: Container(
    alignment: Alignment.centerRight,
    color: DaysoffColors.brandTeal,
    padding: EdgeInsets.only(right: 20),
    child: Row(children: [Icon(Icons.bookmark, color: Colors.white), Text('Save')]),
  ),
  child: HolidayCard(...),
)
```

### Key detail
`confirmDismiss` returns `false` — the card snaps back after the save action. Holidays are server data and must not be removed from the list.

### Accessibility fallback (WCAG 2.5.1)
"Save" button added inside `showDayDetailSheet` — visible tap alternative for the swipe action.

### Conflict check
Swipe-left on list row: **Safe** on both platforms. ✓

---

## Section 5: Long-Press Quick Actions on Holiday Cards

### Where
`home_screen.dart` — `HolidayCard`'s existing `InkWell`.

### Implementation
Add `onLongPress` to `InkWell`:
1. `HapticFeedback.mediumImpact()` — physical confirmation
2. `showModalBottomSheet` mini-menu with two `ListTile` rows:
   - **Save break** (bookmark icon) — same save logic as swipe-left
   - **Share** (share icon) — `Share.share('${h.name} · ${DateFormat('MMM d, y').format(h.date)}')` via `share_plus` package (must be added to `pubspec.yaml`)

### Accessibility fallback (WCAG 2.5.1)
`···` `IconButton` added to the trailing edge of `HolidayCard` — always visible, opens the same mini-sheet. Long-press is the shortcut, not the only path.

### Platform note
Bottom sheet used instead of a popover — Flutter has no native context-menu popover widget on Android; bottom sheet is consistent with Material 3.

---

## Section 6: Horizontal Fling on Plan Cards Carousel

### Where
`plan_screen.dart` — break cards carousel.

### Implementation
Replace current scroll with `PageView`:
```
PageView.builder(
  controller: PageController(viewportFraction: 0.88),
  physics: const PageScrollPhysics(),
  padEnds: true,
  itemCount: trips.length,
  itemBuilder: (_, i) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: BreakCard(trip: trips[i], ...),
  ),
)
```

### Visual
`viewportFraction: 0.88` — cards peek at the right edge signalling more content. No explicit arrow buttons needed for discovery.

### Accessibility fallback (WCAG 2.5.1)
`←` `→` `IconButton`s below the `PageView`, calling `pageController.previousPage(...)` / `nextPage(...)`. Shown/hidden based on current page index.

### Conflict check
Horizontal swipe on carousel: **Safe** on both platforms. ✓

---

## Platform Rules Summary

| Rule | This app |
|---|---|
| iOS left edge (system back) | No drawer — N/A. App uses bottom nav. |
| iOS home indicator (bottom 34pt) | Bottom nav is inside `SafeArea` ✓ |
| Android both edges (system back) | No drawer — N/A ✓ |
| Android bottom (home gesture) | Bottom nav inside `SafeArea` ✓ |
| Swipe up from bottom | Not used anywhere ✓ |

---

## Files Changed

| File | Change |
|---|---|
| `lib/screens/home/home_screen.dart` | Fix touch targets; add `RefreshIndicator`; wrap cards in `Dismissible`; add long-press + `···` button |
| `lib/screens/home/widgets/holiday_card.dart` | Add `onLongPress`, trailing `···` `IconButton` |
| `lib/screens/home/widgets/day_detail_sheet.dart` | Add × close button header; add "Save" button |
| `lib/widgets/preferences_editor_sheet.dart` | Add × close button header |
| `lib/screens/plan/plan_screen.dart` | Replace carousel with `PageView` + nav buttons |
| `lib/screens/plan/widgets/break_card.dart` | Fix "Details ›" touch target |
| `pubspec.yaml` | Add `share_plus: ^10.0.0` dependency |
