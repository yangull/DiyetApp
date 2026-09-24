import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// What a pill's colour means. Each tone is a token pair measured in
/// `core_test.dart`; the label always says the same thing in words.
enum PillTone { approved, aiDraft, warning, neutral }

/// A status label as text on a tint, without a border (Sade, #133).
///
/// "Approved" is grey with a black tick, not green (Can, 24 Sep 2026): a pale
/// green pill is the secondary button, and green means "press this".
class TonePill extends StatelessWidget {
  const TonePill({super.key, required this.label, required this.tone});

  final String label;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (fill, ink) = switch (tone) {
      PillTone.approved => (palette.surfaceSubtle, AppColors.textPrimary),
      PillTone.aiDraft => (palette.aiDraftTint, palette.aiDraft),
      PillTone.warning => (palette.warningTint, palette.warning),
      PillTone.neutral => (palette.surfaceSubtle, palette.textSecondary),
    };
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: ink, fontWeight: FontWeight.w600);

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
            Icon(Icons.check, size: 14, color: ink),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(child: Text(label, style: style)),
        ],
      ),
    );
  }
}
