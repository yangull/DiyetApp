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
        CloudCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ad soyad',
                  style: text.bodySmall?.copyWith(color: palette.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(identity.profile.fullName, style: text.titleMedium),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Onay durumu',
                  style: text.bodySmall?.copyWith(color: palette.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  _verificationLabel(detail?.verificationStatus),
                  style: text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Uzmanlık alanları',
                  style: text.bodySmall?.copyWith(color: palette.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  detail == null || detail.specialties.isEmpty
                      ? 'Yakında'
                      : detail.specialties.join(', '),
                  style: text.bodyMedium?.copyWith(
                    color: detail == null || detail.specialties.isEmpty
                        ? palette.textSecondary
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Görünüm', style: text.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        const ThemeChoiceSelector(),
        const SizedBox(height: AppSpacing.xl),
        SignOutRow(onPressed: actions.signOut),
      ],
    );
  }
}

// This screen is only ever reached from RealPanelShell, which AuthGate only
// builds for an approved dietitian — but the label is derived rather than
// hardcoded so that stays true even if this widget is reused elsewhere later.
String _verificationLabel(VerificationStatus? status) => switch (status) {
  VerificationStatus.approved => 'Onaylı',
  VerificationStatus.pending => 'İnceleniyor',
  VerificationStatus.rejected => 'Onaylanmadı',
  null => '—',
};
