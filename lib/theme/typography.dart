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
