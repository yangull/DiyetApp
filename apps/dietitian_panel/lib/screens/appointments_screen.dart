import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../util/panel_date.dart';
import 'video_call_placeholder_screen.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final upcoming = demo.upcoming;
    final unpaid = demo.unpaid;
    final past = demo.appointments.where((a) => a.isPast).toList()
      ..sort((a, b) => b.at.compareTo(a.at));

    return ListView(
      padding: EdgeInsets.all(context.density.pagePadding),
      children: [
        Text('Randevular', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${upcoming.length} yaklaşan randevu · hatırlatmalar uygulama '
          'bildirimiyle gönderiliyor',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Yaklaşan', style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < upcoming.length; i++)
                _AppointmentRow(appointment: upcoming[i], showDivider: i > 0),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Yaklaşan randevu yok.',
                    style: text.bodyMedium?.copyWith(color: palette.textMuted),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Geçmiş randevular', style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < past.length; i++)
                _PastRow(appointment: past[i], showDivider: i > 0),
              if (past.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Geçmiş randevu yok.',
                    style: text.bodyMedium?.copyWith(color: palette.textMuted),
                  ),
                ),
            ],
          ),
        ),
        if (kShowMoney) ...[
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Text('Tahsil edilmemiş', style: text.titleLarge),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${demo.unpaidCount} seans · ${demo.unpaidTotal} ₺',
                style: text.bodyMedium?.copyWith(
                  color: palette.warning,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < unpaid.length; i++)
                  _UnpaidRow(appointment: unpaid[i], showDivider: i > 0),
                if (unpaid.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'Tahsil edilmemiş seans yok.',
                      style: text.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Gelmeyen bir danışanın seansını tahsil edilecekler arasına '
            'koymuyoruz — bu bizim varsayımımız. Siz gelmediğinde ücret alıyor '
            'musunuz, iptal için bir süre sınırınız var mı?',
            style: text.bodySmall?.copyWith(color: palette.textMuted),
          ),
        ],
      ],
    );
  }
}

String _when(DateTime at) {
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return '${formatDayMonth(at)} ${trWeekdays[at.weekday - 1]} · $hh:$mm';
}

class _AppointmentRow extends ConsumerWidget {
  const _AppointmentRow({required this.appointment, required this.showDivider});

  final Appointment appointment;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(appointment.clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final cancelled = appointment.status == AppointmentStatus.cancelled;
    final reminded = appointment.status == AppointmentStatus.reminderSent;

    final kindIcon = Icon(
      appointment.kind == AppointmentKind.online
          ? Icons.videocam_outlined
          : Icons.person_outline,
      size: 20,
      color: palette.textMuted,
    );
    final kindLabel = Text(
      appointment.kind == AppointmentKind.online
          ? 'Görüntülü görüşme'
          : 'Yüz yüze',
      style: text.bodyMedium?.copyWith(color: palette.textSecondary),
    );
    final who = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          client.name,
          style: text.titleMedium?.copyWith(
            decoration: cancelled ? TextDecoration.lineThrough : null,
            color: cancelled ? palette.textMuted : null,
          ),
        ),
        Text(
          _when(appointment.at),
          style: text.bodySmall?.copyWith(color: palette.textMuted),
        ),
      ],
    );
    final actions = <Widget>[
      if (!cancelled && appointment.kind == AppointmentKind.online)
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    VideoCallPlaceholderScreen(clientName: client.name),
              ),
            ),
            icon: const Icon(Icons.videocam_outlined, size: 18),
            label: const Text('Görüşmeye başla'),
          ),
        ),
      if (cancelled)
        Text(
          'İptal edildi',
          style: text.bodyMedium?.copyWith(color: palette.textMuted),
        )
      else if (reminded)
        // A done state, told like "Onaylı": a black tick, grey words.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 16, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Hatırlatma gönderildi',
                style: text.bodyMedium?.copyWith(color: palette.textSecondary),
              ),
            ),
          ],
        )
      else
        // One green action per row, "Görüşmeye başla" (Can, C29).
        TextButton.icon(
          style: AppTheme.quietButton,
          onPressed: () {
            ref.read(demoProvider.notifier).sendReminder(appointment.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${client.name} için hatırlatma gönderildi.'),
              ),
            );
          },
          icon: const Icon(Icons.notifications_none, size: 18),
          label: const Text('Hatırlatma gönder'),
        ),
      if (!cancelled)
        TextButton(
          style: AppTheme.quietButton,
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Randevuyu iptal et'),
                content: Text('${client.name} ile randevu iptal edilecek.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Vazgeç'),
                  ),
                  FilledButton(
                    style: AppTheme.destructiveButton,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('İptal et'),
                  ),
                ],
              ),
            );
            if (confirmed ?? false) {
              ref.read(demoProvider.notifier).cancelAppointment(appointment.id);
            }
          },
          child: const Text('İptal et'),
        ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: palette.borderSubtle))
            : null,
      ),
      // Below ~720 px the actions go under the name instead of beside it;
      // in one line they overflowed any window narrower than about 900 px.
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kindIcon,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [who, kindLabel],
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
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: actions,
                  ),
                ),
              ],
            );
          }
          // The actions get a fixed share of the row, so "Görüntülü görüşme"
          // and "Yüz yüze" start at the same place in every row whatever the
          // actions' width.
          return Row(
            children: [
              kindIcon,
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 3, child: who),
              Expanded(flex: 2, child: kindLabel),
              Expanded(
                flex: 4,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: AppSpacing.xs,
                  children: actions,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A no-show and a cancellation are shown as different words here because the
/// panel now stores them as different states — and because "gelmedi" is the
/// one a dietitian has to record themselves after the fact.
class _PastRow extends ConsumerWidget {
  const _PastRow({required this.appointment, required this.showDivider});

  final Appointment appointment;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(appointment.clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final noShow = appointment.status == AppointmentStatus.noShow;
    final cancelled = appointment.status == AppointmentStatus.cancelled;
    final who = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(client.name, style: text.titleMedium),
        Text(
          _when(appointment.at),
          style: text.bodySmall?.copyWith(color: palette.textMuted),
        ),
      ],
    );
    final status = Text(
      switch (appointment.status) {
        AppointmentStatus.noShow => 'Gelmedi',
        AppointmentStatus.cancelled => 'İptal edildi',
        _ => 'Görüşme yapıldı',
      },
      style: text.bodyMedium?.copyWith(
        color: noShow ? palette.warning : palette.textSecondary,
      ),
    );
    // Quiet: a record kept after the fact, not the row's next step.
    final markNoShow = noShow || cancelled
        ? null
        : TextButton.icon(
            style: AppTheme.quietButton,
            onPressed: () =>
                ref.read(demoProvider.notifier).markNoShow(appointment.id),
            icon: const Icon(Icons.event_busy_outlined, size: 18),
            label: const Text('Gelmedi olarak işaretle'),
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: palette.borderSubtle))
            : null,
      ),
      // Like the upcoming rows: below 720 px the status and the action go
      // under the name. Beside it, the action took the whole width and the
      // status broke mid-word ("Görüşm / e / yapıldı").
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            // Full width even with no action, or the row shrinks to its text.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                who,
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [status, ?markNoShow],
                ),
              ],
            );
          }
          // A fixed share for the action as well, present or not, so the
          // status column lines up across rows.
          return Row(
            children: [
              Expanded(flex: 3, child: who),
              Expanded(flex: 2, child: status),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: markNoShow,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UnpaidRow extends ConsumerWidget {
  const _UnpaidRow({required this.appointment, required this.showDivider});

  final Appointment appointment;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(appointment.clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: palette.borderSubtle))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: text.titleMedium),
                Text(
                  _when(appointment.at),
                  style: text.bodySmall?.copyWith(color: palette.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${appointment.fee} ₺',
              style: text.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${client.name} için ödeme hatırlatması '
                    'gönderildi.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.campaign_outlined, size: 18),
            label: const Text('Ödeme hatırlat'),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () =>
                ref.read(demoProvider.notifier).markPaid(appointment.id),
            child: const Text('Tahsil edildi'),
          ),
        ],
      ),
    );
  }
}
