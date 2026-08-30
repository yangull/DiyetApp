import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/triage.dart';
import 'client_detail_screen.dart';
import 'plan_editor_screen.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key, required this.onOpenClients});

  final VoidCallback onOpenClients;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final signals = triageSignals(demo);

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
        _TriageCard(signals: signals, onOpenClients: onOpenClients),
        const SizedBox(height: AppSpacing.xxl),
        Text('Sıradaki işler', style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: [
              for (final plan in demo.plans.where((p) => p.isDraft))
                _DraftRow(plan: plan),
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
      ],
    );
  }
}

/// Our guess at what a dietitian opens the panel to find out. It is placed
/// above the counters, and the counters were pushed below the work, because
/// "5 aktif danışan" is not a thing anyone acts on at nine in the morning.
class _TriageCard extends StatelessWidget {
  const _TriageCard({required this.signals, required this.onOpenClients});

  final List<TriageSignal> signals;
  final VoidCallback onOpenClients;

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
            Row(
              children: [
                Text('Dikkat gerekenler', style: text.titleLarge),
                const SizedBox(width: AppSpacing.md),
                if (signals.isNotEmpty)
                  _Count(count: signals.length)
                else
                  Text(
                    'temiz',
                    style: text.bodyMedium?.copyWith(color: palette.textMuted),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: onOpenClients,
                  child: const Text('Tüm danışanlar'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (signals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(
                  'Şu an geride kalan danışan görünmüyor.',
                  style: text.bodyMedium?.copyWith(color: palette.textMuted),
                ),
              )
            else
              for (final signal in signals) _SignalRow(signal: signal),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bu liste bizim tahminimiz: 7 gündür tartılmayan, 24 saattir '
              'yanıt bekleyen ve randevusuna gelmeyen danışanlar. Siz sabah '
              'ilk neye bakıyorsunuz, hangi eşikleri kullanıyorsunuz?',
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.signal});

  final TriageSignal signal;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(_icon(signal.kind), size: 20, color: palette.warning),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 160,
            child: Text(signal.client.name, style: text.titleMedium),
          ),
          Expanded(
            child: Text(
              signal.detail,
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ClientDetailScreen(clientId: signal.client.id),
              ),
            ),
            child: const Text('Danışanı aç'),
          ),
        ],
      ),
    );
  }

  static IconData _icon(TriageKind kind) => switch (kind) {
    TriageKind.staleWeighIn => Icons.monitor_weight_outlined,
    TriageKind.unansweredMessage => Icons.mark_chat_unread_outlined,
    TriageKind.noShow => Icons.event_busy_outlined,
  };
}

/// "İncele" used to switch to the client list, which buried the one screen
/// this product turns on. It opens the draft itself now.
class _DraftRow extends ConsumerWidget {
  const _DraftRow({required this.plan});

  final DietPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(plan.clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: Icon(Icons.description_outlined, color: palette.aiDraft),
      title: Row(
        children: [
          Flexible(child: Text(client.name, style: text.titleMedium)),
          const SizedBox(width: AppSpacing.md),
          _WaitingBadge(draftedAt: plan.draftedAt),
        ],
      ),
      subtitle: Text(
        '${plan.day} · ${plan.kcal} kcal · taslak hazır',
        style: text.bodySmall?.copyWith(color: palette.textMuted),
      ),
      trailing: FilledButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlanEditorScreen(clientId: plan.clientId),
          ),
        ),
        child: const Text('İncele'),
      ),
    );
  }
}

/// Amber past two days. The threshold is a guess and the copy says so on the
/// card above; the badge itself stays short enough to scan.
class _WaitingBadge extends StatelessWidget {
  const _WaitingBadge({required this.draftedAt});

  final DateTime draftedAt;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final age = DateTime.now().difference(draftedAt);
    final late = age.inHours >= kPlanWaitingWarningHours;
    final color = late ? palette.warning : palette.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${formatAge(age)} bekliyor',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: palette.warning,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.surface),
      ),
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
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
