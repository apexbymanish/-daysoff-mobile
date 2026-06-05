# Typography Fidelity Plan (Manrope + JetBrains Mono)

> REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** Match the "Serene Interval" type system — **Manrope** as the app-wide font and **JetBrains Mono** for the caps labels — and fix the 6.2 overline/label color to `#C0C8C8`.

**Why:** `app_theme.dart` currently uses `Typography.black/whiteMountainView` (default Roboto). The Stitch designs use Manrope + JetBrains Mono (`font-label-caps`). This is an app-wide typography gap.

**Repo:** `/Users/manishadhikari/Documents/Projects/daysoff-mobile`, branch **`feat/typography-fidelity`**. Baseline: 82 tests, analyzer clean. Add the `google_fonts` package (runtime-fetched fonts; falls back gracefully in tests).

---

## Task 1: Fonts in the theme + helpers + tokens

**Files:** `pubspec.yaml` (via pub add), `lib/theme/app_theme.dart`, `lib/theme/typography.dart` (new), `lib/theme/colors.dart`; test `test/theme/typography_test.dart` (new)

- [ ] **Step 1:** `flutter pub add google_fonts` then `flutter pub get`.
- [ ] **Step 2: failing test** — `test/theme/typography_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/theme/app_theme.dart';
import 'package:daysoff_mobile/theme/typography.dart';

void main() {
  test('base text theme is Manrope', () {
    final f = DaysoffTheme.light().textTheme.bodyLarge!.fontFamily ?? '';
    expect(f.toLowerCase(), contains('manrope'));
  });
  test('labelCaps is JetBrains Mono', () {
    expect((labelCaps().fontFamily ?? '').toLowerCase(), contains('jetbrains'));
  });
}
```
- [ ] **Step 3:** run → FAIL.
- [ ] **Step 4a: `lib/theme/typography.dart`**:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The design system's `label-caps` style — JetBrains Mono, wide tracking.
/// Callers uppercase the text themselves.
TextStyle labelCaps({
  double fontSize = 12,
  Color? color,
  double letterSpacing = 1.0,
  FontWeight fontWeight = FontWeight.w500,
}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
    );
```
- [ ] **Step 4b: `lib/theme/colors.dart`** — add `static const Color outlineVariant = Color(0xFFC0C8C8);` near the neutrals.
- [ ] **Step 4c: `lib/theme/app_theme.dart`** — import google_fonts; wrap the text theme with Manrope in BOTH `light()` and `dark()`:
  change `textTheme: _textTheme(Brightness.light),` → `textTheme: GoogleFonts.manropeTextTheme(_textTheme(Brightness.light)),` and the dark equivalent. (Keep `_textTheme` + its weight overrides.)
- [ ] **Step 5:** run `flutter test test/theme/typography_test.dart` → PASS. Then full `flutter test` + `flutter analyze`. If google_fonts runtime-fetch warnings cause any test to FAIL, add a `flutter_test_config.dart` at `test/` that sets `GoogleFonts.config.allowRuntimeFetching = false;` (this silences fetch + uses fallback metrics) and report it.
- [ ] **Step 6: commit** — `git add -A && git commit -m "feat(theme): Manrope base font + JetBrains Mono labelCaps + outlineVariant token"`

---

## Task 2: Apply labelCaps + outlineVariant to the 6.1/6.2 caps labels

**Files:** `lib/screens/home/widgets/next_break_hero.dart`, `lib/screens/home/widgets/holiday_card.dart`, `lib/screens/home/widgets/month_section.dart`, `lib/screens/plan/break_detail_screen.dart`. Adjust the affected existing tests only if a text assertion breaks (text content is unchanged, so they shouldn't).

Replace the hand-styled caps `TextStyle`s with `labelCaps(...)` (import `../../../theme/typography.dart`), preserving each label's size/color/weight intent:

- **next_break_hero.dart:** "NEXT BREAK IN" → `labelCaps(fontSize: 10, color: Colors.white70, letterSpacing: 1.5, fontWeight: FontWeight.w600)`; "See details" pill label → `labelCaps(fontSize: 11, color: Colors.white)` (uppercase the text).
- **holiday_card.dart:** weekday (`MON`) → `labelCaps(fontSize: 10, color: DaysoffColors.neutral700, letterSpacing: 0.8)`; the `Free`/`Absorbed` pill text → `labelCaps(fontSize: 10, color: <teal/neutral700>, fontWeight: FontWeight.w700)` (keep uppercase 'FREE'/'ABSORBED' OR 'Free'/'Absorbed' — KEEP the current 'Free'/'Absorbed' casing so `holiday_card_test` still matches).
- **month_section.dart:** month name → `labelCaps(fontSize: 12, color: DaysoffColors.neutral700, letterSpacing: 1.2)` (uppercased).
- **break_detail_screen.dart:** "DAY-BY-DAY" → `labelCaps(fontSize: 12, color: DaysoffColors.outlineVariant, letterSpacing: 1.0)`; each day **overline** ("ORDINARY DAY"/"FESTIVAL"/"REST") → `labelCaps(fontSize: 11, color: DaysoffColors.outlineVariant, letterSpacing: 0.8)` (CHANGE the color from `#8B9197` to `outlineVariant`); the **tag** text → `labelCaps(fontSize: 11, color: Color(0xFFFDFBF7), letterSpacing: 0.8)`; the hero **"{n} PTO"** pill → `labelCaps(fontSize: 10, color: Colors.white)`; the summary subtitle "Maximize your time…" → set its color to `DaysoffColors.outlineVariant` (keep body font).

- [ ] **Step 1:** Make the edits above (do NOT change any visible text content; only fontFamily via labelCaps + the overline/DAY-BY-DAY/summary color → `outlineVariant`).
- [ ] **Step 2: full gate** — `flutter test` (expect 84: 82 + 2 theme) and `flutter analyze` (clean). All existing screen tests must still pass (text unchanged). Report any test touched.
- [ ] **Step 3: commit** — `git add -A lib/screens && git commit -m "feat(home,plan): JetBrains Mono caps labels + outlineVariant color on 6.1/6.2"`

---

## Self-review
- **Coverage:** Manrope app-wide (T1); JetBrains Mono labelCaps helper + applied to all caps labels (T1+T2); outlineVariant token + 6.2 overline/label color fix (T1+T2).
- **Placeholders:** none.
- **Types:** `labelCaps({fontSize,color,letterSpacing,fontWeight})→TextStyle`; `DaysoffColors.outlineVariant`; `GoogleFonts.manropeTextTheme(base)`. Visible text strings unchanged so widget tests' `find.text` keep matching.

## Done when
`flutter test && flutter analyze` clean; the app renders in Manrope, the caps labels (NEXT BREAK IN, FREE/ABSORBED, month headers, DAY-BY-DAY, overlines, tags, PTO pill) render in JetBrains Mono, and the 6.2 overline/label color is `#C0C8C8`.
