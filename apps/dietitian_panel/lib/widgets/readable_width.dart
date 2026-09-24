import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Forms and text pages stop growing at this width and centre (Can,
/// 24 Sep 2026); lists and tables keep the full width. On a laptop the
/// client record's fields and the intake form ran to 1500 px.
const kReadableWidth = 1100.0;

/// Page padding that centres the content once [available] is wider than
/// [kReadableWidth]. Padding rather than a narrower box, so the scroll bar
/// stays at the window's edge.
EdgeInsets readablePadding(double available, double pagePadding) {
  final side = math.max(pagePadding, (available - kReadableWidth) / 2);
  return EdgeInsets.symmetric(horizontal: side, vertical: pagePadding);
}
