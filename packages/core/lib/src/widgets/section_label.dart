import 'package:flutter/material.dart';

import '../format/turkish_text.dart';
import '../theme/app_theme.dart';
import '../theme/edge_button.dart';
import '../theme/tokens/app_spacing.dart';
import 'action_row.dart';

/// A section's name in small capitals on the ground (direction B, PLANNING
/// #133): quiet, so the screen's one focal card leads. [count] follows in
/// grey; [actionLabel] is a grey link with a chevron at the right end, its
/// text on the edge, and drops under the name when both don't fit.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.title, {
    super.key,
    this.count,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? count;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final count = this.count;
    final label = actionLabel;
    final name = Wrap(
      spacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Semantics(
          header: true,
          child: Text(
            trUpper(title),
            style: text.labelSmall?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (count != null)
          Text(
            trUpper(count),
            style: text.labelSmall?.copyWith(color: palette.textMuted),
          ),
      ],
    );
    Widget action(bool end) =>
        SectionLink(label: label!, onPressed: onAction, end: end);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: context.density.controlHeight),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (label == null) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: name,
            );
          }
          final room =
              constraints.maxWidth -
              textButtonWidth(context, label, icon: true);
          final scale = MediaQuery.textScalerOf(context).scale(1);
          if (room >= 120 * scale) {
            return Row(
              children: [
                Expanded(child: name),
                const SizedBox(width: AppSpacing.md),
                action(true),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              name,
              action(false),
            ],
          );
        },
      ),
    );
  }
}

/// A grey link with a chevron that leads to a whole section ("Tüm
/// randevular"). Grey because it often sits on the ground, where green text
/// fails AA under the focus overlay; its text sits on the edge ([end] for a
/// right edge).
class SectionLink extends StatelessWidget {
  const SectionLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.end = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool end;

  @override
  Widget build(BuildContext context) {
    return EdgeButton(
      end: end,
      child: TextButton.icon(
        style: AppTheme.quietButton,
        onPressed: onPressed,
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.chevron_right, size: 18),
        label: Text(label),
      ),
    );
  }
}
