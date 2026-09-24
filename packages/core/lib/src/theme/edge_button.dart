import 'package:flutter/material.dart';

/// Puts a text button's icon or label on the layout edge (design rule 6)
/// while its pill keeps its padding and hangs into the margin, so the hover
/// and focus fill never touches the text. The padding is pinned, not left to
/// Material, which shrinks it as the text scale grows.
class EdgeButton extends StatelessWidget {
  const EdgeButton({super.key, required this.child, this.end = false});

  /// A [TextButton] or [TextButton.icon].
  final Widget child;

  /// Hang past the end edge instead of the start edge.
  final bool end;

  static const inset = 12.0;

  @override
  Widget build(BuildContext context) {
    final base = TextButtonTheme.of(context).style ?? const ButtonStyle();
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final outward = end != rtl ? inset : -inset;
    return Transform.translate(
      offset: Offset(outward, 0),
      child: TextButtonTheme(
        data: TextButtonThemeData(
          style: base.copyWith(
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: inset),
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
