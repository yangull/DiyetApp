import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';
import '../widgets/weight_chart.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return ListView(
      padding: EdgeInsets.all(context.density.pagePadding),
      children: [
        Text('Takip ve raporlar', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Danışan başına kilo seyri. Hangi ölçümleri düzenli takip '
          'ettiğinizi bize anlatın — bu ekran ona göre şekillenecek.',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final client in demo.clients) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(client.name, style: text.titleLarge),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        client.goal,
                        style: text.bodyMedium?.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                      const Spacer(),
                      _Delta(entries: demo.weights[client.id]!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  WeightChart(entries: demo.weights[client.id]!),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.entries});

  final List entries;

  @override
  Widget build(BuildContext context) {
    final first = entries.first.kg as double;
    final last = entries.last.kg as double;
    final delta = last - first;
    final down = delta < 0;

    return Row(
      children: [
        Icon(
          down ? Icons.south : Icons.north,
          size: 16,
          color: context.palette.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '${delta.abs().toStringAsFixed(1)} kg',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
        const SizedBox(width: 6),
        Text(
          'toplam',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.palette.textMuted),
        ),
      ],
    );
  }
}
