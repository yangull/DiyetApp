import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// What a pill's colour means. Each tone is a token pair measured in
/// `core_test.dart`; the label always says the same thing in words.
enum PillTone { approved, aiDraft, warning, neutral }

/// A status label as text on a tint, without a border (#135).
///
/// "Onaylı" is green with a tick (Can, 1 Oct 2026, reversing the 24 Sep grey
/// pill): buttons are black now, so green means "approved", not "press".
/// Neutral is the palette's inset: Cloud Card on the canvas, white in a card.
class TonePill extends StatelessWidget {
  const TonePill({super.key, required this.label, required this.tone});

  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (fill, ink) = switch (tone) {
      PillTone.approved => (palette.accentTint, palette.accentStrong),
      PillTone.aiDraft => (palette.aiDraftTint, palette.aiDraft),
      PillTone.warning => (palette.warningTint, palette.warning),
      PillTone.neutral => (palette.inset, palette.ink),
    };
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: ink);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tone == PillTone.approved) ...[
            Icon(AppIcons.check, size: 14, color: ink),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(child: Text(label, style: style)),
        ],
      ),
    );
  }
}
