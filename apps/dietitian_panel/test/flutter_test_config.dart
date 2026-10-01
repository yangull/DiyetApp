import 'dart:async';

import 'package:core/core.dart';
import 'package:dietitian_panel/util/breakpoints.dart';
import 'package:flutter/widgets.dart';

/// The panel's density follows the input (PLANNING #135), which a VM test
/// can't see. Tests stand in for the two real cases by window width: a wide
/// window is the panel in a computer browser (compact), a narrow one a phone
/// (touch).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  debugPanelDensity = densityByTestWidth;
  await testMain();
}

AppDensity densityByTestWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kPanelPhoneMaxWidth
    ? AppDensity.comfortable
    : AppDensity.compact;
