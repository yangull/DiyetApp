import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Forms and text pages stop growing at this width and centre (Can,
/// 24 Sep 2026); lists keep the full width. On a laptop the
/// client record's fields and the intake form ran to 1500 px.
const kReadableWidth = 1100.0;

/// A two-column screen (Genel Bakış: the work beside the agenda) or a wide
/// table (Danışanlar) stops here and centres (direction B, PLANNING #133), so
/// neither column nor row stretches.
const kDashboardWidth = 1200.0;

/// Page padding that centres the content once [available] is wider than
/// [maxWidth]. Padding rather than a narrower box, so the scroll bar stays at
/// the window's edge.
EdgeInsets readablePadding(
  double available,
  double pagePadding, {
  double maxWidth = kReadableWidth,
}) {
  final side = math.max(pagePadding, (available - maxWidth) / 2);
  return EdgeInsets.symmetric(horizontal: side, vertical: pagePadding);
}
