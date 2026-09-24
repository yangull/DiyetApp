import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/triage.dart';
import 'client_detail_screen.dart';
import 'messages_screen.dart';
import 'plan_editor_screen.dart';
import '../util/breakpoints.dart';
import '../util/turkish.dart';
import '../widgets/tone_pill.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({
    super.key,
    required this.onOpenClients,
    required this.onOpenMessages,
    required this.onOpenAppointments,
  });

  final VoidCallback onOpenClients;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenAppointments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final signals = triageSignals(demo);

    return ListView(
      padding: EdgeInsets.all(context.density.pagePadding),
      children: [
        Text('Hoş geldiniz, Dyt. Deniz', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bugün ${demo.draftCount} planınız onayınızı bekliyor.',
          style: text.bodyLarge?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _TriageCard(
          signals: signals,
          onOpenClients: onOpenClients,
          onOpenMessages: onOpenMessages,
          onOpenAppointments: onOpenAppointments,
        ),
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
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Metric(
                  label: 'Yaklaşan randevu',
                  value: '${demo.upcoming.length}',
                ),
              ),
              if (kShowMoney) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Metric(
                    label: 'Tahsil edilmemiş',
                    value: '${demo.unpaidTotal} ₺',
                  ),
                ),
              ],
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
  const _TriageCard({
    required this.signals,
    required this.onOpenClients,
    required this.onOpenMessages,
    required this.onOpenAppointments,
  });

  final List<TriageSignal> signals;
  final VoidCallback onOpenClients;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenAppointments;

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
            _TriageHeader(signals: signals, onOpenClients: onOpenClients),
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
              for (final signal in signals)
                _SignalRow(
                  signal: signal,
                  onOpenMessages: onOpenMessages,
                  onOpenAppointments: onOpenAppointments,
                ),
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

/// The link does the task the reason names. It used to open the client
/// record for every reason, and answering a message then meant going back,
/// opening Mesajlar and finding the client again.
class _SignalRow extends ConsumerWidget {
  const _SignalRow({
    required this.signal,
    required this.onOpenMessages,
    required this.onOpenAppointments,
  });

  final TriageSignal signal;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenAppointments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final clientId = signal.client.id;

    void openClient({bool atWeights = false}) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ClientDetailScreen(clientId: clientId, showWeights: atWeights),
      ),
    );

    final (taskLabel, task) = switch (signal.kind) {
      TriageKind.unansweredMessage => (
        'Mesajı yanıtla',
        () {
          ref.read(selectedConversationProvider.notifier).select(clientId);
          onOpenMessages();
        },
      ),
      TriageKind.noShow => ('Randevuları aç', onOpenAppointments),
      TriageKind.staleWeighIn => (
        'Ölçümleri incele',
        () => openClient(atWeights: true),
      ),
    };

    final taskButton = OutlinedButton(onPressed: task, child: Text(taskLabel));
    // Grey, so each row has one green action: the task (Can, 24 Sep 2026).
    final openButton = TextButton(
      style: TextButton.styleFrom(foregroundColor: palette.textSecondary),
      onPressed: openClient,
      child: const Text('Danışanı aç'),
    );

    if (isPanelPhone(context)) {
      // On a phone the reason gets the full width and the two actions sit
      // under it, instead of both halves wrapping a word per line.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    _icon(signal.kind),
                    size: 20,
                    color: palette.textMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(signal.client.name, style: text.titleMedium),
                      Text(
                        signal.detail,
                        style: text.bodyMedium?.copyWith(
                          color: palette.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(left: 20 + AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [taskButton, openButton],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(_icon(signal.kind), size: 20, color: palette.textMuted),
          const SizedBox(width: AppSpacing.md),
          // Both halves wrap rather than overflow: two labelled actions
          // don't fit beside the reason on a narrow window.
          Expanded(
            flex: 3,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  child: Text(signal.client.name, style: text.titleMedium),
                ),
                Text(
                  signal.detail,
                  style: text.bodyMedium?.copyWith(color: palette.warning),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [taskButton, openButton],
            ),
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
      leading: Icon(Icons.description_outlined, color: palette.textMuted),
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
      // A pale pill: three solid green buttons in a column were the loudest
      // thing on the screen (Can, 24 Sep 2026).
      trailing: OutlinedButton(
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
    final age = DateTime.now().difference(draftedAt);
    final late = age.inHours >= kPlanWaitingWarningHours;

    return TonePill(
      label: '${formatAge(age)} bekliyor',
      tone: late ? PillTone.warning : PillTone.neutral,
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

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
              trUpper(label),
              style: text.labelSmall?.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: text.headlineLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Title, count and "Tüm danışanlar". On a phone all three wrap as one group,
/// so large text never pushes the button off-screen.
class _TriageHeader extends StatelessWidget {
  const _TriageHeader({required this.signals, required this.onOpenClients});

  final List<TriageSignal> signals;
  final VoidCallback onOpenClients;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final title = Text('Dikkat gerekenler', style: text.titleLarge);
    final count = signals.isNotEmpty
        ? TonePill(label: '${signals.length}', tone: PillTone.neutral)
        : Text(
            'temiz',
            style: text.bodyMedium?.copyWith(color: palette.textMuted),
          );
    final button = TextButton(
      onPressed: onOpenClients,
      child: const Text('Tüm danışanlar'),
    );

    if (isPanelPhone(context)) {
      return Wrap(
        spacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [title, count, button],
      );
    }
    return Row(
      children: [
        title,
        const SizedBox(width: AppSpacing.md),
        count,
        const Spacer(),
        button,
      ],
    );
  }
}
