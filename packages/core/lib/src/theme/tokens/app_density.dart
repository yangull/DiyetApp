import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppDensityProfile { comfortable, compact }

/// Metrics that differ between touch layouts and dense pointer layouts.
///
/// Colors, font families and semantic meanings deliberately do NOT live here:
/// they are identical on both sides, and that is what makes the two apps read
/// as one product. Only spacing-like measurements change.
@immutable
class AppDensity extends ThemeExtension<AppDensity> {
  const AppDensity({
    required this.profile,
    required this.pagePadding,
    required this.cardPadding,
    required this.sectionGap,
    required this.cardRadius,
    required this.controlRadius,
    required this.controlHeight,
    required this.inputHeight,
    required this.rowHeight,
    required this.avatarSize,
  });

  /// Touch: the client app, and the panel on phones and tablets. HIG's iOS
  /// sizes with 48 px targets (#135).
  static const comfortable = AppDensity(
    profile: AppDensityProfile.comfortable,
    pagePadding: 20,
    cardPadding: 20,
    sectionGap: 32,
    cardRadius: 24,
    controlRadius: 12,
    controlHeight: 48,
    inputHeight: 52,
    rowHeight: 72,
    avatarSize: 40,
  );

  /// The panel in a computer browser (#135): HIG's macOS sizes, a draft Can
  /// judges on the real panel.
  static const compact = AppDensity(
    profile: AppDensityProfile.compact,
    pagePadding: 24,
    cardPadding: 16,
    sectionGap: 24,
    cardRadius: 16,
    controlRadius: 8,
    controlHeight: 32,
    inputHeight: 32,
    rowHeight: 40,
    avatarSize: 28,
  );

  /// Density by input, not width (#135): compact only in a browser on
  /// Windows, macOS or Linux. Flutter's web engine reports an iPad's Safari
  /// as iOS when it has touch points.
  static AppDensity forPlatform({
    bool isWeb = kIsWeb,
    TargetPlatform? platform,
  }) {
    final target = platform ?? defaultTargetPlatform;
    final pointer =
        target == TargetPlatform.windows ||
        target == TargetPlatform.macOS ||
        target == TargetPlatform.linux;
    return isWeb && pointer ? compact : comfortable;
  }

  final AppDensityProfile profile;
  final double pagePadding;
  final double cardPadding;
  final double sectionGap;
  final double cardRadius;
  final double controlRadius;
  final double controlHeight;
  final double inputHeight;
  final double rowHeight;
  final double avatarSize;

  bool get isCompact => profile == AppDensityProfile.compact;

  @override
  AppDensity copyWith({
    AppDensityProfile? profile,
    double? pagePadding,
    double? cardPadding,
    double? sectionGap,
    double? cardRadius,
    double? controlRadius,
    double? controlHeight,
    double? inputHeight,
    double? rowHeight,
    double? avatarSize,
  }) {
    return AppDensity(
      profile: profile ?? this.profile,
      pagePadding: pagePadding ?? this.pagePadding,
      cardPadding: cardPadding ?? this.cardPadding,
      sectionGap: sectionGap ?? this.sectionGap,
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      controlHeight: controlHeight ?? this.controlHeight,
      inputHeight: inputHeight ?? this.inputHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      avatarSize: avatarSize ?? this.avatarSize,
    );
  }

  @override
  AppDensity lerp(AppDensity? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}
