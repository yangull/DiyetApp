import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../util/panel_date.dart';
import '../widgets/tone_pill.dart';
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
    final past =
        demo.appointments.where((a) => a.isPast && !a.isOnAgenda).toList()
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
        CloudCard(
          child: Column(
            children: [
              if (upcoming.isNotEmpty) const _AppointmentHeader(),
              for (var i = 0; i < upcoming.length; i++)
                _AppointmentRow(appointment: upcoming[i], showDivider: i > 0),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Yaklaşan randevu yok.',
                    style: text.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Geçmiş randevular', style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        CloudCard(
          child: Column(
            children: [
              if (past.isNotEmpty) const _AppointmentHeader(whatLabel: 'Durum'),
              for (var i = 0; i < past.length; i++)
                _PastRow(appointment: past[i], showDivider: i > 0),
              if (past.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Geçmiş randevu yok.',
                    style: text.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
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
                style: text.bodyMedium?.copyWith(color: palette.warning),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CloudCard(
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
                        color: palette.textSecondary,
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
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ],
    );
  }
}

String _when(DateTime at) =>
    '${trWeekdays[at.weekday - 1]}, ${formatDate(at)} · ${formatTime(at)}';

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

    final kind = _KindLabel(appointment.kind);
    final who = _Who(name: client.name, at: appointment.at, struck: cancelled);
    final start = cancelled || appointment.kind != AppointmentKind.online
        ? null
        : OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    VideoCallPlaceholderScreen(clientName: client.name),
              ),
            ),
            icon: const Icon(AppIcons.video, size: 18),
            label: const Text('Görüşmeye başla'),
          );
    final reminder = cancelled
        ? const TonePill(label: 'İptal edildi', tone: PillTone.neutral)
        : reminded
        // A done state, told like "Onaylı": a black tick, grey words.
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon and gap as the reminder button's, so both read from one
              // left edge.
              Icon(AppIcons.check, size: 18, color: context.palette.ink),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Hatırlatma gönderildi',
                  style: text.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          )
        // One green action per row, "Görüşmeye başla" (Can, C29).
        : TextButton.icon(
            // Fixed padding: the theme's scales with the text, and a sent
            // reminder in the same slot has to start at the same place.
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            onPressed: () {
              ref.read(demoProvider.notifier).sendReminder(appointment.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${client.name} için hatırlatma gönderildi.'),
                ),
              );
            },
            icon: const Icon(AppIcons.notifications, size: 18),
            label: const Text('Hatırlatma gönder'),
          );
    final cancel = cancelled
        ? null
        : TextButton(
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
                      style: AppTheme.destructive(context),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('İptal et'),
                    ),
                  ],
                ),
              );
              if (confirmed ?? false) {
                ref
                    .read(demoProvider.notifier)
                    .cancelAppointment(appointment.id);
              }
            },
            child: const Text('İptal et'),
          );

    return _AppointmentGrid(
      showDivider: showDivider,
      at: appointment.at,
      who: who,
      what: kind,
      first: start,
      second: reminder,
      // A sent reminder and an "İptal edildi" pill are plain states, not
      // buttons: in the grid they take a button's inset to line up with one.
      secondIsState: cancelled || reminded,
      third: cancel,
    );
  }
}

/// One grid for every appointment row, upcoming and past (Can, 24 Sep 2026):
/// the time first, then who, what kind or what happened, then three action
/// slots. Each slot starts at the same place in every row of both cards, so
/// "Görüşmeye başla" does not move with the width of the text beside it.
/// Below [_gridBreakpoint] the row stacks: the actions go under the name, all
/// on the text's left edge.
class _AppointmentGrid extends StatelessWidget {
  const _AppointmentGrid({
    required this.showDivider,
    required this.at,
    required this.who,
    required this.what,
    this.first,
    this.second,
    this.secondIsState = false,
    this.third,
  });

  final bool showDivider;
  final DateTime at;
  final Widget who;
  final Widget what;
  final Widget? first;
  final Widget? second;

  /// [second] is a state, not a button: in the grid it gets a button's inset.
  final bool secondIsState;
  final Widget? third;

  /// Three action slots need about this much room; below it they would
  /// squeeze their buttons.
  static const _gridBreakpoint = 1000.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // The time is the key fact of the row, so it is the biggest thing in it:
    // figures style, in a slot sized to "00:00" so the colons line up.
    final timeStyle = AppTypography.figures(
      text.titleLarge!.fontSize!,
      text.titleLarge!.height! * text.titleLarge!.fontSize!,
    ).copyWith(color: context.palette.ink);
    final time = SizedBox(
      width: numberSlotWidth(context, '00:00', timeStyle),
      child: Text(formatTime(at), textAlign: TextAlign.end, style: timeStyle),
    );

    Widget slot(Widget? child, {bool inset = false}) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: child == null
          ? null
          : Padding(
              padding: EdgeInsetsDirectional.only(start: inset ? 12 : 0),
              child: child,
            ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: context.palette.divider))
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _gridBreakpoint) {
            // Full width even with no action, or the row shrinks to its text.
            // At large text the time column would leave the name too little
            // room, so the time goes above it.
            final stackTime = MediaQuery.textScalerOf(context).scale(1) > 1.3;
            final body = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (stackTime) Text(formatTime(at), style: timeStyle),
                who,
                const SizedBox(height: 2),
                what,
              ],
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stackTime)
                  body
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      time,
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: body),
                    ],
                  ),
                if (first != null || second != null || third != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    // Under the name, not under the time.
                    padding: EdgeInsetsDirectional.only(
                      start: stackTime
                          ? 0
                          : _timeWidth(context) + AppSpacing.md,
                    ),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ?first,
                        // A text button's own inset is cancelled only when it
                        // starts the line (EdgeButton shifts by 12): later ones
                        // sit after a neighbour and keep it.
                        ?(second == null
                            ? null
                            : secondIsState
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                                child: second,
                              )
                            : first == null
                            ? EdgeButton(child: second!)
                            : second),
                        ?third,
                      ],
                    ),
                  ),
                ],
              ],
            );
          }
          return Row(
            children: [
              time,
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 3, child: who),
              Expanded(
                key: const ValueKey('appointments-what-column'),
                flex: 2,
                child: what,
              ),
              Expanded(flex: 3, child: slot(first)),
              Expanded(flex: 3, child: slot(second, inset: secondIsState)),
              Expanded(flex: 2, child: slot(third)),
            ],
          );
        },
      ),
    );
  }

  static double _timeWidth(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final style = AppTypography.figures(
      text.titleLarge!.fontSize!,
      text.titleLarge!.height! * text.titleLarge!.fontSize!,
    );
    return numberSlotWidth(context, '00:00', style);
  }
}

/// Column names above the rows on a wide screen; nothing on a phone, where
/// the rows stack.
class _AppointmentHeader extends StatelessWidget {
  const _AppointmentHeader({this.whatLabel = 'Görüşme'});

  /// The second column: the kind of an upcoming appointment, the outcome of a
  /// past one.
  final String whatLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        // The rows measure inside their own padding: the same width here, or
        // a header would sit over rows that have stacked.
        if (constraints.maxWidth - 2 * AppSpacing.lg <
            _AppointmentGrid._gridBreakpoint) {
          return const SizedBox.shrink();
        }
        final style = text.bodySmall?.copyWith(color: palette.textSecondary);
        final timeStyle = AppTypography.figures(
          text.titleLarge!.fontSize!,
          text.titleLarge!.height! * text.titleLarge!.fontSize!,
        );
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.divider)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: numberSlotWidth(context, '00:00', timeStyle),
                child: Text('Saat', textAlign: TextAlign.end, style: style),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 3, child: Text('Danışan', style: style)),
              Expanded(flex: 2, child: Text(whatLabel, style: style)),
              Expanded(flex: 8, child: Text('İşlemler', style: style)),
            ],
          ),
        );
      },
    );
  }
}

/// Name, with the day under it: "28 Eyl Pazartesi". The time has its own
/// column, so the day is all this carries.
class _Who extends StatelessWidget {
  const _Who({required this.name, required this.at, this.struck = false});

  final String name;
  final DateTime at;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: text.titleMedium?.copyWith(
            decoration: struck ? TextDecoration.lineThrough : null,
            color: struck ? palette.textSecondary : null,
          ),
        ),
        Text(
          '${trWeekdays[at.weekday - 1]}, ${formatDate(at)}',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }
}

/// The kind of appointment, the icon beside its words.
class _KindLabel extends StatelessWidget {
  const _KindLabel(this.kind);

  final AppointmentKind kind;

  @override
  Widget build(BuildContext context) {
    final online = kind == AppointmentKind.online;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          online ? AppIcons.video : AppIcons.inPerson,
          size: 18,
          color: context.palette.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            online ? 'Görüntülü görüşme' : 'Yüz yüze',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
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
    final client = ref.watch(demoProvider).clientOf(appointment.clientId);
    final noShow = appointment.status == AppointmentStatus.noShow;
    final cancelled = appointment.status == AppointmentStatus.cancelled;
    final who = _Who(name: client.name, at: appointment.at);
    final status = switch (appointment.status) {
      AppointmentStatus.noShow => const TonePill(
        label: 'Gelmedi',
        tone: PillTone.warning,
      ),
      AppointmentStatus.cancelled => const TonePill(
        label: 'İptal edildi',
        tone: PillTone.neutral,
      ),
      // Neutral, not green: green means an approved plan, and a held
      // appointment is not an approval.
      _ => const TonePill(label: 'Görüşme yapıldı', tone: PillTone.neutral),
    };
    // Quiet: a record kept after the fact, not the row's next step.
    final markNoShow = noShow || cancelled
        ? null
        : TextButton.icon(
            // The pill's inset, so this icon lines up with the camera icon of
            // "Görüşmeye başla" in the same column.
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              ),
            ),
            onPressed: () =>
                ref.read(demoProvider.notifier).markNoShow(appointment.id),
            icon: const Icon(AppIcons.appointmentMissed, size: 18),
            label: const Text('Gelmedi olarak işaretle'),
          );

    return _AppointmentGrid(
      showDivider: showDivider,
      at: appointment.at,
      who: who,
      what: Align(alignment: AlignmentDirectional.centerStart, child: status),
      first: markNoShow,
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
            ? Border(top: BorderSide(color: palette.divider))
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
                  style: text.bodySmall?.copyWith(color: palette.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text('${appointment.fee} ₺', style: text.titleMedium),
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
            icon: const Icon(AppIcons.announcement, size: 18),
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
