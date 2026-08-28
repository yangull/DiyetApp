import 'package:flutter/material.dart';

import 'app_density.dart';

/// Fraunces for headings, Figtree for everything else. Both are SIL OFL and
/// both were verified at the cmap level to carry all twelve Turkish glyphs
/// (ı İ ğ Ğ ş Ş ç Ç ö Ö ü Ü).
///
/// The serif is for headings only — never body text, tables or buttons.
///
/// The files ship as assets in `packages/core/fonts` (latin + latin-ext
/// subsets, licences alongside them). Nothing is fetched at runtime, so the
/// panel renders identically offline and there is no first-load flash.
abstract final class AppTypography {
  static const _serifFamily = 'Fraunces';
  static const _sansFamily = 'Figtree';
  static const _package = 'core';

  static TextStyle _serif(double size, double lineHeight) => TextStyle(
    fontFamily: _serifFamily,
    package: _package,
    fontSize: size,
    height: lineHeight / size,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static TextStyle _sans(
    double size,
    double lineHeight, [
    FontWeight weight = FontWeight.w400,
  ]) => TextStyle(
    fontFamily: _sansFamily,
    package: _package,
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
