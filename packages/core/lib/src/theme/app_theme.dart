import 'package:flutter/material.dart';

import 'tokens/app_colors.dart';
import 'tokens/app_density.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_typography.dart';

/// The app ships light-only for now (C43).
///
/// [ColorScheme.fromSeed] is deliberately NOT used. It derives its own tonal
/// ramps from one seed and would not reproduce the measured values in
/// [AppColors]; every slot below is set explicitly instead.
abstract final class AppTheme {
  /// The confirm button of a destructive dialog ("İptal et", "Sıfırla"): red.
  /// White on it is 6.01:1.
  static final destructiveButton = FilledButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: AppColors.onFilled,
  ).copyWith(overlayColor: overlay);

  /// Hover, focus and press darken whatever sits below, and text must keep
  /// 4.5:1 in every state. Capped at Ink 4 % (hover) and 8 % (focus, press):
  /// every ratio in [AppColors] was measured on a Cloud Card under 8 %.
  static const hoverOverlay = Color(0x0A222326);
  static const pressOverlay = Color(0x14222326);

  /// The capped Ink overlay, for a button styled at the call site:
  /// `TextButton.styleFrom(...).copyWith(overlayColor: AppTheme.overlay)`.
  static final WidgetStateProperty<Color?> overlay =
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return pressOverlay;
        }
        if (states.contains(WidgetState.hovered)) return hoverOverlay;
        return null;
      });

  static ThemeData light(AppDensity density) {
    final text = AppTypography.textTheme(density);
    final pill = const StadiumBorder();
    final inputRadius = BorderRadius.circular(density.controlRadius);
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(density.cardRadius),
    );
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: density.isCompact ? AppSpacing.lg : AppSpacing.xl,
    );
    // Padding is derived from the input token rather than fixed, so a text
    // field, a dropdown and a chip beside it come out the same height.
    final inputText = text.bodyLarge!;
    final inputVertical =
        (density.inputHeight - inputText.fontSize! * inputText.height!) / 2;

    return ThemeData(
      colorScheme: const ColorScheme.light(
        // Black does the acting: Material's "primary" drives checkboxes,
        // focus, the cursor and pickers, so it is Charcoal. The green accent
        // is "secondary" and only reaches progress through its own theme.
        primary: AppColors.charcoal,
        onPrimary: AppColors.cloudCard,
        primaryContainer: AppColors.cloudCard,
        onPrimaryContainer: AppColors.ink,
        secondary: AppColors.accent,
        onSecondary: AppColors.onFilled,
        secondaryContainer: AppColors.accentTint,
        onSecondaryContainer: AppColors.accentStrong,
        tertiary: AppColors.aiDraft,
        onTertiary: AppColors.onFilled,
        surface: AppColors.canvas,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.textSecondary,
        surfaceContainerLowest: AppColors.canvas,
        surfaceContainerLow: AppColors.canvas,
        surfaceContainer: AppColors.canvas,
        surfaceContainerHigh: AppColors.canvas,
        surfaceContainerHighest: AppColors.cloudCard,
        surfaceTint: Colors.transparent,
        error: AppColors.error,
        onError: AppColors.onFilled,
        errorContainer: AppColors.errorTint,
        onErrorContainer: AppColors.error,
        outline: AppColors.borderStrong,
        outlineVariant: AppColors.divider,
        shadow: Colors.black,
        inverseSurface: AppColors.charcoal,
        onInverseSurface: AppColors.cloudCard,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      canvasColor: AppColors.canvas,
      // AppDensity is the density system. Left alone, Flutter adds its own
      // on desktop (VisualDensity.compact), which took 8 px off every
      // control in a Windows browser.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: density.isCompact
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
      textTheme: text,
      extensions: [AppPalette.light, density],
      hoverColor: hoverOverlay,
      focusColor: pressOverlay,
      // The splash carries the press; a highlight on top of it would double
      // the overlay past 8 %.
      highlightColor: Colors.transparent,
      splashColor: pressOverlay,
      dividerColor: AppColors.divider,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.ink,
        // Ink at 20 %: Cloud Card (1.14:1) was invisible on a white field.
        selectionColor: Color(0x33222326),
        selectionHandleColor: AppColors.ink,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        // The colour has to be restated: supplying titleTextStyle at all
        // stops foregroundColor from reaching the title.
        titleTextStyle: text.headlineMedium?.copyWith(color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cloudCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        // No border and no shadow: Cloud Card on white is the separation.
        shape: cardShape,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: text.titleLarge?.copyWith(color: AppColors.ink),
        subtitleTextStyle: text.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        leadingAndTrailingTextStyle: text.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        iconColor: AppColors.ink,
        textColor: AppColors.ink,
      ),
      // The floating capsule (FloatingNavBar) carries the shape and shadow;
      // the bar itself is white with no indicator pill.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.ink
                : AppColors.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.ink
                : AppColors.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.canvas,
        indicatorColor: Colors.transparent,
        selectedIconTheme: const IconThemeData(color: AppColors.ink),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
        ),
        selectedLabelTextStyle: text.labelMedium?.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          // Height is fixed, width is not: Size.fromHeight would set an
          // infinite width and break any button placed inside a Row.
          minimumSize: WidgetStatePropertyAll(Size(64, density.controlHeight)),
          padding: WidgetStatePropertyAll(buttonPadding),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.cloudCard;
            }
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return AppColors.charcoalHover;
            }
            return AppColors.charcoal;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.textSecondary
                : AppColors.cloudCard,
          ),
          // The fill itself lifts to charcoalHover; no veil on top.
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          shape: WidgetStatePropertyAll(pill),
        ),
      ),
      // The secondary action ("Düzenle") is a pale pill with an Ink label,
      // not an outline: OutlinedButton is Material's name for it.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(64, density.controlHeight)),
          padding: WidgetStatePropertyAll(buttonPadding),
          backgroundColor: const WidgetStatePropertyAll(AppColors.cloudCard),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.textSecondary
                : AppColors.ink,
          ),
          overlayColor: overlay,
          side: const WidgetStatePropertyAll(BorderSide.none),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          shape: WidgetStatePropertyAll(pill),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(density.isCompact ? 28 : 48, density.controlHeight),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.textSecondary
                : AppColors.ink,
          ),
          overlayColor: overlay,
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          shape: WidgetStatePropertyAll(pill),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(AppColors.ink),
          overlayColor: overlay,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.cloudCard,
        elevation: 0,
        shape: StadiumBorder(),
      ),
      // Filter chips: a Cloud Card pill when off, Charcoal with a tick when
      // on.
      chipTheme: ChipThemeData(
        shape: pill,
        side: BorderSide.none,
        backgroundColor: AppColors.cloudCard,
        selectedColor: AppColors.charcoal,
        disabledColor: AppColors.cloudCard,
        checkmarkColor: AppColors.cloudCard,
        // Material 3 reads the selected label's colour from labelStyle, so
        // the colour itself resolves the state.
        labelStyle: text.labelLarge?.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.cloudCard
                : AppColors.ink,
          ),
        ),
        secondaryLabelStyle: text.labelLarge?.copyWith(
          color: AppColors.cloudCard,
        ),
        color: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.charcoal
              : AppColors.cloudCard,
        ),
        // The chip adds 2 px of its own above and below the label.
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical:
              (density.inputHeight -
                      text.labelLarge!.fontSize! * text.labelLarge!.height!) /
                  2 -
              2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
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
        hintStyle: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        helperStyle: text.bodySmall?.copyWith(color: AppColors.textSecondary),
        labelStyle: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle: text.bodyLarge?.copyWith(color: AppColors.ink),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: AppColors.ink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.charcoal
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.cloudCard),
        side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
        overlayColor: overlay,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.charcoal
              : AppColors.borderStrong,
        ),
        overlayColor: overlay,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.canvas
              : AppColors.borderStrong,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.charcoal
              : AppColors.cloudCard,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.charcoal
              : AppColors.borderStrong,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.cloudCard,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 8,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
        titleTextStyle: text.headlineSmall?.copyWith(color: AppColors.ink),
        contentTextStyle: text.bodyLarge?.copyWith(color: AppColors.ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(density.cardRadius),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: text.bodyLarge?.copyWith(color: AppColors.ink),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.cloudCard),
        actionTextColor: AppColors.cloudCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: text.bodySmall?.copyWith(color: AppColors.cloudCard),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.ink,
        dividerColor: AppColors.divider,
        labelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: text.labelLarge,
        overlayColor: overlay,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.charcoal,
        textColor: AppColors.cloudCard,
        textStyle: text.labelSmall,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// The theme for everything inside a Cloud Card: whatever was a pale Cloud
/// Card fill on the canvas (the secondary pill, a disabled button, an off
/// chip, a progress track, [AppPalette.inset]) becomes white, or it would
/// vanish into the card. Used by `CloudCard`.
ThemeData onCloudCard(ThemeData base) {
  final palette = base.extension<AppPalette>()!;
  final filled = base.filledButtonTheme.style!;
  final filledBackground = filled.backgroundColor!;
  return base.copyWith(
    extensions: [
      ...base.extensions.values.where((e) => e is! AppPalette),
      palette.copyWith(inset: AppColors.canvas),
    ],
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: base.outlinedButtonTheme.style!.copyWith(
        backgroundColor: const WidgetStatePropertyAll(AppColors.canvas),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: filled.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? AppColors.canvas
              : filledBackground.resolve(states),
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.canvas,
      disabledColor: AppColors.canvas,
      color: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.charcoal
            : AppColors.canvas,
      ),
    ),
    progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
      linearTrackColor: AppColors.canvas,
    ),
  );
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  AppDensity get density => Theme.of(this).extension<AppDensity>()!;
}
