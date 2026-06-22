import 'package:flutter/material.dart';

import 'colors.dart';

/// Material 3 theme for the daysoff app.
class DaysoffTheme {
  DaysoffTheme._();

  static ThemeData light() {
    // 60-30-10: creamSoft (#F5F3FF) is the 60% neutral surface.
    // Brand indigo (#312E81) is seeded as primary — M3 will derive tonal
    // palette from it; we pin the key roles explicitly below.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DaysoffColors.brandTeal,
      brightness: Brightness.light,
      primary: DaysoffColors.brandTeal,
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: DaysoffColors.oliveFixed,
      onPrimaryContainer: DaysoffColors.brandTeal,
      secondary: DaysoffColors.neutral700,
      surface: const Color(0xFFFFFFFF),
      onSurface: DaysoffColors.neutral900,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: DaysoffColors.creamSoft,
      textTheme: _textTheme(Brightness.light).apply(fontFamily: 'Manrope'),
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
      primary: DaysoffColors.indigoContainer,
      secondary: DaysoffColors.neutral500,
      surface: DaysoffColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: DaysoffColors.darkBackground,
      textTheme: _textTheme(Brightness.dark).apply(fontFamily: 'Manrope'),
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
