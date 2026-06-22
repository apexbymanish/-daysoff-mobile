import 'package:flutter/material.dart';

/// daysoff color tokens — Indigo theme.
///
/// Design system: 60-30-10 rule. Brand indigo (#312E81) appears only where it
/// carries meaning: PTO day cells, the Save button, and key numerals.
/// Holiday red (#991B1B) is semantic and fixed across themes. 90% of visible
/// pixels are neutral grey (#F5F3FF) or white.
///
/// All text/background pairs verified WCAG 2.1 AAA (≥ 7:1).
class DaysoffColors {
  DaysoffColors._();

  // ── Brand (10%) ─────────────────────────────────────────────────────────
  // #312E81 on white: 11.42:1 AAA. White on #312E81: 11.42:1 AAA.
  static const Color brandTeal = Color(0xFF312E81); // named brandTeal for compat
  static const Color brandTealDark = Color(0xFF21207A);

  // ── Surfaces (60% neutral + 30% card) ───────────────────────────────────
  // App background / list surfaces — very light violet tint.
  static const Color creamSoft = Color(0xFFF5F3FF); // 60% neutral surface
  static const Color cream = Color(0xFFEDE9FF);     // slightly deeper tint

  // ── PTO semantic tokens ──────────────────────────────────────────────────
  // PTO pill bg / day-cell tint (#E0E7FF) → brand text on it: 9.58:1 AAA.
  static const Color oliveFixed = Color(0xFFE0E7FF); // PTO surface (pill bg, cell bg)
  static const Color olive = Color(0xFF312E81);      // PTO foreground = brand

  // ── Holiday semantic tokens (fixed across all themes) ────────────────────
  // #991B1B on #FEF2F2: 7.60:1 AAA.
  static const Color koreaRed = Color(0xFF991B1B);      // holiday text
  static const Color holidaySurface = Color(0xFFFEF2F2); // holiday cell bg

  // ── Neutrals ────────────────────────────────────────────────────────────
  // #111827 on white: 17.74:1 AAA. #4B5563 on white: 7.55:1 AAA.
  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral700 = Color(0xFF4B5563);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral100 = Color(0xFFF5F3FF);
  static const Color outlineVariant = Color(0xFFD1D5DB);

  // ── Dark mode ────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0B0D0E);
  static const Color darkSurface = Color(0xFF14171A);

  // ── Semantic / error ─────────────────────────────────────────────────────
  static const Color danger = Color(0xFF991B1B);
  static const Color dangerDark = Color(0xFFB91C1C);

  // ── Legacy aliases (kept to avoid widespread widget refactor) ────────────
  static const Color peach = Color(0xFFE0E7FF);      // was warm peach, now PTO tint
  static const Color peachDark = Color(0xFFB8C5FF);
  static const Color sage = Color(0xFF6B7280);        // was green, now neutral
  static const Color sageDark = Color(0xFF4B5563);
  static const Color indigo = Color(0xFF312E81);
  static const Color indigoContainer = Color(0xFFE0E7FF);
  static const Color redContainer = Color(0xFFFEF2F2);
  static const Color onRedContainer = Color(0xFF991B1B);
  static const Color surfaceContainerHigh = Color(0xFFEDE9FF);
  static const Color surfaceContainerLow = Color(0xFFF5F3FF);
  static const Color surfaceVariant = Color(0xFFEDE9FF);
  static const Color oliveFixedDim = Color(0xFFB8C5FF);
}
