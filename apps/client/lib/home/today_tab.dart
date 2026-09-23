import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_widgets.dart';
import 'goals_edit_screen.dart';

/// Bugün, the client's first tab ("Sıcak", PLANNING #131). Until plans exist
/// it shows only what is real: the goal, a pending invite, the connected
/// dietitian, and one quiet "Yakında" note (rules 4 and 5). The hero's three
/// steps are derived from saved data, never from a flag.
class TodayTab extends ConsumerWidget {
  const TodayTab({super.key, required this.identity});

  final AuthedIdentity identity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final hasDietitian = dietitians.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ListView(
        padding: EdgeInsets.only(bottom: density.pagePadding),
        children: [
          _Hero(
            firstName: _firstName(profile.fullName),
            hasGoal: hasGoal,
            hasDietitian: hasDietitian,
            hasInvite: invites.isNotEmpty,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              density.pagePadding,
              AppSpacing.xl,
              density.pagePadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final invite in invites) ...[
                  _InviteCard(invite: invite),
                  const SizedBox(height: AppSpacing.md),
                ],
                _GoalRow(
                  goal: hasGoal ? goal : null,
                  onTap: () => GoalsEditScreen.open(
                    context,
                    userId: profile.id,
                    detail: detail,
                  ),
                ),
                for (final relationship in dietitians) ...[
                  const SizedBox(height: AppSpacing.md),
                  DietitianRow(dietitianId: relationship.dietitianId),
                ],
                const SizedBox(height: AppSpacing.x3),
                const _ComingSoon(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _firstName(String fullName) =>
    fullName.trim().isEmpty ? 'Danışan' : fullName.trim().split(' ').first;

const _days = [
  'PAZARTESİ',
  'SALI',
  'ÇARŞAMBA',
  'PERŞEMBE',
  'CUMA',
  'CUMARTESİ',
  'PAZAR',
];
const _months = [
  'OCAK',
  'ŞUBAT',
  'MART',
  'NİSAN',
  'MAYIS',
  'HAZİRAN',
  'TEMMUZ',
  'AĞUSTOS',
  'EYLÜL',
  'EKİM',
  'KASIM',
  'ARALIK',
];

String _todayLabel(DateTime d) =>
    '${_days[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

class _Hero extends StatelessWidget {
  const _Hero({
    required this.firstName,
    required this.hasGoal,
    required this.hasDietitian,
    required this.hasInvite,
  });

  final String firstName;
  final bool hasGoal;
  final bool hasDietitian;
  final bool hasInvite;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final top = MediaQuery.paddingOf(context).top;

    final String nextStep;
    if (!hasGoal) {
      nextStep = 'Önce hedeflerini yaz; diyetisyenin buradan başlar.';
    } else if (!hasDietitian && hasInvite) {
      nextStep = 'Bir davetin var. Aşağıdan yanıtlayabilirsin.';
    } else if (!hasDietitian) {
      nextStep = 'Sıradaki adım: bir diyetisyene bağlanmak.';
    } else {
      nextStep =
          'Diyetisyenine bağlısın. Planın hazır olunca burada görünecek.';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        density.pagePadding,
        top + AppSpacing.xxl,
        density.pagePadding,
        AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: palette.hero,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(density.heroRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _todayLabel(DateTime.now()),
            style: text.labelSmall?.copyWith(color: palette.onHeroSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Merhaba, $firstName',
            style: text.headlineLarge?.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            nextStep,
            style: text.bodyLarge?.copyWith(color: palette.onHeroSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Steps(done: [hasGoal, hasDietitian, false]),
        ],
      ),
    );
  }
}

/// Three real steps, in order (rule 11): goals, a dietitian, the first plan.
/// The first plan cannot be delivered yet, so its step says so.
class _Steps extends StatelessWidget {
  const _Steps({required this.done});

  final List<bool> done;

  static const _labels = ['Hedefler', 'Diyetisyen', 'İlk plan · yakında'];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final current = done.indexWhere((d) => !d);
    final count = done.where((d) => d).length;

    Widget dot(int i) {
      if (done[i]) {
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: palette.highlight,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 18, color: palette.onHighlight),
        );
      }
      final isCurrent = i == current && i < 2;
      final color = isCurrent ? AppColors.onPrimary : palette.onHeroSecondary;
      return Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          '${i + 1}',
          style: AppTypography.figures(14, 18).copyWith(color: color),
        ),
      );
    }

    Widget line(int i) => Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: done[i] ? palette.highlight : palette.heroTrack,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

    return Semantics(
      label: 'Başlangıç: 3 adımdan $count tamamlandı',
      excludeSemantics: true,
      child: Column(
        children: [
          Row(children: [dot(0), line(0), dot(1), line(1), dot(2)]),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: Text(
                    _labels[i],
                    textAlign: switch (i) {
                      0 => TextAlign.start,
                      1 => TextAlign.center,
                      _ => TextAlign.end,
                    },
                    style: text.bodySmall?.copyWith(
                      color: palette.onHeroSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
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
                      foregroundColor: palette.primaryHover,
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

/// The whole row is the tap target (at least 48 tall), not a small link.
class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, required this.onTap});

  final String? goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: density.rowHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Hedeflerin', style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        goal ?? 'Henüz yazmadın. Diyetisyenin buradan başlar.',
                        style: text.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, color: palette.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YAKINDA',
            style: text.labelSmall?.copyWith(color: palette.textMuted),
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
    );
  }
}
