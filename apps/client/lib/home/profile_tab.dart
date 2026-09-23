import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_widgets.dart';
import 'goals_edit_screen.dart';

/// Profil: who the client is, what they told their dietitian, and who that
/// dietitian is. A summary to read, not a form; editing happens on its own
/// screen (design-system "Redesign Sıcak").
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key, required this.identity, required this.actions});

  final AuthedIdentity identity;
  final AuthGateActions actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final profile = identity.profile;
    final detail =
        ref.watch(clientDetailProvider(profile.id)).asData?.value ??
        identity.clientDetail;
    final dietitians =
        ref.watch(myActiveRelationshipsProvider).asData?.value ??
        const <ClientRelationship>[];
    final name = profile.fullName.trim();

    return ListView(
      padding: EdgeInsets.all(density.pagePadding),
      children: [
        Row(
          children: [
            // On the ground the subtle fill nearly vanishes (1.05:1), so this
            // one sits on white.
            PersonAvatar(name: name, size: 64, background: AppColors.surface),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                name.isEmpty ? 'Profil' : name,
                style: text.headlineMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x3),
        _SectionHeader(
          title: 'HEDEFLERİN',
          action: TextButton(
            onPressed: () => GoalsEditScreen.open(
              context,
              userId: profile.id,
              detail: detail,
            ),
            child: const Text('Düzenle'),
          ),
        ),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoRow(label: 'Hedefim', value: detail?.goal),
              const Divider(),
              _InfoRow(label: 'Bütçe aralığım', value: detail?.budgetRange),
              const Divider(),
              _InfoRow(label: 'Sağlık notlarım', value: detail?.healthNotes),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _SectionHeader(title: 'DİYETİSYENİN'),
        if (dietitians.isEmpty)
          Text(
            'Henüz bir diyetisyenin yok. Bir davet geldiğinde Bugün '
            'ekranında görünür.',
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          )
        else
          for (final r in dietitians) ...[
            DietitianRow(dietitianId: r.dietitianId),
            const SizedBox(height: AppSpacing.md),
          ],
        const SizedBox(height: AppSpacing.xxl),
        const _SectionHeader(title: 'YAKINDA'),
        Text(
          'Dosyaların: diyetisyeninle paylaşacağın rapor ve belgeler.',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.x4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: actions.signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış yap'),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: text.labelSmall?.copyWith(
                color: context.palette.textMuted,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final filled = value?.trim().isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.bodySmall?.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            filled ? value!.trim() : 'Yazılmadı',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: filled
                ? text.bodyLarge
                : text.bodyLarge?.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}
