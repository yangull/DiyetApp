import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Placeholder brand mark: a "W" on a rounded Charcoal tile, drawn in code.
/// Replace the body when the real logo exists; callers only know [size].
class WellkitMark extends StatelessWidget {
  const WellkitMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.charcoal,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Text(
          'W',
          textScaler: TextScaler.noScaling,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: palette.onCharcoal,
            fontSize: size * 0.5,
            height: 1,
          ),
        ),
      ),
    );
  }
}
