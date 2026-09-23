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
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(density.controlRadius),
    );
    // Padding is derived from the input token rather than fixed, so a text
    // field, a dropdown and a chip beside it come out the same height. A fixed
    // 12 px made the panel's fields 44 px tall next to 36 px buttons.
    final inputText = text.bodyLarge!;
    final inputVertical =
        (density.inputHeight - inputText.fontSize! * inputText.height!) / 2;

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
      // AppDensity is the density system. Left alone, Flutter adds its own
      // on desktop (VisualDensity.compact), which took 8 px off every
      // control: the panel's 36 px buttons rendered 28 px tall in a Windows
      // browser. The panel is mouse-driven, so it also drops the 48 px touch
      // padding that made chips and buttons different heights.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: density.isCompact
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
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
          shape: controlShape,
        ),
      ),
      // Without these, outlined and text buttons kept Material's pill shape
      // next to the square-cornered filled button.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(64, density.controlHeight),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.borderStrong),
          textStyle: text.labelLarge,
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(48, density.controlHeight),
          foregroundColor: AppColors.primary,
          textStyle: text.labelLarge,
          shape: controlShape,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: controlShape,
        side: const BorderSide(color: AppColors.borderStrong),
        labelStyle: text.labelLarge?.copyWith(color: AppColors.textPrimary),
        // The chip adds 2 px of its own above and below the label.
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical:
              (density.inputHeight -
                      text.labelLarge!.fontSize! * text.labelLarge!.height!) /
                  2 -
              2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        // A non-dense field has a 48 px floor of its own, above inputHeight.
        isDense: density.isCompact,
        constraints: BoxConstraints(minHeight: density.inputHeight),
        // Icon slots default to 48 px square, which overrode inputHeight on
        // any field with a search icon or a dropdown arrow.
        prefixIconConstraints: BoxConstraints(
          minWidth: density.inputHeight,
          minHeight: density.inputHeight,
        ),
        suffixIconConstraints: BoxConstraints(
          minWidth: density.inputHeight,
          minHeight: density.inputHeight,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: inputVertical,
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
