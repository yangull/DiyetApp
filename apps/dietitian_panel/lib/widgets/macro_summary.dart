import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../demo/demo_models.dart';

/// Four independent measures. Each shares the brand hue and takes its
/// identity from the label rather than from four decorative colors — no
/// progress bar here, since the plan carries no separate per-macro target to
/// measure against yet (only the kcal figure the dietitian sets directly).
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
            child: _Macro(label: 'Kalori', value: '$kcal', unit: 'kcal'),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Macro(
              label: 'Protein',
              value: '${macros.proteinG}',
              unit: 'g',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Macro(
              label: 'Karbonhidrat',
              value: '${macros.carbG}',
              unit: 'g',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Macro(label: 'Yağ', value: '${macros.fatG}', unit: 'g'),
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

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
          ],
        ),
      ),
    );
  }
}
