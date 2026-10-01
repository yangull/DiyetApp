import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens/app_colors.dart';
import 'tokens/app_density.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_typography.dart';

/// Light and dark (Can, 1 Oct 2026, was C43), built from one function over
/// the measured [AppPalette.light] and [AppPalette.dark].
///
/// [ColorScheme.fromSeed] is deliberately NOT used. It derives its own tonal
/// ramps from one seed and would not reproduce the measured values in
/// [AppPalette]; every slot below is set explicitly instead.
abstract final class AppTheme {
  /// The confirm button of a destructive dialog ("İptal et", "Sıfırla"): red,
  /// with a label measured at 6.01:1 (light) and 8.11:1 (dark).
  static ButtonStyle destructive(BuildContext context) {
    final p = Theme.of(context).extension<AppPalette>()!;
    return ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(p.error),
      foregroundColor: WidgetStatePropertyAll(p.onFilled),
    );
  }

  /// Hover, focus and press darken (or, in dark, lighten) whatever sits
  /// below, and text must keep 4.5:1 in every state. Capped at Ink 4 %
  /// (hover) and 8 % (focus, press): every ratio in [AppPalette] was measured
  /// on a card under 8 %. These are the light values.
  static const hoverOverlay = Color(0x0A222326);
  static const pressOverlay = Color(0x14222326);

  static ThemeData light(AppDensity density) =>
      _build(density, AppPalette.light, Brightness.light);

  static ThemeData dark(AppDensity density) =>
      _build(density, AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppDensity density, AppPalette p, Brightness b) {
    final hover = p.ink.withValues(alpha: 0x0A / 255);
    final press = p.ink.withValues(alpha: 0x14 / 255);
    final WidgetStateProperty<Color?> overlay = WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return press;
        }
        if (states.contains(WidgetState.hovered)) return hover;
        return null;
      },
    );
    final text = AppTypography.textTheme(density);
    final pill = StadiumBorder();
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
      colorScheme: ColorScheme(
        brightness: b,
        // Black does the acting: Material's "primary" drives checkboxes,
        // focus, the cursor and pickers, so it is Charcoal. The green accent
        // is "secondary" and only reaches progress through its own theme.
        primary: p.charcoal,
        onPrimary: p.onCharcoal,
        primaryContainer: p.cloudCard,
        onPrimaryContainer: p.ink,
        secondary: p.accent,
        onSecondary: p.onFilled,
        secondaryContainer: p.accentTint,
        onSecondaryContainer: p.accentStrong,
        tertiary: p.aiDraft,
        onTertiary: p.onFilled,
        surface: p.canvas,
        onSurface: p.ink,
        onSurfaceVariant: p.textSecondary,
        surfaceContainerLowest: p.canvas,
        surfaceContainerLow: p.canvas,
        surfaceContainer: p.canvas,
        surfaceContainerHigh: p.canvas,
        surfaceContainerHighest: p.cloudCard,
        surfaceTint: Colors.transparent,
        error: p.error,
        onError: p.onFilled,
        errorContainer: p.errorTint,
        onErrorContainer: p.error,
        outline: p.borderStrong,
        outlineVariant: p.divider,
        shadow: Colors.black,
        inverseSurface: p.charcoal,
        onInverseSurface: p.onCharcoal,
      ),
      brightness: b,
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.canvas,
      // AppDensity is the density system. Left alone, Flutter adds its own
      // on desktop (VisualDensity.compact), which took 8 px off every
      // control in a Windows browser.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: density.isCompact
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
      textTheme: text,
      extensions: [p, density],
      hoverColor: hover,
      focusColor: press,
      // The splash carries the press; a highlight on top of it would double
      // the overlay past 8 %.
      highlightColor: Colors.transparent,
      splashColor: press,
      dividerColor: p.divider,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.ink,
        // Ink at 20 %: Cloud Card (1.14:1) was invisible on a white field.
        selectionColor: p.ink.withValues(alpha: 0.2),
        selectionHandleColor: p.ink,
      ),
      iconTheme: IconThemeData(color: p.ink),
      appBarTheme: AppBarTheme(
        // Status bar icons dark on the light canvas, light on the dark one.
        systemOverlayStyle: b == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: p.canvas,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        // The colour has to be restated: supplying titleTextStyle at all
        // stops foregroundColor from reaching the title.
        titleTextStyle: text.headlineMedium?.copyWith(color: p.ink),
      ),
      cardTheme: CardThemeData(
        color: p.cloudCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        // No border and no shadow: Cloud Card on white is the separation.
        shape: cardShape,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: text.titleLarge?.copyWith(color: p.ink),
        subtitleTextStyle: text.bodyMedium?.copyWith(color: p.textSecondary),
        leadingAndTrailingTextStyle: text.bodyMedium?.copyWith(
          color: p.textSecondary,
        ),
        iconColor: p.ink,
        textColor: p.ink,
      ),
      // The floating capsule (FloatingNavBar) carries the shape and shadow;
      // the bar itself is white with no indicator pill.
      navigationBarTheme: NavigationBarThemeData(
        // The floating capsule: white on white with a shadow in light; one
        // step lighter than the canvas in dark, where a shadow can't show.
        backgroundColor: b == Brightness.dark ? p.cloudCard : p.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? p.ink
                : p.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? p.ink
                : p.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.canvas,
        indicatorColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: p.ink),
        unselectedIconTheme: IconThemeData(color: p.textSecondary),
        selectedLabelTextStyle: text.labelMedium?.copyWith(
          color: p.ink,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(
          color: p.textSecondary,
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
              return p.cloudCard;
            }
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return p.charcoalHover;
            }
            return p.charcoal;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? p.textSecondary
                : p.onCharcoal,
          ),
          // The fill itself lifts to charcoalHover; no veil on top.
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(0),
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
          backgroundColor: WidgetStatePropertyAll(p.cloudCard),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.disabled) ? p.textSecondary : p.ink,
          ),
          overlayColor: overlay,
          side: WidgetStatePropertyAll(BorderSide.none),
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
            (states) =>
                states.contains(WidgetState.disabled) ? p.textSecondary : p.ink,
          ),
          overlayColor: overlay,
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          shape: WidgetStatePropertyAll(pill),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(p.ink),
          overlayColor: overlay,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.charcoal,
        foregroundColor: p.onCharcoal,
        elevation: 0,
        shape: StadiumBorder(),
      ),
      // Filter chips: a Cloud Card pill when off, Charcoal with a tick when
      // on.
      chipTheme: ChipThemeData(
        shape: pill,
        side: BorderSide.none,
        backgroundColor: p.cloudCard,
        selectedColor: p.charcoal,
        disabledColor: p.cloudCard,
        checkmarkColor: p.onCharcoal,
        // Material 3 reads the selected label's colour from labelStyle, so
        // the colour itself resolves the state.
        labelStyle: text.labelLarge?.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? p.onCharcoal : p.ink,
          ),
        ),
        secondaryLabelStyle: text.labelLarge?.copyWith(color: p.onCharcoal),
        color: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.charcoal : p.cloudCard,
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
        fillColor: p.canvas,
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
        hintStyle: text.bodyLarge?.copyWith(color: p.textSecondary),
        helperStyle: text.bodySmall?.copyWith(color: p.textSecondary),
        labelStyle: text.bodyLarge?.copyWith(color: p.textSecondary),
        floatingLabelStyle: text.bodyLarge?.copyWith(color: p.ink),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: p.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: p.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: p.ink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: p.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: p.error, width: 2),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.charcoal
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(p.onCharcoal),
        side: BorderSide(color: p.borderStrong, width: 1.5),
        overlayColor: overlay,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.charcoal
              : p.borderStrong,
        ),
        overlayColor: overlay,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.canvas : p.borderStrong,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.charcoal : p.cloudCard,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? p.charcoal
              : p.borderStrong,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.cloudCard,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 8,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.canvas,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
        titleTextStyle: text.headlineSmall?.copyWith(color: p.ink),
        contentTextStyle: text.bodyLarge?.copyWith(color: p.ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(density.cardRadius),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: text.bodyLarge?.copyWith(color: p.ink),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.charcoal,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.onCharcoal),
        actionTextColor: p.onCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.charcoal,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: text.bodySmall?.copyWith(color: p.onCharcoal),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.ink,
        unselectedLabelColor: p.textSecondary,
        indicatorColor: p.ink,
        dividerColor: p.divider,
        labelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: text.labelLarge,
        overlayColor: overlay,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: p.charcoal,
        textColor: p.onCharcoal,
        textStyle: text.labelSmall,
      ),
      // The theme choice and any other segmented control: the selected
      // segment is the filled pill's colours, never green.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, density.controlHeight)),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? p.charcoal
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? p.onCharcoal : p.ink,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: p.borderStrong)),
          overlayColor: overlay,
        ),
      ),
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
    );
  }
}

/// The theme for everything inside a Cloud Card: whatever was a pale Cloud
/// Card fill on the canvas (the secondary pill, a disabled button, an off
/// chip, a progress track, [AppPalette.inset]) becomes white, or it would
/// vanish into the card. Used by `CloudCard`.
ThemeData onCloudCard(ThemeData base) {
  final palette = base.extension<AppPalette>()!;
  final canvas = palette.canvas;
  final filled = base.filledButtonTheme.style!;
  final filledBackground = filled.backgroundColor!;
  return base.copyWith(
    extensions: [
      ...base.extensions.values.where((e) => e is! AppPalette),
      palette.copyWith(inset: canvas),
    ],
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: base.outlinedButtonTheme.style!.copyWith(
        backgroundColor: WidgetStatePropertyAll(canvas),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: filled.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? canvas
              : filledBackground.resolve(states),
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: canvas,
      disabledColor: canvas,
      color: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? palette.charcoal : canvas,
      ),
    ),
    progressIndicatorTheme: base.progressIndicatorTheme.copyWith(
      linearTrackColor: canvas,
    ),
  );
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  AppDensity get density => Theme.of(this).extension<AppDensity>()!;
}
