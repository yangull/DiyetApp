import 'package:core/core.dart';
import 'package:flutter/material.dart';

class RealProfileScreen extends StatelessWidget {
  const RealProfileScreen({
    super.key,
    required this.identity,
    required this.actions,
  });

  final AuthedIdentity identity;
  final AuthGateActions actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final detail = identity.dietitianDetail;

    return ListView(
      padding: EdgeInsets.all(density.pagePadding),
      children: [
        Text('Profil', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AD SOYAD',
                  style: text.labelSmall?.copyWith(color: palette.textMuted),
                ),
                const SizedBox(height: 2),
                Text(identity.profile.fullName, style: text.titleMedium),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'ONAY DURUMU',
                  style: text.labelSmall?.copyWith(color: palette.textMuted),
                ),
                const SizedBox(height: 2),
                Text('Onaylı', style: text.titleMedium),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'UZMANLIK ALANLARI',
                  style: text.labelSmall?.copyWith(color: palette.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  detail == null || detail.specialties.isEmpty
                      ? 'Yakında'
                      : detail.specialties.join(', '),
                  style: text.bodyMedium?.copyWith(
                    color: detail == null || detail.specialties.isEmpty
                        ? palette.textMuted
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton(
          onPressed: actions.signOut,
          child: const Text('Çıkış yapın'),
        ),
      ],
    );
  }
}
