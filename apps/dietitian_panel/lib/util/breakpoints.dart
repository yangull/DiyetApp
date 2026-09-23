import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Below this width the panel is a phone layout: a bottom bar and the
/// comfortable density with touch-sized controls (PLANNING #38, #64). It is
/// Material's "compact" window class boundary.
const kPanelPhoneMaxWidth = 600.0;

bool isPanelPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kPanelPhoneMaxWidth;

AppDensity panelDensityFor(double width) =>
    width < kPanelPhoneMaxWidth ? AppDensity.comfortable : AppDensity.compact;

/// `MaterialApp.builder` for both panel entry points: picks the density from
/// the window width, so every route and dialog below it gets the right one.
Widget panelThemeBuilder(BuildContext context, Widget? child) {
  final width = MediaQuery.sizeOf(context).width;
  return Theme(
    data: AppTheme.light(panelDensityFor(width)),
    child: child ?? const SizedBox.shrink(),
  );
}
