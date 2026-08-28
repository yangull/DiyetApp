import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../demo/demo_models.dart';

/// Four independent measures, each against its own target — not four competing
/// series. So they share the brand hue and take their identity from the label
/// rather than from four decorative colors. Numbers lead; the bar is secondary.
class MacroSummary extends StatelessWidget {
  const MacroSummary({super.key, required this.kcal, required this.macros});

  final int kcal;
  final Macros macros;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Macro(
              label: 'Kalori',
              value: '$kcal',
              unit: 'kcal',
              filled: 0.94,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Macro(
              label: 'Protein',
              value: '${macros.proteinG}',
              unit: 'g',
              filled: 0.88,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Macro(
              label: 'Karbonhidrat',
              value: '${macros.carbG}',
              unit: 'g',
              filled: 0.97,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Macro(
              label: 'Yağ',
              value: '${macros.fatG}',
              unit: 'g',
              filled: 0.81,
            ),
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({
    required this.label,
    required this.value,
    required this.unit,
    required this.filled,
  });

  final String label;
  final String value;
  final String unit;
  final double filled;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: text.labelSmall?.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: text.headlineMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: text.bodySmall?.copyWith(color: palette.textMuted),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: filled,
                minHeight: 4,
                backgroundColor: palette.surfaceSubtle,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'hedefin %${(filled * 100).round()}\'i',
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
