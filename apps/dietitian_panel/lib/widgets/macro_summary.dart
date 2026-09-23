import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../demo/demo_models.dart';
import '../util/turkish.dart';

/// Four independent measures. Each shares the brand hue and takes its
/// identity from the label rather than from four decorative colors — no
/// progress bar here, since the plan carries no separate per-macro target to
/// measure against yet (only the kcal figure the dietitian sets directly).
///
/// Sitting right above the meals, the boxes read as meal totals, but nothing
/// here is summed from the meals. The caption and the kcal label say so.
class MacroSummary extends StatelessWidget {
  const MacroSummary({super.key, required this.kcal, required this.macros});

  final int kcal;
  final Macros macros;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Örnek makro hedefleri · öğünlerden hesaplanmaz',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.palette.textMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        _row(),
      ],
    );
  }

  /// Four across when there is room, two by two in the plan editor's side
  /// panel.
  Widget _row() {
    final boxes = [
      _Macro(label: 'Belirlenen enerji hedefi', value: '$kcal', unit: 'kcal'),
      _Macro(label: 'Protein', value: '${macros.proteinG}', unit: 'g'),
      _Macro(label: 'Karbonhidrat', value: '${macros.carbG}', unit: 'g'),
      _Macro(label: 'Yağ', value: '${macros.fatG}', unit: 'g'),
    ];

    Widget line(List<_Macro> items) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            Expanded(child: items[i]),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 560
          ? line(boxes)
          : Column(
              children: [
                line(boxes.sublist(0, 2)),
                const SizedBox(height: AppSpacing.md),
                line(boxes.sublist(2)),
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
              trUpper(label),
              style: text.labelSmall?.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            // One text run so a narrow box wraps the unit instead of
            // overflowing.
            Text.rich(
              TextSpan(
                text: value,
                style: text.headlineMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                children: [
                  TextSpan(
                    text: ' $unit',
                    style: text.bodySmall?.copyWith(color: palette.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
