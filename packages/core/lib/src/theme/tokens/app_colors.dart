import 'package:flutter/material.dart';

/// Palette "Sıcak" (PLANNING #131), light theme. Every value below was measured
/// against WCAG AA (4.5:1 for text) and WCAG 1.4.11 (3:1 for graphics and
/// interactive boundaries); the ratios are recorded next to each token and
/// checked by `core_test.dart`. Do not edit a value without re-measuring it.
///
/// There is deliberately no separate `success` color: a distinct success green
/// sat at 1.19:1 against [primary], which is indistinguishable. Approved states
/// use [primary]. Every other color in the app carries a meaning.
abstract final class AppColors {
  /// App background. Warm paper; text, brand and status colours all keep AA
  /// on it (14.70 / 7.17 / 4.95 for the three text tokens, 4.75 for [primary]).
  static const ground = Color(0xFFF6F1E8);

  /// Card and sheet background.
  static const surface = Color(0xFFFFFFFF);

  /// Table headers, subtle fills, secondary buttons, "Yakında" chips, bar
  /// tracks. [primary] is only 4.47:1 here, so text and links on this fill use
  /// [primaryHover] (6.37:1); [borderStrong] is 2.94:1, so no essential
  /// boundary sits on it.
  static const surfaceSubtle = Color(0xFFF1EADF);

  /// Decorative hairline. 1.19:1 on [ground]: never used to convey state.
  static const borderSubtle = Color(0xFFE8DDCB);

  /// Input and control boundaries. 3.51:1 on [surface], 3.12:1 on [ground].
  static const borderStrong = Color(0xFF7E8C86);

  /// 16.54:1 on [surface], 14.70:1 on [ground], 13.84:1 on [surfaceSubtle].
  static const textPrimary = Color(0xFF16211D);

  /// 7.17:1 on [ground], 6.75:1 on [surfaceSubtle].
  static const textSecondary = Color(0xFF46534D);

  /// 5.56:1 on [surface], 4.95:1 on [ground].
  static const textMuted = Color(0xFF5F6B64);

  /// The single brand hue. 5.35:1 both ways against white, so it works as
  /// button fill and as text. Also means "approved".
  static const primary = Color(0xFF18795C);

  /// Pressed and hovered state, and text on [surfaceSubtle]. 7.61:1 against
  /// white, 6.37:1 on [surfaceSubtle].
  static const primaryHover = Color(0xFF135F49);

  static const onPrimary = Color(0xFFFFFFFF);

  /// The green block that carries a screen's main number (rule 1 allows one
  /// flat block). The brand green itself: white text on it is 5.35:1.
  static const hero = primary;

  /// Secondary text, pending step numbers and borders on [hero]. 4.64:1.
  static const onHeroSecondary = Color(0xFFE4F2EC);

  /// The unfilled part of a ring or step line on [hero]. Decorative against
  /// the hero (1.42:1); [highlight] on it is 4.53:1.
  static const heroTrack = primaryHover;

  /// Progress and achievement only: the day's ring, a finished step, the week
  /// count. Never "needs attention" (that is [warning]). 3.19:1 on [hero].
  static const highlight = Color(0xFFF2C14E);

  /// Text and icons on [highlight]. 8.25:1.
  static const onHighlight = Color(0xFF3B2A00);

  /// Pending review, needs attention. 5.92:1 on [surface], 5.26:1 on [ground].
  static const warning = Color(0xFF8A5A0B);

  /// Fill behind [warning] text. [warning] on it is 5.19:1.
  static const warningTint = Color(0xFFFBEFD5);

  /// Rejected and failures. 7.56:1 on [surface], 6.72:1 on [ground].
  static const error = Color(0xFFA32017);

  /// Reserved exclusively for AI-drafted, not-yet-approved content, so that
  /// violet always means exactly that. 8.25:1 on [surface].
  static const aiDraft = Color(0xFF514196);
}

/// One exchange group's colours: [bar] for bars and rings (at least 3:1 on
/// white and on the [AppColors.surfaceSubtle] track), [chipText] on [chipTint]
/// for chips (at least 4.5:1). Always shown next to the group's name.
@immutable
class GroupColor {
  const GroupColor({
    required this.bar,
    required this.chipText,
    required this.chipTint,
  });

  final Color bar;
  final Color chipText;
  final Color chipTint;
}

/// The eight exchange groups' colours (PLANNING #132). They identify a group
/// and nothing else: never an avatar, an icon tile or a status. None is violet.
abstract final class ExchangeGroupColors {
  /// Bar 4.19 / 3.51, chip 5.18.
  static const sut = GroupColor(
    bar: Color(0xFF3E7BD6),
    chipText: Color(0xFF2B5EA8),
    chipTint: Color(0xFFDCE8F7),
  );

  /// Bar 4.48 / 3.75, chip 6.27.
  static const et = GroupColor(
    bar: Color(0xFFC4552F),
    chipText: Color(0xFF8E3517),
    chipTint: Color(0xFFF8E1D8),
  );

  /// Bar 3.69 / 3.09, chip 5.71. Close to [AppColors.warning] in hue; the
  /// group name keeps them apart.
  static const nisasta = GroupColor(
    bar: Color(0xFFB07B12),
    chipText: Color(0xFF7A5406),
    chipTint: Color(0xFFF7EBCB),
  );

  /// Bar 4.94 / 4.14, chip 6.64.
  static const baklagil = GroupColor(
    bar: Color(0xFF8C6A3F),
    chipText: Color(0xFF624A2D),
    chipTint: Color(0xFFEEE5D8),
  );

  /// Bar 4.19 / 3.50, chip 5.48.
  static const sebzeA = GroupColor(
    bar: Color(0xFF478B37),
    chipText: Color(0xFF2F6A22),
    chipTint: Color(0xFFE1EFDC),
  );

  /// Bar 3.88 / 3.24, chip 5.66.
  static const sebzeB = GroupColor(
    bar: Color(0xFF2F8F8A),
    chipText: Color(0xFF1D6662),
    chipTint: Color(0xFFDCF0EC),
  );

  /// Bar 4.26 / 3.57, chip 5.83.
  static const meyve = GroupColor(
    bar: Color(0xFFD2477B),
    chipText: Color(0xFF983055),
    chipTint: Color(0xFFF8E0E9),
  );

  /// Bar 4.37 / 3.66, chip 6.46.
  static const yag = GroupColor(
    bar: Color(0xFF6B7A8F),
    chipText: Color(0xFF46546A),
    chipTint: Color(0xFFE7ECF2),
  );

  static const all = [sut, et, nisasta, baklagil, sebzeA, sebzeB, meyve, yag];
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
    required this.hero,
    required this.onHeroSecondary,
    required this.heroTrack,
    required this.highlight,
    required this.onHighlight,
    required this.warning,
    required this.warningTint,
    required this.aiDraft,
  });

  static const light = AppPalette(
    ground: AppColors.ground,
    surfaceSubtle: AppColors.surfaceSubtle,
    borderSubtle: AppColors.borderSubtle,
    borderStrong: AppColors.borderStrong,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    primaryHover: AppColors.primaryHover,
    hero: AppColors.hero,
    onHeroSecondary: AppColors.onHeroSecondary,
    heroTrack: AppColors.heroTrack,
    highlight: AppColors.highlight,
    onHighlight: AppColors.onHighlight,
    warning: AppColors.warning,
    warningTint: AppColors.warningTint,
    aiDraft: AppColors.aiDraft,
  );

  final Color ground;
  final Color surfaceSubtle;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textSecondary;
  final Color textMuted;
  final Color primaryHover;
  final Color hero;
  final Color onHeroSecondary;
  final Color heroTrack;
  final Color highlight;
  final Color onHighlight;
  final Color warning;
  final Color warningTint;
  final Color aiDraft;

  @override
  AppPalette copyWith({
    Color? ground,
    Color? surfaceSubtle,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textSecondary,
    Color? textMuted,
    Color? primaryHover,
    Color? hero,
    Color? onHeroSecondary,
    Color? heroTrack,
    Color? highlight,
    Color? onHighlight,
    Color? warning,
    Color? warningTint,
    Color? aiDraft,
  }) {
    return AppPalette(
      ground: ground ?? this.ground,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primaryHover: primaryHover ?? this.primaryHover,
      hero: hero ?? this.hero,
      onHeroSecondary: onHeroSecondary ?? this.onHeroSecondary,
      heroTrack: heroTrack ?? this.heroTrack,
      highlight: highlight ?? this.highlight,
      onHighlight: onHighlight ?? this.onHighlight,
      warning: warning ?? this.warning,
      warningTint: warningTint ?? this.warningTint,
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
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
      onHeroSecondary: Color.lerp(onHeroSecondary, other.onHeroSecondary, t)!,
      heroTrack: Color.lerp(heroTrack, other.heroTrack, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      onHighlight: Color.lerp(onHighlight, other.onHighlight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      aiDraft: Color.lerp(aiDraft, other.aiDraft, t)!,
    );
  }
}
