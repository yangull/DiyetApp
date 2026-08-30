import 'package:flutter/material.dart';

import 'tokens/app_colors.dart';
import 'tokens/app_density.dart';
import 'tokens/app_typography.dart';

/// The app ships light-only for now. Dark tokens are measured and documented
/// but not wired up: dark reads heavy for a health product, and following the
/// system theme hands the first impression to the user's phone setting.
///
/// [ColorScheme.fromSeed] is deliberately NOT used. It derives its own tonal
/// ramps from one seed and would not reproduce the measured values in
/// [AppColors]; every slot below is set explicitly instead.
abstract final class AppTheme {
  static ThemeData light(AppDensity density) {
    final text = AppTypography.textTheme(density);

    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primary,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceSubtle,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderStrong,
        outlineVariant: AppColors.borderSubtle,
      ),
      scaffoldBackgroundColor: AppColors.ground,
      textTheme: text,
      extensions: [AppPalette.light, density],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        // The colour has to be restated here: supplying titleTextStyle at all
        // stops foregroundColor from reaching the title, and AppTypography's
        // styles carry no colour of their own — so the title on every pushed
        // screen was rendering in the default, near-invisible on this ground.
        titleTextStyle: text.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(density.cardRadius),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Height is fixed, width is not: Size.fromHeight would set an
          // infinite width and break any button placed inside a Row.
          // Full-width buttons stretch at the call site instead.
          minimumSize: Size(64, density.controlHeight),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(density.controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        constraints: BoxConstraints(minHeight: density.inputHeight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(density.controlRadius),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(density.controlRadius),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(density.controlRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  AppDensity get density => Theme.of(this).extension<AppDensity>()!;
}
