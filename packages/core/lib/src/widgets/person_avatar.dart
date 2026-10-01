import 'package:flutter/material.dart';

import '../format/turkish_text.dart';
import '../theme/app_theme.dart';

/// First and last initials, skipping titles such as "Dyt.", in Turkish
/// capitals ("ismail" gives "İ", not "I").
String initialsOf(String? fullName) {
  final parts = (fullName ?? '').trim().split(RegExp(r'\s+'))
    ..removeWhere((p) => p.isEmpty || p.endsWith('.'));
  if (parts.isEmpty) return '';
  final first = parts.first.characters.first;
  final last = parts.length > 1 ? parts.last.characters.first : '';
  return trUpper(first + last);
}

/// A person's initials on a pale disc, in both apps. Neutral on purpose:
/// colour never marks people (design rule 15), and it is not a photo (rule 9).
/// In a list it gives each row an anchor the eye can run down (direction B,
/// PLANNING #133). Decorative: the name beside it is what a screen reader
/// reads, so the disc is left out of the semantics tree.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    this.size,
    this.background,
  });

  final String? name;

  /// Defaults to the density's avatar size.
  final double? size;

  /// Defaults to the palette's `inset`: Cloud Card on the canvas, white
  /// inside a `CloudCard`.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final side = size ?? context.density.avatarSize;
    final text = Theme.of(context).textTheme;
    final style = side > 56
        ? text.titleLarge
        : side >= 36
        ? text.titleMedium
        : text.labelMedium?.copyWith(fontWeight: FontWeight.w600);
    return ExcludeSemantics(
      child: Container(
        width: side,
        height: side,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background ?? palette.inset,
          shape: BoxShape.circle,
        ),
        // The disc keeps its size at large text; initials that grew with it
        // would be clipped by the circle.
        child: Text(
          initialsOf(name),
          textScaler: TextScaler.noScaling,
          style: style?.copyWith(color: palette.textSecondary),
        ),
      ),
    );
  }
}
