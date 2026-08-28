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
    final unpaid = demo.appointments.where((a) => a.isPast && !a.paid).toList();

    return ListView(
      padding: EdgeInsets.all(context.density.pagePadding),
      children: [
        Text('Randevular', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${upcoming.length} yaklaşan randevu · hatırlatmalar '
          '${demo.reminders.channel == 'sms' ? 'SMS' : 'uygulama bildirimi'} '
          'ile gönderiliyor',
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
                    style: text.bodyMedium?.copyWith(color: palette.textMuted),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Bu ekran görüşme için hazırlanmıştır. Randevu ve ödeme takibinin '
          'işinize ne kadar yaradığını sizden öğrenmek istiyoruz.',
          style: text.bodySmall?.copyWith(color: palette.textMuted),
        ),
      ],
    );
  }
}

String _when(DateTime at) {
  const days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  final hh = at.hour.toString().padLeft(2, '0');
  final mm = at.minute.toString().padLeft(2, '0');
  return '${formatDayMonth(at)} ${days[at.weekday - 1]} · $hh:$mm';
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
          Icon(
            appointment.kind == AppointmentKind.online
                ? Icons.videocam_outlined
                : Icons.person_outline,
            size: 20,
            color: palette.textMuted,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Column(
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
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              appointment.kind == AppointmentKind.online
                  ? 'Görüntülü görüşme'
                  : 'Yüz yüze',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
          ),
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
            Row(
              children: [
                Icon(Icons.check, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Hatırlatma gönderildi',
                  style: text.bodyMedium?.copyWith(color: AppColors.primary),
                ),
              ],
            )
          else
            TextButton.icon(
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
            IconButton(
              tooltip: 'Randevuyu iptal et',
              onPressed: () => ref
                  .read(demoProvider.notifier)
                  .cancelAppointment(appointment.id),
              icon: Icon(Icons.close, size: 18, color: palette.textMuted),
            ),
        ],
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
