import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';
import '../util/panel_date.dart';
import '../widgets/status_pill.dart';
import '../widgets/weight_chart.dart';
import 'plan_editor_screen.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clients.firstWhere((c) => c.id == clientId);
    final plan = demo.planFor(clientId);
    final weights = demo.weights[clientId] ?? const [];
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      body: ListView(
        padding: EdgeInsets.all(context.density.pagePadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Danışan bilgileri', style: text.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.x3,
                    runSpacing: AppSpacing.lg,
                    children: [
                      _Fact(label: 'Yaş', value: '${client.age}'),
                      _Fact(label: 'Boy', value: '${client.heightCm} cm'),
                      _Fact(
                        label: 'Güncel kilo',
                        value: '${client.weightKg.toStringAsFixed(1)} kg',
                      ),
                      _Fact(label: 'Hedef', value: client.goal),
                      _Fact(
                        label: 'Başlangıç',
                        value: formatDate(client.startedOn),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'NOT',
                    style: text.labelSmall?.copyWith(color: palette.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    client.note,
                    style: text.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Diyet planı', style: text.titleLarge),
                      const SizedBox(width: AppSpacing.md),
                      StatusPill(state: plan.state),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${plan.day} · ${plan.kcal} kcal · ${plan.meals.length} öğün',
                    style: text.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlanEditorScreen(clientId: clientId),
                        ),
                      ),
                      child: Text(
                        plan.isDraft ? 'Taslağı düzenle' : 'Planı aç',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Ölçüm geçmişi', style: text.titleLarge),
                      const Spacer(),
                      Text(
                        '${weights.length} ölçüm · haftalık',
                        style: text.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (weights.isEmpty)
                    Text(
                      'Henüz ölçüm kaydı yok.',
                      style: text.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
                    )
                  else ...[
                    WeightChart(entries: weights),
                    const SizedBox(height: AppSpacing.lg),
                    for (final entry in weights.reversed.take(4))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 96,
                              child: Text(
                                formatDate(entry.date),
                                style: text.bodyMedium?.copyWith(
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.kg.toStringAsFixed(1)} kg',
                              style: text.titleMedium?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ölçümleri şimdilik yalnızca görüntülüyoruz. Kilo dışında '
                    'hangi ölçümleri aldığınızı sizden öğrenmek istiyoruz.',
                    style: text.bodySmall?.copyWith(color: palette.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: text.labelSmall?.copyWith(color: context.palette.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: text.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
