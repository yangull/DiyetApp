import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_widgets.dart';
import 'goals_edit_screen.dart';

/// Bugün, the client's first tab ("Sade", PLANNING #133): black type on a
/// light-grey ground, white cards, and the brand green only where the client
/// can act or sees progress. Until plans exist it shows only what is real:
/// the goal, a pending invite, the connected dietitian, and one quiet
/// "Yakında" note (rules 4 and 5). The steps come from saved data.
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
          style: text.bodyMedium?.copyWith(color: palette.textMuted),
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
        const SizedBox(height: AppSpacing.x3),
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

    return Card(
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
                        ).copyWith(color: palette.textMuted),
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
              title: 'Hedeflerin',
              subtitle: goal ?? 'Diyetisyenin buradan başlar.',
              trailing: _TintButton(
                label: goal == null ? 'Yaz' : 'Düzenle',
                onPressed: onEditGoals,
              ),
            ),
            _StepRow(
              done: done[1],
              title: 'Diyetisyenin',
              subtitleWidget: dietitianId == null
                  ? null
                  : _DietitianName(dietitianId: dietitianId!),
              subtitle: hasInvite
                  ? 'Bir davetin var, yukarıda.'
                  : 'Bir diyetisyen seni davet ettiğinde burada görünür.',
            ),
            _StepRow(
              done: done[2],
              title: 'İlk planın',
              subtitle: 'Diyetisyenin onayladığında burada görünür.',
              trailing: Text(
                'Yakında',
                style: text.bodySmall?.copyWith(color: palette.textMuted),
              ),
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
            backgroundColor: palette.surfaceSubtle,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.done,
    required this.title,
    required this.subtitle,
    this.subtitleWidget,
    this.trailing,
  });

  final bool done;
  final String title;
  final String subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Black when done, an empty ring when not: colour is not the
            // signal, the tick is (rule 10).
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.textPrimary : null,
                border: done
                    ? null
                    : Border.all(color: palette.borderStrong, width: 1.5),
              ),
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: text.titleMedium),
                  subtitleWidget ??
                      Text(
                        subtitle,
                        style: text.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
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

/// The theme's secondary pill (pale green, see AppTheme), drawn 40 tall to sit
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PersonAvatar(name: name),
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
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.surfaceSubtle,
                      foregroundColor: AppColors.textPrimary,
                    ),
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

/// Unbuilt paths, named once and never drawn as buttons (rule 4).
class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final body = text.bodyMedium?.copyWith(color: palette.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YAKINDA',
          style: text.labelSmall?.copyWith(color: palette.textMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Diyetisyen bul: sana uygun diyetisyeni kendin seç.', style: body),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Yapay zekâ ile ilerle: diyetisyensiz beslenme planı.',
          style: body,
        ),
      ],
    );
  }
}
