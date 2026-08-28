import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key, required this.onOpenClients});

  final VoidCallback onOpenClients;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return ListView(
      padding: EdgeInsets.all(context.density.pagePadding),
      children: [
        Text('Hoş geldiniz, Dyt. Kutay', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bugün ${demo.draftCount} planınız onayınızı bekliyor.',
          style: text.bodyLarge?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Metric(
                  label: 'Aktif danışan',
                  value: '${demo.clients.length}',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Metric(
                  label: 'Onay bekleyen plan',
                  value: '${demo.draftCount}',
                  emphasise: demo.draftCount > 0,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Metric(
                  label: 'Yaklaşan randevu',
                  value: '${demo.upcoming.length}',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Metric(
                  label: 'Tahsil edilmemiş',
                  value: '${demo.unpaidTotal} ₺',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Sıradaki işler', style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: [
              for (final plan in demo.plans.where((p) => p.isDraft))
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  leading: Icon(
                    Icons.description_outlined,
                    color: palette.aiDraft,
                  ),
                  title: Text(
                    demo.clients.firstWhere((c) => c.id == plan.clientId).name,
                    style: text.titleMedium,
                  ),
                  subtitle: Text(
                    '${plan.day} · ${plan.kcal} kcal · taslak hazır',
                    style: text.bodySmall?.copyWith(color: palette.textMuted),
                  ),
                  trailing: TextButton(
                    onPressed: onOpenClients,
                    child: const Text('İncele'),
                  ),
                ),
              if (demo.draftCount == 0)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Bekleyen plan yok.',
                    style: text.bodyMedium?.copyWith(color: palette.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: text.labelSmall?.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: text.headlineLarge?.copyWith(
                color: emphasise
                    ? context.palette.aiDraft
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
