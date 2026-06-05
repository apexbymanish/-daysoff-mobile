import 'package:flutter/material.dart';

/// The design system's `label-caps` style — JetBrains Mono, wide tracking.
/// Callers uppercase the text themselves. The font is bundled (pubspec
/// `fonts:`), so it renders correctly offline and in tests.
TextStyle labelCaps({
  double fontSize = 12,
  Color? color,
  double letterSpacing = 1.0,
  FontWeight fontWeight = FontWeight.w500,
}) =>
    TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
    );
