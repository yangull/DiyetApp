import 'package:flutter/widgets.dart';

/// Motion only on a change of state (design rule 12): a ring or bar animates
/// when its value changes, never because a screen opened.
abstract final class AppMotion {
  /// A ring or bar moving to a new value.
  static const change = Duration(milliseconds: 400);

  /// The check that confirms a meal was marked eaten.
  static const pop = Duration(milliseconds: 200);

  static const curve = Curves.easeOut;

  /// [duration], or zero when the OS asks for reduced motion.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
