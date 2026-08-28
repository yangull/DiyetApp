import 'package:flutter/material.dart';

enum AppDensityProfile { comfortable, compact }

/// Metrics that differ between the client app and the dietitian panel.
///
/// Colors, font families and semantic meanings deliberately do NOT live here:
/// they are identical on both sides, and that is what makes the two apps read
/// as one product. Only spacing-like measurements change.
@immutable
class AppDensity extends ThemeExtension<AppDensity> {
  const AppDensity({
    required this.profile,
    required this.pagePadding,
    required this.cardRadius,
    required this.controlRadius,
    required this.controlHeight,
    required this.inputHeight,
    required this.rowHeight,
    required this.avatarSize,
  });

  /// Client mobile app.
  static const comfortable = AppDensity(
    profile: AppDensityProfile.comfortable,
    pagePadding: 20,
    cardRadius: 14,
    controlRadius: 10,
    controlHeight: 48,
    inputHeight: 52,
    rowHeight: 72,
    avatarSize: 40,
  );

  /// Dietitian web panel, where a screenful of clients matters more than air.
  static const compact = AppDensity(
    profile: AppDensityProfile.compact,
    pagePadding: 24,
    cardRadius: 10,
    controlRadius: 8,
    controlHeight: 36,
    inputHeight: 38,
    rowHeight: 44,
    avatarSize: 28,
  );

  final AppDensityProfile profile;
  final double pagePadding;
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
