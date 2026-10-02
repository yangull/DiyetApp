import 'package:flutter/material.dart';

/// The light values. Widgets read colours through `context.palette`, which
/// also carries [AppPalette.dark]; these constants are the light theme's
/// source and what the contrast tests measure.
///
/// Bevel adapted for an app (PLANNING #134–#135, `docs/design-system.md`),
/// light theme: a white canvas, borderless Cloud Card surfaces, black actions,
/// one green accent for progress, "approved" and data, and three status
/// colours with one meaning each. Every value was measured against WCAG AA
/// (4.5:1 for all text, 3:1 for graphics and input boundaries), also on a
/// Cloud Card under the 8 % Ink press overlay (`#DBE0E7`); the ratios are
/// recorded next to each token and checked by `core_test.dart`. Do not edit a
/// value without re-measuring it.
abstract final class AppColors {
  /// Page background, app bar, bottom bar, sheets, dialogs, input fill.
  static const canvas = Color(0xFFFFFFFF);

  /// Cards and inset surfaces: no border, no shadow. 1.14:1 on [canvas]; the
  /// change of tone is the separation.
  static const cloudCard = Color(0xFFEBF0F8);

  /// Headings, body text, icons and text actions. 15.71:1 on [canvas],
  /// 13.73:1 on [cloudCard], 11.84:1 on a pressed Cloud Card.
  static const ink = Color(0xFF222326);

  /// The filled button and the selected chip. Its label is [cloudCard],
  /// 14.21:1.
  static const charcoal = Color(0xFF1F2025);

  /// Pressed or hovered filled button. [cloudCard] on it is 10.52:1.
  static const charcoalHover = Color(0xFF35363C);

  /// All supporting text, on any surface: 6.11:1 on [canvas], 5.34:1 on
  /// [cloudCard], 4.61:1 on a pressed Cloud Card. Bevel's own grey (#747679)
  /// fails on its Cloud Card (3.98:1).
  static const textSecondary = Color(0xFF606266);

  /// Input and checkbox boundaries: 3.65:1 on [canvas], 3.19:1 on
  /// [cloudCard]. Inputs never sit inside a pressable area (2.75:1 there).
  static const borderStrong = Color(0xFF83868B);

  /// Dividers between touching rows. 1.24:1: never carries state.
  static const divider = Color(0xFFE3E7EE);

  /// Progress fills, "approved" and the one data colour. 5.35:1 on [canvas],
  /// 4.67:1 on [cloudCard]; white on it 5.35:1. Not an action colour.
  static const accent = Color(0xFF18795C);

  /// Accent text on [accentTint] (6.60:1): the "Onaylı" pill.
  static const accentStrong = Color(0xFF135F49);

  static const accentTint = Color(0xFFE4F2EC);

  /// Waiting, needs attention. 5.52:1 on [canvas], 4.82:1 on [cloudCard],
  /// 4.97:1 on [warningTint].
  static const warning = Color(0xFF8F5F00);

  static const warningTint = Color(0xFFFFF2D6);

  /// Failed, rejected, destructive. 6.01:1 on [canvas], 5.26:1 on
  /// [cloudCard] and [errorTint]; white on it 6.01:1.
  static const error = Color(0xFFB43622);

  static const errorTint = Color(0xFFFDECEB);

  /// Reserved exclusively for AI-drafted, not-yet-approved content, so that
  /// violet always means exactly that. 8.25:1 on [canvas], 7.21:1 on
  /// [cloudCard], 7.01:1 on [aiDraftTint].
  static const aiDraft = Color(0xFF514196);

  static const aiDraftTint = Color(0xFFEEEBF6);

  /// Star shapes only, always beside the rating number in [ink] (1.53:1).
  static const gold = Color(0xFFFFCA00);

  /// Text on [accent] and [error] fills.
  static const onFilled = Color(0xFFFFFFFF);
}

/// Every colour a widget reads, in one theme. Read with `context.palette`,
/// never from [AppColors] directly, so dark mode reaches every widget.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.cloudCard,
    required this.ink,
    required this.charcoal,
    required this.charcoalHover,
    required this.onCharcoal,
    required this.textSecondary,
    required this.borderStrong,
    required this.divider,
    required this.accent,
    required this.accentStrong,
    required this.accentTint,
    required this.warning,
    required this.warningTint,
    required this.error,
    required this.errorTint,
    required this.aiDraft,
    required this.aiDraftTint,
    required this.gold,
    required this.onFilled,
    required this.inset,
  });

  static const light = AppPalette(
    canvas: AppColors.canvas,
    cloudCard: AppColors.cloudCard,
    ink: AppColors.ink,
    charcoal: AppColors.charcoal,
    charcoalHover: AppColors.charcoalHover,
    onCharcoal: AppColors.cloudCard,
    textSecondary: AppColors.textSecondary,
    borderStrong: AppColors.borderStrong,
    divider: AppColors.divider,
    accent: AppColors.accent,
    accentStrong: AppColors.accentStrong,
    accentTint: AppColors.accentTint,
    warning: AppColors.warning,
    warningTint: AppColors.warningTint,
    error: AppColors.error,
    errorTint: AppColors.errorTint,
    aiDraft: AppColors.aiDraft,
    aiDraftTint: AppColors.aiDraftTint,
    gold: AppColors.gold,
    onFilled: AppColors.onFilled,
    inset: AppColors.cloudCard,
  );

  /// Dark (Can, 1 Oct 2026, was C43): a near-black canvas, cards one step
  /// lighter, a near-white filled pill, lightened accent and status colours,
  /// and Bevel's Sleep Lilac for AI drafts. Measured like light: every text
  /// colour keeps 4.5:1 on the canvas, on a card and on a card under the 8 %
  /// press overlay (`#2F3035`): ink 16.00 / 14.04 / 11.34, textSecondary
  /// 6.83 / 6.00 / 4.84, accent 8.39 / 7.36 / 5.94, warning 9.44 / 8.28 / 6.69,
  /// error 8.11 / 7.12 / 5.75, aiDraft 8.81 / 7.73 / 6.25; borderStrong 3.53 on
  /// the canvas and 3.10 on a card; status text on its tint 6.55 or more;
  /// the canvas-coloured label on the filled pill 16.00 (12.89 pressed), on
  /// accent 8.39 and on error 8.11. Checked in `core_test.dart`.
  static const dark = AppPalette(
    canvas: Color(0xFF121316),
    cloudCard: Color(0xFF1E2025),
    ink: Color(0xFFEDEEF0),
    charcoal: Color(0xFFEDEEF0),
    charcoalHover: Color(0xFFD5D7DB),
    onCharcoal: Color(0xFF121316),
    textSecondary: Color(0xFF9A9DA3),
    borderStrong: Color(0xFF696C73),
    divider: Color(0xFF2C2F35),
    accent: Color(0xFF4CC38A),
    accentStrong: Color(0xFF7FD9AE),
    accentTint: Color(0xFF173327),
    warning: Color(0xFFE6B04A),
    warningTint: Color(0xFF3A2E12),
    error: Color(0xFFFF8A7A),
    errorTint: Color(0xFF3D1E1B),
    aiDraft: Color(0xFFB9A6FF),
    aiDraftTint: Color(0xFF2A2445),
    gold: Color(0xFFFFCA00),
    onFilled: Color(0xFF121316),
    inset: Color(0xFF1E2025),
  );

  final Color canvas;
  final Color cloudCard;
  final Color ink;

  /// The filled button and the selected chip: Charcoal in light, near-white
  /// in dark.
  final Color charcoal;
  final Color charcoalHover;

  /// The label on [charcoal].
  final Color onCharcoal;
  final Color textSecondary;
  final Color borderStrong;
  final Color divider;
  final Color accent;
  final Color accentStrong;
  final Color accentTint;
  final Color warning;
  final Color warningTint;
  final Color error;
  final Color errorTint;
  final Color aiDraft;
  final Color aiDraftTint;
  final Color gold;

  /// Text on [accent] and [error] fills.
  final Color onFilled;

  /// The pale fill for something set into the surface it sits on (a neutral
  /// pill, an avatar disc, a progress track, a selected row): Cloud Card on
  /// the canvas, the canvas inside a Cloud Card. `CloudCard` swaps it, so a
  /// widget never has to know where it sits.
  final Color inset;

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? cloudCard,
    Color? ink,
    Color? charcoal,
    Color? charcoalHover,
    Color? onCharcoal,
    Color? textSecondary,
    Color? borderStrong,
    Color? divider,
    Color? accent,
    Color? accentStrong,
    Color? accentTint,
    Color? warning,
    Color? warningTint,
    Color? error,
    Color? errorTint,
    Color? aiDraft,
    Color? aiDraftTint,
    Color? gold,
    Color? onFilled,
    Color? inset,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      cloudCard: cloudCard ?? this.cloudCard,
      ink: ink ?? this.ink,
      charcoal: charcoal ?? this.charcoal,
      charcoalHover: charcoalHover ?? this.charcoalHover,
      onCharcoal: onCharcoal ?? this.onCharcoal,
      textSecondary: textSecondary ?? this.textSecondary,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      accentTint: accentTint ?? this.accentTint,
      warning: warning ?? this.warning,
      warningTint: warningTint ?? this.warningTint,
      error: error ?? this.error,
      errorTint: errorTint ?? this.errorTint,
      aiDraft: aiDraft ?? this.aiDraft,
      aiDraftTint: aiDraftTint ?? this.aiDraftTint,
      gold: gold ?? this.gold,
      onFilled: onFilled ?? this.onFilled,
      inset: inset ?? this.inset,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      canvas: l(canvas, other.canvas),
      cloudCard: l(cloudCard, other.cloudCard),
      ink: l(ink, other.ink),
      charcoal: l(charcoal, other.charcoal),
      charcoalHover: l(charcoalHover, other.charcoalHover),
      onCharcoal: l(onCharcoal, other.onCharcoal),
      textSecondary: l(textSecondary, other.textSecondary),
      borderStrong: l(borderStrong, other.borderStrong),
      divider: l(divider, other.divider),
      accent: l(accent, other.accent),
      accentStrong: l(accentStrong, other.accentStrong),
      accentTint: l(accentTint, other.accentTint),
      warning: l(warning, other.warning),
      warningTint: l(warningTint, other.warningTint),
      error: l(error, other.error),
      errorTint: l(errorTint, other.errorTint),
      aiDraft: l(aiDraft, other.aiDraft),
      aiDraftTint: l(aiDraftTint, other.aiDraftTint),
      gold: l(gold, other.gold),
      onFilled: l(onFilled, other.onFilled),
      inset: l(inset, other.inset),
    );
  }
}
