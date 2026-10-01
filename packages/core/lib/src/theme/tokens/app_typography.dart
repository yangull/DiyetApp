import 'package:flutter/material.dart';

import 'app_density.dart';

/// One family, Alpino (PLANNING #135), from its variable file: Flutter maps
/// [FontWeight] onto the wght axis, so 400, 500 and 600 come from one asset.
/// Headings and numbers 600, buttons and navigation 500, body 400; nothing
/// above 600. All Turkish letters were verified in the file's cmap.
///
/// Sizes are HIG's: iOS for touch, macOS (11 as the floor) for the compact
/// panel. Line heights stay at or above 1.18 em, above Alpino's 1.14 em of
/// ink, with Flutter's default proportional leading so İ and ş never clip.
///
/// Bundled in `packages/core/fonts` with its licence, unmodified (no
/// subsetting or conversion, as the licence requires); never fetched at
/// runtime (#63).
abstract final class AppTypography {
  static const _family = 'Alpino';
  static const _package = 'core';

  static TextStyle _style(
    double size,
    double lineHeight, [
    FontWeight weight = FontWeight.w400,
    double tracking = 0,
  ]) => TextStyle(
    fontFamily: _family,
    package: _package,
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    letterSpacing: tracking,
  );

  /// Every number the user reads as data: counts, kcal, kg, times. Alpino 600.
  /// Alpino has no tabular figures, so numbers that must line up sit in a
  /// fixed-width, right-aligned slot (was C39).
  static TextStyle figures(double size, double lineHeight) =>
      _style(size, lineHeight, FontWeight.w600, size >= 28 ? -0.5 : 0);

  static TextTheme textTheme(AppDensity density) {
    if (density.isCompact) {
      final largeTitle = _style(26, 32, FontWeight.w600, -0.4);
      return TextTheme(
        displayLarge: largeTitle,
        displayMedium: largeTitle,
        displaySmall: largeTitle,
        headlineLarge: _style(22, 26, FontWeight.w600, -0.3),
        headlineMedium: _style(17, 22, FontWeight.w600),
        headlineSmall: _style(15, 20, FontWeight.w600),
        titleLarge: _style(13, 16, FontWeight.w600),
        titleMedium: _style(12, 15, FontWeight.w600),
        titleSmall: _style(11, 14, FontWeight.w600),
        bodyLarge: _style(13, 16),
        bodyMedium: _style(12, 15),
        bodySmall: _style(11, 14),
        labelLarge: _style(13, 16, FontWeight.w500),
        labelMedium: _style(11, 14, FontWeight.w500),
        labelSmall: _style(11, 14, FontWeight.w600, 0.2),
      );
    }
    final largeTitle = _style(34, 41, FontWeight.w600, -0.7);
    return TextTheme(
      // The date and time pickers read the display slots; left empty they
      // fall back to Material's font.
      displayLarge: largeTitle,
      displayMedium: largeTitle,
      displaySmall: largeTitle,
      headlineLarge: _style(28, 34, FontWeight.w600, -0.5),
      headlineMedium: _style(22, 28, FontWeight.w600, -0.3),
      // AlertDialog titles resolve to headlineSmall.
      headlineSmall: _style(20, 25, FontWeight.w600, -0.2),
      titleLarge: _style(17, 22, FontWeight.w600),
      titleMedium: _style(16, 21, FontWeight.w600),
      titleSmall: _style(15, 20, FontWeight.w600),
      bodyLarge: _style(17, 22),
      bodyMedium: _style(15, 20),
      bodySmall: _style(13, 18),
      labelLarge: _style(16, 21, FontWeight.w500),
      // NavigationBar and NavigationRail labels resolve to labelMedium.
      labelMedium: _style(12, 16, FontWeight.w500),
      labelSmall: _style(12, 16, FontWeight.w600, 0.2),
    );
  }
}
