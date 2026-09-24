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
import '../widgets/tone_pill.dart';

class OverviewScreen extends ConsumerStatefulWidget {
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
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  final _draftsKey = GlobalKey();

  void _showDrafts() {
    final target = _draftsKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: AppMotion.of(context, AppMotion.change),
      curve: AppMotion.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final signals = triageSignals(demo);

    // Not a lazy ListView: "onay bekliyor" scrolls to Sıradaki işler, which
    // has to be built for that, even below the fold on a phone.
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.density.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The client's Bugün pattern: the date, then the greeting in bold.
          Text(
            formatTodayLabel(DateTime.now()),
            style: text.bodyMedium?.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: 2),
          Text('Hoş geldiniz, Dyt. Deniz', style: text.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          _CountsLine(
            counts: [
              (demo.clients.length, 'danışan', widget.onOpenClients),
              (demo.draftCount, 'onay bekliyor', _showDrafts),
              (demo.upcoming.length, 'randevu', widget.onOpenAppointments),
              if (kShowMoney) (demo.unpaidTotal, '₺ tahsil edilmemiş', null),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _TriageCard(
            signals: signals,
            onOpenClients: widget.onOpenClients,
            onOpenMessages: widget.onOpenMessages,
            onOpenAppointments: widget.onOpenAppointments,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Sıradaki işler', key: _draftsKey, style: text.titleLarge),
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
                      style: text.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
          // On a phone Mesajlar opens the thread itself as a page over this
          // screen, so back returns here; wide screens switch tabs.
          if (!isPanelPhone(context)) onOpenMessages();
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
      style: AppTheme.quietButton,
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

    void open() => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanEditorScreen(clientId: plan.clientId),
      ),
    );
    // A pale pill: three solid green buttons in a column were the loudest
    // thing on the screen (Can, 24 Sep 2026).
    final review = OutlinedButton(onPressed: open, child: const Text('İncele'));
    // Name and status wrap, so a long name or a large text size moves the
    // status to the next line instead of overflowing.
    final title = Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(client.name, style: text.titleMedium),
        _WaitingBadge(draftedAt: plan.draftedAt),
      ],
    );
    final subtitle = Text(
      '${plan.day} · ${plan.kcal} kcal · taslak hazır',
      style: text.bodySmall?.copyWith(color: palette.textMuted),
    );
    final icon = Icon(Icons.description_outlined, color: palette.textMuted);

    if (isPanelPhone(context)) {
      // As in the triage rows: the text gets the full width, the action
      // sits under it.
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: AppSpacing.xs),
                  subtitle,
                  const SizedBox(height: AppSpacing.sm),
                  review,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: icon,
      title: title,
      subtitle: subtitle,
      trailing: review,
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

/// One slim line in place of the stat tiles: "5 danışan · 3 onay bekliyor ·
/// 4 randevu". Each count opens where its items are. The tiles sat below the
/// work because nobody acts on "5 aktif danışan"; a line under the greeting
/// keeps the numbers without the weight.
class _CountsLine extends StatelessWidget {
  const _CountsLine({required this.counts});

  final List<(int, String, VoidCallback?)> counts;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final separator = Text(
      ' · ',
      style: text.bodyLarge?.copyWith(color: palette.textMuted),
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (i, (value, label, onTap)) in counts.indexed)
          // The dot rides on the end of its count, so a wrapped line never
          // starts with one.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, context.density.controlHeight),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$value',
                          style: AppTypography.figures(
                            text.bodyLarge!.fontSize!,
                            text.bodyLarge!.height! * text.bodyLarge!.fontSize!,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                        TextSpan(
                          text: ' $label',
                          style: text.bodyLarge?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (i < counts.length - 1) separator,
            ],
          ),
      ],
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
        Expanded(
          child: Wrap(
            spacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [title, count],
          ),
        ),
        button,
      ],
    );
  }
}
