import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/progress.dart';
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
          'Danışan başına kilo seyri, hedef kilosuna göre değerlendirilmiş. '
          'Kilo koruma hedefindeki bir danışanda düşüş de dikkat gerektirir; '
          'bu ayrımı doğru mu kuruyoruz, ve hangi ölçümleri düzenli takip '
          'ediyorsunuz?',
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
                      _Delta(client: client, entries: demo.weights[client.id]!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  WeightChart(
                    entries: demo.weights[client.id]!,
                    targetKg: client.targetWeightKg,
                  ),
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

/// The arrow says which way the scale moved; the words next to it say whether
/// that is what this client wanted. Colour follows the verdict, not the
/// direction — see `progress.dart`.
class _Delta extends StatelessWidget {
  const _Delta({required this.client, required this.entries});

  final DemoClient client;
  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final progress = weightProgress(client, entries);
    final color = switch (progress.verdict) {
      ProgressVerdict.onTrack => AppColors.primary,
      ProgressVerdict.offTrack => palette.warning,
      ProgressVerdict.neutral => palette.textMuted,
    };

    return Row(
      children: [
        Icon(
          progress.isLoss ? Icons.south : Icons.north,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${progress.deltaKg.abs().toStringAsFixed(1)} kg',
          style: text.titleMedium?.copyWith(
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          progress.label,
          style: text.bodySmall?.copyWith(color: palette.textMuted),
        ),
      ],
    );
  }
}
