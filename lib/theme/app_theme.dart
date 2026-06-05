import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Material 3 theme for the daysoff app.
class DaysoffTheme {
  DaysoffTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DaysoffColors.brandTeal,
      brightness: Brightness.light,
      primary: DaysoffColors.brandTeal,
      secondary: DaysoffColors.sage,
      tertiary: DaysoffColors.peach,
      surface: DaysoffColors.creamSoft,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DaysoffColors.creamSoft,
      textTheme: GoogleFonts.manropeTextTheme(_textTheme(Brightness.light)),
      appBarTheme: AppBarTheme(
        backgroundColor: DaysoffColors.creamSoft,
        foregroundColor: DaysoffColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DaysoffColors.brandTeal,
      brightness: Brightness.dark,
      primary: DaysoffColors.sage,
      secondary: DaysoffColors.peach,
      surface: DaysoffColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DaysoffColors.darkBackground,
      textTheme: GoogleFonts.manropeTextTheme(_textTheme(Brightness.dark)),
      appBarTheme: const AppBarTheme(
        backgroundColor: DaysoffColors.darkBackground,
        foregroundColor: DaysoffColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? Typography.blackMountainView
        : Typography.whiteMountainView;
    return base.copyWith(
      // Date numerals — big, semibold
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
