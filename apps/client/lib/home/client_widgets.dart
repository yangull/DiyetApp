import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The client's goal, budget range and health note, fetched fresh so Bugün and
/// Profil follow a save in Hedeflerim without a new sign-in. Invalidate after
/// writing them.
final clientDetailProvider = FutureProvider.family<ClientDetail, String>((
  ref,
  userId,
) {
  return ref.watch(profileRepositoryProvider).fetchClientDetail(userId);
});

/// A dietitian's name, readable to the client because migration 1's
/// "profiles: read approved dietitians" policy is still in force.
final dietitianProfileProvider = FutureProvider.family<AppProfile, String>((
  ref,
  dietitianId,
) {
  return ref.watch(profileRepositoryProvider).fetchProfile(dietitianId);
});

class DietitianRow extends ConsumerWidget {
  const DietitianRow({super.key, required this.dietitianId});

  final String dietitianId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final name = ref
        .watch(dietitianProfileProvider(dietitianId))
        .asData
        ?.value
        .fullName;

    return CloudCard(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: density.rowHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              PersonAvatar(name: name, size: context.density.avatarSize + 4),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Diyetisyenin',
                      style: text.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    Text(name ?? '', style: text.titleMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
