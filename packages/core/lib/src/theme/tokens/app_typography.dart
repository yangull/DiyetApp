import 'package:flutter/material.dart';

import 'app_density.dart';

/// One family, Figtree, for everything ("Sade", PLANNING #133): headings in
/// bold, body in regular, numbers in bold with tabular figures ([figures]).
/// It was verified at the cmap level to carry all twelve Turkish glyphs
/// (ı İ ğ Ğ ş Ş ç Ç ö Ö ü Ü). Fraunces is still bundled but no longer used.
///
/// The files ship as assets in `packages/core/fonts` (latin + latin-ext
/// subsets, licences alongside them). Nothing is fetched at runtime, so the
/// panel renders identically offline and there is no first-load flash.
abstract final class AppTypography {
  static const _sansFamily = 'Figtree';
  static const _package = 'core';

  /// Headings: bold and slightly tight, the way large sans type reads best.
  static TextStyle _heading(double size, double lineHeight) =>
      _sans(size, lineHeight, FontWeight.w700).copyWith(letterSpacing: -0.3);

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

  /// Every number the user reads as data: counts, kcal, kg, times (#132).
  /// Figtree 700 with tabular figures, so digits keep their width.
  static TextStyle figures(double size, double lineHeight) => _sans(
    size,
    lineHeight,
    FontWeight.w700,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextTheme textTheme(AppDensity density) {
    final c = density.isCompact;
    return TextTheme(
      displaySmall: _heading(32, 38),
      headlineLarge: _heading(c ? 22 : 28, c ? 28 : 34),
      headlineMedium: _heading(c ? 18 : 22, c ? 24 : 28),
      titleLarge: _sans(c ? 16 : 18, c ? 22 : 24, FontWeight.w600),
      titleMedium: _sans(c ? 14 : 16, c ? 20 : 24, FontWeight.w600),
      bodyLarge: _sans(c ? 14 : 16, c ? 20 : 24),
      bodyMedium: _sans(c ? 13 : 14, c ? 18 : 20),
      bodySmall: _sans(c ? 12 : 13, c ? 16 : 18),
      labelLarge: _sans(c ? 13.5 : 15, c ? 18 : 20, FontWeight.w600),
      // NavigationRail labels resolve to labelMedium. Leaving the slot empty
      // did not fall back to Figtree — it fell back to Material's own default,
      // so the panel's rail was the one piece of chrome not in our type.
      labelMedium: _sans(c ? 12 : 13, c ? 16 : 18, FontWeight.w600),
      labelSmall: _sans(11, 16, FontWeight.w600).copyWith(letterSpacing: 0.88),
    );
  }
}
