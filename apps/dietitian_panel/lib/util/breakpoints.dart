import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Below this width the panel lays out for a phone: a bottom bar instead of
/// the rail (PLANNING #38). Layout only; density follows the input (#135).
const kPanelPhoneMaxWidth = 600.0;

bool isPanelPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kPanelPhoneMaxWidth;

/// Tests stand in for the input here: `flutter test` is never web, so it can
/// tell neither a computer browser nor a phone (see flutter_test_config.dart).
@visibleForTesting
AppDensity Function(BuildContext context)? debugPanelDensity;

/// Density by input, not width (PLANNING #135, was C44): compact only in a
/// browser on Windows, macOS or Linux; touch sizes on phones and tablets.
AppDensity panelDensity(BuildContext context) =>
    debugPanelDensity?.call(context) ?? AppDensity.forPlatform();

/// `MaterialApp.builder` for both panel entry points, so every route and
/// dialog below it gets the panel's density.
Widget panelThemeBuilder(BuildContext context, Widget? child) {
  return Theme(
    data: AppTheme.light(panelDensity(context)),
    child: child ?? const SizedBox.shrink(),
  );
}
