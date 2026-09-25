import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/triage.dart';
import '../util/breakpoints.dart';
import '../util/panel_date.dart';
import '../widgets/readable_width.dart';
import '../widgets/tone_pill.dart';
import 'client_detail_screen.dart';
import 'messages_screen.dart';
import 'plan_editor_screen.dart';
import 'video_call_placeholder_screen.dart';

/// Genel Bakış in direction B (Can, 25 Sep 2026, PLANNING #133). The drafts
/// card leads with the day's one big number: approving an AI draft is the
/// work only the dietitian can do, and a client waits on it. Everything else
/// sits under quiet uppercase labels, and each row keeps its one green action
/// at the right end. From [_twoColumnsFrom] the agenda takes a second column,
/// so a wide window carries content instead of gaps.
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

  /// Narrower than this the page is one column: a phone, a tablet, a small
  /// window.
  static const _twoColumnsFrom = 1000.0;
  static const _sideWidth = 396.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final groups = groupByClient(triageSignals(demo));
    final drafts = demo.plans.where((p) => p.isDraft).toList()
      ..sort((a, b) => a.draftedAt.compareTo(b.draftedAt));
    final agenda = demo.upcoming
        .where((a) => a.status != AppointmentStatus.cancelled)
        .toList();

    final triage = [
      SectionLabel(
        'Dikkat gerekenler',
        count: groups.isEmpty ? null : '${groups.length} danışan',
        actionLabel: 'Tüm danışanlar',
        onAction: onOpenClients,
      ),
      const SizedBox(height: AppSpacing.sm),
      _TriageCard(
        groups: groups,
        onOpenMessages: onOpenMessages,
        onOpenAppointments: onOpenAppointments,
      ),
      const SizedBox(height: AppSpacing.md),
      const _Footnote(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _twoColumnsFrom;
        final Widget content;
        if (wide) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DraftsCard(drafts: drafts),
                    const SizedBox(height: AppSpacing.x3),
                    ...triage,
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xxl),
              SizedBox(
                width: _sideWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AgendaCard(appointments: agenda),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _AllAppointmentsLink(
                        onPressed: onOpenAppointments,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DraftsCard(drafts: drafts),
              const SizedBox(height: AppSpacing.xxl),
              SectionLabel(
                'Bugün',
                actionLabel: 'Tüm randevular',
                onAction: onOpenAppointments,
              ),
              const SizedBox(height: AppSpacing.sm),
              _AgendaCard(appointments: agenda, todayOnly: true),
              const SizedBox(height: AppSpacing.xxl),
              ...triage,
            ],
          );
        }
        // Not a lazy ListView: the page is short, and every section has to
        // be built for "jump to" links and for tests at large text.
        return SingleChildScrollView(
          padding: readablePadding(
            constraints.maxWidth,
            context.density.pagePadding,
            maxWidth: kDashboardWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              const SizedBox(height: AppSpacing.xxl),
              content,
            ],
          ),
        );
      },
    );
  }
}

/// Inner padding of every card on this page, so the names in the drafts card
/// and the triage card share one left edge and their actions one right edge.
double _cardPadding(BuildContext context) =>
    context.density.isCompact ? AppSpacing.xl : AppSpacing.lg;

/// The date as a small label, then the greeting. It is no longer the biggest
/// text on the page: the drafts count is.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trUpper(formatTodayLabel(DateTime.now())),
          style: text.labelSmall?.copyWith(
            color: context.palette.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hoş geldiniz, Dyt. Deniz',
          style: isPanelPhone(context)
              ? text.headlineMedium
              : text.headlineLarge,
        ),
      ],
    );
  }
}

/// The page's focal card: how many AI drafts wait, oldest first. Violet once,
/// on the label (Can, 25 Sep 2026, over C30): the home screen names the
/// safeguard.
class _DraftsCard extends StatelessWidget {
  const _DraftsCard({required this.drafts});

  final List<DietPlan> drafts;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final wide = context.density.isCompact;
    final pad = _cardPadding(context);

    if (drafts.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Onay bekleyen plan yok', style: text.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Yapay zekâ yeni bir taslak hazırladığında onayınızı burada '
                'bekler.',
                style: text.bodyMedium?.copyWith(color: palette.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final count = drafts.length;
    final number = ExcludeSemantics(
      child: Text(
        '$count',
        style: AppTypography.figures(
          wide ? 48 : 56,
          wide ? 52 : 60,
        ).copyWith(color: AppColors.textPrimary, letterSpacing: -1),
      ),
    );
    final title = Semantics(
      header: true,
      child: Text(
        'plan onayınızı bekliyor',
        semanticsLabel: '$count plan onayınızı bekliyor',
        style: text.headlineSmall,
      ),
    );
    final caption = Text(
      'Danışanlar planı siz onaylayana kadar göremez.',
      style: (wide ? text.bodyLarge : text.bodyMedium)?.copyWith(
        color: palette.textSecondary,
      ),
    );
    const label = TonePill(label: 'Yapay zekâ taslağı', tone: PillTone.aiDraft);
    // Number, words and label on one line on a wide screen; stacked on a
    // phone, or when large text leaves the words too little room.
    final head = LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        if (wide && constraints.maxWidth >= 560 * scale) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              number,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 2), caption],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              label,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            const SizedBox(height: AppSpacing.md),
            number,
            title,
            const SizedBox(height: 2),
            caption,
          ],
        );
      },
    );
    final inset = pad + context.density.avatarSize + ActionRow.gap;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, AppSpacing.lg),
            child: head,
          ),
          for (final (i, plan) in drafts.indexed) ...[
            i == 0 ? const Divider() : Divider(indent: inset),
            _DraftRow(plan: plan),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

/// "İncele" opens the draft itself, the one screen this product turns on.
class _DraftRow extends ConsumerWidget {
  const _DraftRow({required this.plan});

  final DietPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(plan.clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final wide = context.density.isCompact;
    final age = DateTime.now().difference(plan.draftedAt);
    // Amber past two days: a guess, and the triage note says our thresholds
    // are guesses.
    final late = age.inHours >= kPlanWaitingWarningHours;
    final waiting = Text(
      '${formatWaitingSince(age)} bekliyor',
      style: text.bodyMedium?.copyWith(
        color: late ? palette.warning : palette.textMuted,
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _cardPadding(context),
        vertical: AppSpacing.md,
      ),
      child: ActionRow(
        lead: PersonAvatar(name: client.name),
        leadWidth: context.density.avatarSize,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.name, style: text.titleMedium),
            const SizedBox(height: 2),
            Text(
              '${plan.day} · ${plan.kcal} kcal',
              style: text.bodyMedium?.copyWith(color: palette.textMuted),
            ),
            if (!wide) waiting,
          ],
        ),
        meta: wide ? waiting : null,
        metaWidth: 170 * MediaQuery.textScalerOf(context).scale(1),
        actionLabel: 'İncele',
        actionSemantics: '${client.name}: planı incele',
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlanEditorScreen(clientId: plan.clientId),
          ),
        ),
      ),
    );
  }
}

/// One entry per client, their reasons under the name (Can, 25 Sep 2026: a
/// client appearing twice read as a bug).
class _TriageCard extends StatelessWidget {
  const _TriageCard({
    required this.groups,
    required this.onOpenMessages,
    required this.onOpenAppointments,
  });

  final List<TriageGroup> groups;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenAppointments;

  @override
  Widget build(BuildContext context) {
    final pad = _cardPadding(context);
    if (groups.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Text(
            'Şu an geride kalan danışan görünmüyor.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.palette.textMuted),
          ),
        ),
      );
    }
    final inset = pad + context.density.avatarSize + ActionRow.gap;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, group) in groups.indexed) ...[
              if (i > 0) Divider(indent: inset),
              _TriageGroupTile(
                group: group,
                onOpenMessages: onOpenMessages,
                onOpenAppointments: onOpenAppointments,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The name opens the client (the chevron says so); each reason's action does
/// the task it names, so answering a message never means finding the client
/// again in Mesajlar. On a phone the action labels are short, and a screen
/// reader hears the full task with the client's name.
class _TriageGroupTile extends ConsumerWidget {
  const _TriageGroupTile({
    required this.group,
    required this.onOpenMessages,
    required this.onOpenAppointments,
  });

  final TriageGroup group;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenAppointments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final pad = _cardPadding(context);
    final phone = isPanelPhone(context);
    final client = group.client;

    void openClient({bool atWeights = false}) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ClientDetailScreen(clientId: client.id, showWeights: atWeights),
      ),
    );

    final header = Semantics(
      button: true,
      label: '${client.name}, danışanı aç',
      excludeSemantics: true,
      child: InkWell(
        onTap: openClient,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: density.controlHeight + 4),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              children: [
                PersonAvatar(name: client.name),
                const SizedBox(width: ActionRow.gap),
                Expanded(child: Text(client.name, style: text.titleMedium)),
                Icon(
                  Icons.chevron_right,
                  size: phone ? 24 : 20,
                  color: palette.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget line(TriageSignal signal) {
      final (full, short, task) = switch (signal.kind) {
        TriageKind.unansweredMessage => (
          'Mesajı yanıtla',
          'Yanıtla',
          () {
            ref.read(selectedConversationProvider.notifier).select(client.id);
            // On a phone Mesajlar opens the thread itself as a page over this
            // screen, so back returns here; wide screens switch tabs.
            if (!phone) onOpenMessages();
          },
        ),
        TriageKind.noShow => (
          'Randevuları aç',
          'Randevular',
          onOpenAppointments,
        ),
        TriageKind.staleWeighIn => (
          'Ölçümleri incele',
          'Ölçümler',
          () => openClient(atWeights: true),
        ),
      };
      return Padding(
        padding: EdgeInsetsDirectional.only(
          start: pad + density.avatarSize + ActionRow.gap,
          end: pad,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: density.controlHeight),
          child: ActionRow(
            body: Text(
              signal.detail,
              style: text.bodyMedium?.copyWith(color: palette.warning),
            ),
            actionLabel: phone ? short : full,
            actionSemantics: '${client.name}: $full',
            onAction: task,
            minBodyWidth: 110,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, for (final signal in group.signals) line(signal)],
      ),
    );
  }
}

/// Upcoming appointments by day, time first (the agenda of #133). On a phone
/// only today's, with one line for the rest.
class _AgendaCard extends StatelessWidget {
  const _AgendaCard({required this.appointments, this.todayOnly = false});

  final List<Appointment> appointments;
  final bool todayOnly;

  /// The column shows the next few; Randevular has the rest.
  static const _maxRows = 6;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final pad = _cardPadding(context);
    final now = DateTime.now();
    bool isToday(Appointment a) => DateUtils.isSameDay(a.at, now);
    final muted = text.bodyMedium?.copyWith(color: palette.textMuted);

    Widget note(String s) => Padding(
      padding: EdgeInsets.all(pad),
      child: Text(s, style: muted),
    );

    final children = <Widget>[];
    if (todayOnly) {
      final today = appointments.where(isToday).toList();
      final later = appointments.where((a) => !isToday(a)).toList();
      if (today.isEmpty) {
        children.add(note('Bugün randevu yok.'));
      } else {
        children.addAll([for (final a in today) _AgendaRow(appointment: a)]);
      }
      if (later.isNotEmpty) {
        final next = later.first.at;
        children.addAll([
          Divider(indent: pad, endIndent: pad),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pad,
              vertical: AppSpacing.md,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${later.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' randevu daha · ilki ${formatDayInSentence(next)} '
                        '${formatTime(next)}',
                  ),
                ],
              ),
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
          ),
        ]);
      }
    } else if (appointments.isEmpty) {
      children.add(note('Yaklaşan randevu yok.'));
    } else {
      final days = <DateTime, List<Appointment>>{};
      for (final a in appointments.take(_maxRows)) {
        days.putIfAbsent(DateUtils.dateOnly(a.at), () => []).add(a);
      }
      for (final (i, day) in days.entries.indexed) {
        if (i > 0) children.add(Divider(indent: pad, endIndent: pad));
        children.add(
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              pad,
              i == 0 ? AppSpacing.lg + 2 : AppSpacing.md + 2,
              pad,
              AppSpacing.xs,
            ),
            child: Semantics(
              header: true,
              child: Text(
                trUpper(formatDayHeading(day.key)),
                style: text.labelSmall?.copyWith(
                  color: palette.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
        children.addAll([
          for (final a in day.value) _AgendaRow(appointment: a),
        ]);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// The time, who and how; "Görüşmeye başla" only for today's online
/// appointment, the one a dietitian can start from here.
class _AgendaRow extends ConsumerWidget {
  const _AgendaRow({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(appointment.clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final online = appointment.kind == AppointmentKind.online;
    final today = DateUtils.isSameDay(appointment.at, DateTime.now());
    final name = text.titleMedium!;
    final scale = MediaQuery.textScalerOf(context).scale(1);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _cardPadding(context),
        vertical: AppSpacing.sm + 2,
      ),
      child: ActionRow(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        lead: Text(
          formatTime(appointment.at),
          style: AppTypography.figures(
            name.fontSize!,
            name.height! * name.fontSize!,
          ).copyWith(color: AppColors.textPrimary),
        ),
        leadWidth: 48 * scale,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.name, style: name),
            Text(
              online ? 'Görüntülü görüşme' : 'Yüz yüze',
              style: text.bodyMedium?.copyWith(color: palette.textMuted),
            ),
            if (appointment.status == AppointmentStatus.reminderSent)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      'Hatırlatma gönderildi',
                      style: text.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        minBodyWidth: 120,
        actionLabel: online && today ? 'Görüşmeye başla' : null,
        actionSemantics: '${client.name}: görüşmeye başla',
        onAction: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoCallPlaceholderScreen(clientName: client.name),
          ),
        ),
      ),
    );
  }
}

class _AllAppointmentsLink extends StatelessWidget {
  const _AllAppointmentsLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return EdgeButton(
      end: true,
      child: TextButton.icon(
        style: AppTheme.quietButton,
        onPressed: onPressed,
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.chevron_right, size: 18),
        label: const Text('Tüm randevular'),
      ),
    );
  }
}

/// The interview question behind the triage thresholds (#110): the list is
/// our guess, and it says so.
class _Footnote extends StatelessWidget {
  const _Footnote();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Text(
          'Bu liste bizim tahminimiz: 7 gündür tartılmayan, 24 saattir yanıt '
          'bekleyen ve randevusuna gelmeyen danışanlar. Siz sabah ilk neye '
          'bakıyorsunuz, hangi eşikleri kullanıyorsunuz?',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.palette.textMuted),
        ),
      ),
    );
  }
}
