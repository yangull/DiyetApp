import 'package:flutter/material.dart';

/// Palette "Sade" (PLANNING #133), light theme: neutral greys, white cards and
/// one accent, the brand green, for actions and progress only. Every value below was measured
/// against WCAG AA (4.5:1 for text) and WCAG 1.4.11 (3:1 for graphics and
/// interactive boundaries); the ratios are recorded next to each token and
/// checked by `core_test.dart`. Do not edit a value without re-measuring it.
///
/// There is deliberately no separate `success` color: a distinct success green
/// sat at 1.19:1 against [primary], which is indistinguishable. Approved states
/// use [primary]. Every other color in the app carries a meaning.
abstract final class AppColors {
  /// App background: a neutral light grey that white cards lift off without
  /// borders. Text, brand and status colours keep AA on it (14.98 / 7.30 /
  /// 5.04 for the three text tokens, 4.84 for [primary]).
  static const ground = Color(0xFFF2F4F3);

  /// Card and sheet background.
  static const surface = Color(0xFFFFFFFF);

  /// Table headers, progress tracks, neutral status pills and disabled
  /// secondary buttons.
  /// [primary] is 4.58:1 here, [primaryHover] 6.51:1; [borderStrong] is below
  /// 3:1, so no essential boundary sits on it.
  static const surfaceSubtle = Color(0xFFEBEEEC);

  /// Dividers inside a card. 1.24:1 on white: never used to convey state.
  /// Cards themselves have no border; the ground separates them.
  static const borderSubtle = Color(0xFFE4E8E6);

  /// Input and control boundaries. 3.51:1 on [surface], 3.18:1 on [ground].
  static const borderStrong = Color(0xFF7E8C86);

  /// 16.54:1 on [surface], 14.98:1 on [ground], 14.16:1 on [surfaceSubtle].
  static const textPrimary = Color(0xFF16211D);

  /// 7.30:1 on [ground], 6.90:1 on [surfaceSubtle].
  static const textSecondary = Color(0xFF46534D);

  /// 5.56:1 on [surface], 5.04:1 on [ground], 4.76:1 on [surfaceSubtle].
  static const textMuted = Color(0xFF5F6B64);

  /// The single brand hue. 5.35:1 both ways against white, so it works as
  /// button fill and as text. Also means "approved".
  static const primary = Color(0xFF18795C);

  /// Pressed and hovered state, and text on tinted fills. 7.61:1 against
  /// white, 6.53:1 on [primaryTint].
  static const primaryHover = Color(0xFF135F49);

  static const onPrimary = Color(0xFFFFFFFF);

  /// The tinted fill of a secondary action ("Düzenle", "Yaz"): the one place
  /// the accent appears as a background. [primaryHover] on it is 6.53:1.
  static const primaryTint = Color(0xFFE3F1EA);

  /// Pending review, needs attention. 5.92:1 on [surface], 5.36:1 on [ground].
  static const warning = Color(0xFF8A5A0B);

  /// Fill behind [warning] text. [warning] on it is 5.19:1.
  static const warningTint = Color(0xFFFBEFD5);

  /// Rejected and failures. 7.56:1 on [surface], 6.85:1 on [ground].
  static const error = Color(0xFFA32017);

  /// Reserved exclusively for AI-drafted, not-yet-approved content, so that
  /// violet always means exactly that. 8.25:1 on [surface].
  static const aiDraft = Color(0xFF514196);

  /// Fill behind [aiDraft] text in a status pill. [aiDraft] on it is 7.01:1.
  static const aiDraftTint = Color(0xFFEEEBF6);
}

/// Tokens Material's [ColorScheme] has no slot for. Read with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ground,
    required this.surfaceSubtle,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textSecondary,
    required this.textMuted,
    required this.primaryHover,
    required this.primaryTint,
    required this.warning,
    required this.warningTint,
    required this.aiDraft,
    required this.aiDraftTint,
  });

  static const light = AppPalette(
    ground: AppColors.ground,
    surfaceSubtle: AppColors.surfaceSubtle,
    borderSubtle: AppColors.borderSubtle,
    borderStrong: AppColors.borderStrong,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    primaryHover: AppColors.primaryHover,
    primaryTint: AppColors.primaryTint,
    warning: AppColors.warning,
    warningTint: AppColors.warningTint,
    aiDraft: AppColors.aiDraft,
    aiDraftTint: AppColors.aiDraftTint,
  );

  final Color ground;
  final Color surfaceSubtle;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textSecondary;
  final Color textMuted;
  final Color primaryHover;
  final Color primaryTint;
  final Color warning;
  final Color warningTint;
  final Color aiDraft;
  final Color aiDraftTint;

  @override
  AppPalette copyWith({
    Color? ground,
    Color? surfaceSubtle,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textSecondary,
    Color? textMuted,
    Color? primaryHover,
    Color? primaryTint,
    Color? warning,
    Color? warningTint,
    Color? aiDraft,
    Color? aiDraftTint,
  }) {
    return AppPalette(
      ground: ground ?? this.ground,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryTint: primaryTint ?? this.primaryTint,
      warning: warning ?? this.warning,
      warningTint: warningTint ?? this.warningTint,
      aiDraft: aiDraft ?? this.aiDraft,
      aiDraftTint: aiDraftTint ?? this.aiDraftTint,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      ground: Color.lerp(ground, other.ground, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      aiDraft: Color.lerp(aiDraft, other.aiDraft, t)!,
      aiDraftTint: Color.lerp(aiDraftTint, other.aiDraftTint, t)!,
    );
  }
}
