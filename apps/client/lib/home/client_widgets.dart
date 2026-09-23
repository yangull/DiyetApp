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

/// First and last initials, skipping titles such as "Dyt.".
String initialsOf(String? fullName) {
  final parts = (fullName ?? '').trim().split(RegExp(r'\s+'))
    ..removeWhere((p) => p.isEmpty || p.endsWith('.'));
  if (parts.isEmpty) return '';
  final first = parts.first.characters.first;
  final last = parts.length > 1 ? parts.last.characters.first : '';
  return (first + last).toUpperCase();
}

/// Neutral on purpose: group colours never mark people (design rule 15).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    this.size,
    this.background,
  });

  final String? name;
  final double? size;

  /// Defaults to `surfaceSubtle`, which reads on white cards.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final side = size ?? context.density.avatarSize + 4;
    final text = Theme.of(context).textTheme;
    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? palette.surfaceSubtle,
        shape: BoxShape.circle,
        border: background == null
            ? null
            : Border.all(color: palette.borderSubtle),
      ),
      child: Text(
        initialsOf(name),
        style: (side > 56 ? text.titleLarge : text.titleMedium)?.copyWith(
          color: palette.textSecondary,
        ),
      ),
    );
  }
}

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

    return Card(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: density.rowHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              PersonAvatar(name: name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Diyetisyenin',
                      style: text.bodySmall?.copyWith(color: palette.textMuted),
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
