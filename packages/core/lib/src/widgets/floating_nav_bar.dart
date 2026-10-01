import 'package:flutter/material.dart';

import '../theme/tokens/app_spacing.dart';

/// The bottom bar as a solid white floating capsule (PLANNING #135): 16 from
/// the screen edges and above the safe area, the floating shadow, no blur.
/// Wraps a [NavigationBar], which keeps its own semantics and keyboard
/// handling; Android's back button and gestures stay native.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.child});

  final NavigationBar child;

  /// `rgba(0,0,0,0.15) 0 2 16`, the one shadow in the system: only floating
  /// things carry it.
  static const shadow = BoxShadow(
    color: Color(0x26000000),
    offset: Offset(0, 2),
    blurRadius: 16,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: NavigationBarTheme.of(context).backgroundColor,
            shape: const StadiumBorder(),
            shadows: const [shadow],
          ),
          child: ClipPath(
            clipper: const ShapeBorderClipper(shape: StadiumBorder()),
            // The capsule already sits above the safe area.
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
