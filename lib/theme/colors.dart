import 'package:flutter/material.dart';

/// daysoff color tokens.
///
/// Sourced from docs/stitch/master.md — warm, calm palette:
/// deep teal brand, peach for "free" days, sage green for PTO/off-days,
/// warm cream for surfaces.
class DaysoffColors {
  DaysoffColors._();

  // Brand
  static const Color brandTeal = Color(0xFF0A4A4F);
  static const Color brandTealDark = Color(0xFF073439);

  // Accents
  static const Color peach = Color(0xFFF5B591);
  static const Color peachDark = Color(0xFFE39A78);
  static const Color sage = Color(0xFF9CAF88);
  static const Color sageDark = Color(0xFF7D9070);

  // Neutrals — warm
  static const Color cream = Color(0xFFF4ECD8);
  static const Color creamSoft = Color(0xFFFBF7EE);

  // Neutrals — cool
  static const Color neutral900 = Color(0xFF1A1D1F);
  static const Color neutral700 = Color(0xFF4B5256);
  static const Color neutral500 = Color(0xFF8B9197);
  static const Color neutral300 = Color(0xFFD4D8DB);
  static const Color neutral100 = Color(0xFFF1F3F4);
  static const Color outlineVariant = Color(0xFFC0C8C8);

  // Dark mode
  static const Color darkBackground = Color(0xFF0B0D0E);
  static const Color darkSurface = Color(0xFF14171A);

  // Semantic
  static const Color danger = Color(0xFFB54545);
  static const Color dangerDark = Color(0xFFD66B6B);

  // Regional accent — Korea-red, for holiday tags (matches Stitch 6.x).
  static const Color koreaRed = Color(0xFFCD2E3A);

  // Plan (6.6) accents — indigo = holiday blocks, olive = PTO blocks.
  static const Color indigo = Color(0xFF4858AB); // secondary
  static const Color indigoContainer = Color(0xFF96A5FF); // secondary-container
  static const Color olive = Color(0xFF2B3218); // tertiary
  static const Color oliveFixed = Color(0xFFDEE7C0); // tertiary-fixed
  static const Color redContainer = Color(0xFFFFDAD6); // error-container
  static const Color onRedContainer = Color(0xFF93000A); // on-error-container
  static const Color surfaceContainerHigh = Color(0xFFE7E8E8);
  static const Color surfaceContainerLow = Color(0xFFF3F4F3);
}
