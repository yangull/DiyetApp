import 'package:flutter/material.dart';

import '../theme/edge_button.dart';
import '../theme/tokens/app_spacing.dart';

/// The width a text button needs for [label] at the current text size,
/// padding included, so a row can tell whether it still fits beside its words.
double textButtonWidth(
  BuildContext context,
  String label, {
  bool icon = false,
}) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: Theme.of(context).textTheme.labelLarge),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final width = painter.width + 2 * EdgeButton.inset + (icon ? 18 + 8 : 0);
  painter.dispose();
  return width;
}

/// A row in direction B (PLANNING #133): who and what on the left, its one
/// action at the right end as green text, the label on the row's edge. When
/// the two can't share a line (a narrow phone, large text) the action drops
/// under the words, its label on their left edge, so nothing squeezes a name
/// into a column two words wide.
class ActionRow extends StatelessWidget {
  const ActionRow({
    super.key,
    required this.body,
    this.lead,
    this.leadWidth = 0,
    this.meta,
    this.metaWidth = 0,
    this.actionLabel,
    this.actionSemantics,
    this.onAction,
    this.minBodyWidth = 140,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final Widget body;

  /// An avatar or a time, in a column [leadWidth] wide.
  final Widget? lead;
  final double leadWidth;

  /// A fixed column between the words and the action, shown only while
  /// everything fits on one line.
  final Widget? meta;
  final double metaWidth;

  final String? actionLabel;

  /// What a screen reader says for the action when the visible label is
  /// short ("Yanıtla" means little without the client's name).
  final String? actionSemantics;
  final VoidCallback? onAction;
  final double minBodyWidth;
  final CrossAxisAlignment crossAxisAlignment;

  static const gap = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    Widget? action(bool end) => label == null
        ? null
        : EdgeButton(
            end: end,
            child: TextButton(
              onPressed: onAction,
              child: Text(label, semanticsLabel: actionSemantics),
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final leadSpace = lead == null ? 0.0 : leadWidth + gap;
        final actionSpace = label == null
            ? 0.0
            : textButtonWidth(context, label) + gap;
        final metaSpace = meta == null ? 0.0 : metaWidth + gap;
        final bodyRoom =
            constraints.maxWidth - leadSpace - actionSpace - metaSpace;
        final fits = bodyRoom >= minBodyWidth * scale;

        if (fits) {
          return Row(
            crossAxisAlignment: crossAxisAlignment,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (lead != null) ...[
                SizedBox(width: leadWidth, child: lead),
                const SizedBox(width: gap),
              ],
              Expanded(child: body),
              if (meta != null) ...[
                const SizedBox(width: gap),
                SizedBox(width: metaWidth, child: meta),
              ],
              if (label != null) ...[const SizedBox(width: gap), action(true)!],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment:
                  crossAxisAlignment == CrossAxisAlignment.baseline
                  ? CrossAxisAlignment.baseline
                  : CrossAxisAlignment.start,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (lead != null) ...[
                  SizedBox(width: leadWidth, child: lead),
                  const SizedBox(width: gap),
                ],
                Expanded(child: body),
              ],
            ),
            if (label != null)
              Padding(
                padding: EdgeInsetsDirectional.only(start: leadSpace),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: action(false),
                ),
              ),
          ],
        );
      },
    );
  }
}
