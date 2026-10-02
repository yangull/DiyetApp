import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_widgets.dart';
import 'goals_edit_screen.dart';

/// Bugün, the client's first tab (PLANNING #135): Ink type on the white
/// canvas, Cloud Card cards, black actions, and green only for progress.
/// Until plans exist it shows only what is real:
/// the goal, a pending invite, the connected dietitian, and one small
/// "Yakında" card (rules 4 and 5). The steps come from saved data.
class TodayTab extends ConsumerWidget {
  const TodayTab({super.key, required this.identity});

  final AuthedIdentity identity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final profile = identity.profile;
    final detail =
        ref.watch(clientDetailProvider(profile.id)).asData?.value ??
        identity.clientDetail;
    // Nothing is shown while these load or if they fail: each is an addition
    // to the screen, not something it depends on.
    final invites =
        ref.watch(pendingInvitesProvider).asData?.value ??
        const <ClientRelationship>[];
    final dietitians =
        ref.watch(myActiveRelationshipsProvider).asData?.value ??
        const <ClientRelationship>[];

    final goal = detail?.goal?.trim() ?? '';
    final hasGoal = goal.isNotEmpty;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        density.pagePadding,
        AppSpacing.xxl,
        density.pagePadding,
        density.pagePadding,
      ),
      children: [
        Text(
          formatTodayLabel(DateTime.now()),
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          'Merhaba, ${_firstName(profile.fullName)}',
          style: text.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        // An invite waits on the client, so it comes before the checklist.
        for (final invite in invites) ...[
          _InviteCard(invite: invite),
          const SizedBox(height: AppSpacing.md),
        ],
        _StartCard(
          goal: hasGoal ? goal : null,
          dietitianId: dietitians.isEmpty ? null : dietitians.first.dietitianId,
          hasInvite: invites.isNotEmpty,
          onEditGoals: () =>
              GoalsEditScreen.open(context, userId: profile.id, detail: detail),
        ),
        const SizedBox(height: AppSpacing.md),
        const _ComingSoon(),
      ],
    );
  }
}

String _firstName(String fullName) =>
    fullName.trim().isEmpty ? 'Danışan' : fullName.trim().split(' ').first;

/// Three real steps in order (rule 11): goals, a dietitian, the first plan.
/// The count and bar are the screen's one number; the first plan cannot be
/// delivered yet, so its row says so.
class _StartCard extends StatelessWidget {
  const _StartCard({
    required this.goal,
    required this.dietitianId,
    required this.hasInvite,
    required this.onEditGoals,
  });

  final String? goal;
  final String? dietitianId;
  final bool hasInvite;
  final VoidCallback onEditGoals;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final done = [goal != null, dietitianId != null, false];
    final count = done.where((d) => d).length;
    final current = done.indexOf(false);

    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: 'Başlangıç: 3 adımdan $count tamamlandı',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text('Başlangıç', style: text.titleMedium),
                      ),
                      Text('$count', style: AppTypography.figures(22, 28)),
                      Text(
                        ' / 3',
                        style: AppTypography.figures(
                          15,
                          20,
                        ).copyWith(color: palette.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProgressBar(value: count / 3),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _StepRow(
              done: done[0],
              current: current == 0,
              title: 'Hedeflerin',
              subtitle: goal ?? 'Diyetisyenin buradan başlar.',
              // The pill is for the first step; once written, or while an
              // invite is the main action, it is a quiet text action, as on
              // Profil.
              action: (stacked) => goal == null && !hasInvite
                  ? Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: stacked ? AppSpacing.sm : 0,
                        ),
                        child: _TintButton(
                          label: 'Yaz',
                          onPressed: onEditGoals,
                        ),
                      ),
                    )
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: EdgeButton(
                        end: !stacked,
                        child: TextButton(
                          onPressed: onEditGoals,
                          child: Text(goal == null ? 'Yaz' : 'Düzenle'),
                        ),
                      ),
                    ),
            ),
            _StepRow(
              done: done[1],
              current: current == 1,
              title: 'Diyetisyenin',
              subtitleWidget: dietitianId == null
                  ? null
                  : _DietitianName(dietitianId: dietitianId!),
              subtitle: hasInvite
                  ? 'Bir davetin var, yukarıda.'
                  : 'Bir diyetisyen seni davet ettiğinde burada görünür.',
              trailing: dietitianId == null
                  ? null
                  : _DietitianAvatar(dietitianId: dietitianId!),
            ),
            _StepRow(
              done: done[2],
              current: current == 2,
              title: 'İlk planın',
              subtitle: 'Diyetisyenin onayladığında burada görünür.',
            ),
          ],
        ),
      ),
    );
  }
}

/// A thick, rounded bar: grey track, green fill. It moves only when the value
/// changes, never because the screen opened (design rule 12).
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: TweenAnimationBuilder<double>(
          // No begin: the first build shows the value as it is.
          tween: Tween<double>(end: value),
          duration: AppMotion.of(context, AppMotion.change),
          curve: AppMotion.curve,
          builder: (context, v, _) => LinearProgressIndicator(
            value: v,
            backgroundColor: palette.track,
            color: palette.accent,
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.done,
    required this.current,
    required this.title,
    required this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.action,
  });

  final bool done;

  /// The first step not done yet: its ring is drawn in Ink.
  final bool current;
  final String title;
  final String subtitle;
  final Widget? subtitleWidget;

  /// A small, fixed-size element at the row's end (an avatar).
  final Widget? trailing;

  /// A button, built for the row's end or, at large text, under the text so
  /// it does not squeeze it.
  final Widget Function(bool stacked)? action;

  static const _ring = 26.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final scaler = MediaQuery.textScalerOf(context);
    final stacked = action != null && scaler.scale(10) > 13;
    final titleStyle = text.titleMedium;
    // The ring is centred on the title's first line, not on the whole row.
    final firstLine =
        scaler.scale(titleStyle?.fontSize ?? 16) * (titleStyle?.height ?? 1.3);
    final ringBox = firstLine > _ring ? firstLine : _ring;
    final textTop = (ringBox - firstLine) / 2;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Black when done, an empty ring when not: colour is not the
              // signal, the tick is (rule 10).
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: ringBox,
                  child: Center(
                    child: Container(
                      width: _ring,
                      height: _ring,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? palette.ink : null,
                        border: done
                            ? null
                            : Border.all(
                                color: current
                                    ? palette.ink
                                    : palette.borderStrong,
                                width: current ? 2 : 1.5,
                              ),
                      ),
                      child: done
                          ? Icon(
                              AppIcons.check,
                              size: 16,
                              color: palette.onFilled,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: textTop),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: titleStyle),
                      subtitleWidget ??
                          Text(
                            subtitle,
                            style: text.bodyMedium?.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                      if (stacked) action!(true),
                    ],
                  ),
                ),
              ),
              if (action != null && !stacked) ...[
                const SizedBox(width: AppSpacing.sm),
                Align(alignment: Alignment.center, child: action!(false)),
              ],
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Align(alignment: Alignment.center, child: trailing!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DietitianName extends ConsumerWidget {
  const _DietitianName({required this.dietitianId});

  final String dietitianId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref
        .watch(dietitianProfileProvider(dietitianId))
        .asData
        ?.value
        .fullName;
    return Text(
      name ?? '',
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: context.palette.textSecondary),
    );
  }
}

class _DietitianAvatar extends ConsumerWidget {
  const _DietitianAvatar({required this.dietitianId});

  final String dietitianId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref
        .watch(dietitianProfileProvider(dietitianId))
        .asData
        ?.value
        .fullName;
    return PersonAvatar(
      name: name,
      size: 36,
      background: context.palette.inset,
    );
  }
}

/// The theme's secondary pill (pale, see AppTheme), drawn 40 tall to sit
/// inside a row. Its tap target is still at least 48 tall.
class _TintButton extends StatelessWidget {
  const _TintButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 40),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _InviteCard extends ConsumerWidget {
  const _InviteCard({required this.invite});

  final ClientRelationship invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    // Never the invited email: that is the client's own address, and this
    // card asks them to grant a stranger access to their health data. Who is
    // asking has to be on the card (PLANNING #105).
    final name = ref
        .watch(dietitianProfileProvider(invite.dietitianId))
        .asData
        ?.value
        .fullName;

    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PersonAvatar(name: name, size: context.density.avatarSize + 4),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name == null
                            ? 'Bir diyetisyen seni davet etti'
                            : '$name seni davet etti',
                        style: text.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kabul edersen hedeflerini ve sağlık notlarını '
                        'görebilir.',
                        style: text.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _respond(context, ref, accept: true),
                    child: const Text('Kabul et'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respond(context, ref, accept: false),
                    child: const Text('Reddet'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref, {
    required bool accept,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(clientRelationshipRepositoryProvider);
    try {
      if (accept) {
        await repo.acceptInvite(invite.id);
      } else {
        await repo.declineInvite(invite.id);
      }
      ref.invalidate(pendingInvitesProvider);
      ref.invalidate(myActiveRelationshipsProvider);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('İşlem tamamlanamadı. Tekrar dene.')),
      );
    }
  }
}

/// Unbuilt paths, named once in one quiet card and never drawn as buttons
/// (rule 4).
class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final body = text.bodyMedium?.copyWith(color: palette.textSecondary);
    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text('Yakında', style: text.titleMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Diyetisyen bul: sana uygun diyetisyeni kendin seç.',
              style: body,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Yapay zekâ ile ilerle: diyetisyensiz beslenme planı.',
              style: body,
            ),
          ],
        ),
      ),
    );
  }
}
