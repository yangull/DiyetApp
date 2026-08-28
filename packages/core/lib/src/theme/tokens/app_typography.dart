import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_density.dart';

/// Fraunces for headings, Figtree for everything else. Both are SIL OFL and
/// both were verified at the cmap level to carry all twelve Turkish glyphs
/// (ı İ ğ Ğ ş Ş ç Ç ö Ö ü Ü).
///
/// The serif is for headings only — never body text, tables or buttons.
// TODO: bundle the font files as assets before release; google_fonts fetches
// them at runtime, which costs a first-load flash and fails offline.
abstract final class AppTypography {
  static TextStyle _serif(double size, double lineHeight) =>
      GoogleFonts.fraunces(
        fontSize: size,
        height: lineHeight / size,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  static TextStyle _sans(
    double size,
    double lineHeight, [
    FontWeight weight = FontWeight.w400,
  ]) => GoogleFonts.figtree(
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
  );

  static TextTheme textTheme(AppDensity density) {
    final c = density.isCompact;
    return TextTheme(
      displaySmall: _serif(34, 40),
      headlineLarge: _serif(c ? 22 : 27, c ? 28 : 34),
      headlineMedium: _serif(c ? 18 : 22, c ? 24 : 28),
      titleLarge: _sans(c ? 16 : 18, c ? 22 : 24, FontWeight.w600),
      titleMedium: _sans(c ? 14 : 16, c ? 20 : 24, FontWeight.w600),
      bodyLarge: _sans(c ? 14 : 16, c ? 20 : 24),
      bodyMedium: _sans(c ? 13 : 14, c ? 18 : 20),
      bodySmall: _sans(c ? 12 : 13, c ? 16 : 18),
      labelLarge: _sans(c ? 13.5 : 15, c ? 18 : 20, FontWeight.w600),
      labelSmall: _sans(11, 16, FontWeight.w600).copyWith(letterSpacing: 0.88),
    );
  }
}
