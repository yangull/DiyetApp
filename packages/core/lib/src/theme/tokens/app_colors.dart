import 'package:flutter/material.dart';

/// Palette B ("Serin"), light theme. Every value below was measured against
/// WCAG AA (4.5:1 for text) and WCAG 1.4.11 (3:1 for interactive boundaries);
/// the ratios are recorded next to each token. Do not edit a value without
/// re-measuring it.
///
/// There is deliberately no separate `success` color: a distinct success green
/// sat at 1.19:1 against [primary], which is indistinguishable. Approved states
/// use [primary]. Every other color in the app carries a meaning.
abstract final class AppColors {
  /// App background. Cool neutral rather than warm paper.
  static const ground = Color(0xFFF7F9F8);

  /// Card and sheet background.
  static const surface = Color(0xFFFFFFFF);

  /// Table headers, subtle fills.
  static const surfaceSubtle = Color(0xFFEBF1EE);

  /// Decorative hairline. 1.36:1 — never used to convey state.
  static const borderSubtle = Color(0xFFDAE4E0);

  /// Input and control boundaries. 3.51:1 on [surface], 3.32:1 on [ground].
  static const borderStrong = Color(0xFF7E8C86);

  /// 16.54:1 on [surface].
  static const textPrimary = Color(0xFF16211D);

  /// 7.62:1 on [ground].
  static const textSecondary = Color(0xFF46534D);

  /// 5.56:1 on [surface], 5.26:1 on [ground].
  static const textMuted = Color(0xFF5F6B64);

  /// The single brand hue. 5.35:1 both ways against white, so it works as
  /// button fill and as text. Also means "approved".
  static const primary = Color(0xFF18795C);

  /// Pressed and hovered state. 7.61:1 against white.
  static const primaryHover = Color(0xFF135F49);

  static const onPrimary = Color(0xFFFFFFFF);

  /// Pending review. 5.92:1 on [surface].
  static const warning = Color(0xFF8A5A0B);

  /// Rejected and failures. 7.56:1 on [surface].
  static const error = Color(0xFFA32017);

  /// Reserved exclusively for AI-drafted, not-yet-approved content, so that
  /// violet always means exactly that. 8.25:1 on [surface].
  static const aiDraft = Color(0xFF514196);
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
    required this.warning,
    required this.aiDraft,
  });

  static const light = AppPalette(
    ground: AppColors.ground,
    surfaceSubtle: AppColors.surfaceSubtle,
    borderSubtle: AppColors.borderSubtle,
    borderStrong: AppColors.borderStrong,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    warning: AppColors.warning,
    aiDraft: AppColors.aiDraft,
  );

  final Color ground;
  final Color surfaceSubtle;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textSecondary;
  final Color textMuted;
  final Color warning;
  final Color aiDraft;

  @override
  AppPalette copyWith({
    Color? ground,
    Color? surfaceSubtle,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textSecondary,
    Color? textMuted,
    Color? warning,
    Color? aiDraft,
  }) {
    return AppPalette(
      ground: ground ?? this.ground,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      warning: warning ?? this.warning,
      aiDraft: aiDraft ?? this.aiDraft,
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
      warning: Color.lerp(warning, other.warning, t)!,
      aiDraft: Color.lerp(aiDraft, other.aiDraft, t)!,
    );
  }
}
