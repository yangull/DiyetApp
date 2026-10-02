import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../util/breakpoints.dart';
import '../widgets/readable_width.dart';
import '../widgets/tone_pill.dart';

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

    final name = identity.profile.fullName.trim();
    final status = detail?.verificationStatus;
    final specialties = detail?.specialties ?? const <String>[];

    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: readablePadding(
          constraints.maxWidth,
          density.pagePadding,
          maxWidth: 720,
        ),
        children: [
          Row(
            children: [
              PersonAvatar(name: name, size: 64),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    name.isEmpty ? 'Profil' : name,
                    style: isPanelPhone(context)
                        ? text.headlineMedium
                        : text.headlineLarge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),
          CloudCard(
            child: Padding(
              padding: EdgeInsets.all(density.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Onay durumu',
                    style: text.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TonePill(
                      label: _verificationLabel(status),
                      tone: status == VerificationStatus.approved
                          ? PillTone.approved
                          : PillTone.neutral,
                    ),
                  ),
                  // Shown once there is something to show: "Yakında" in a row
                  // of real data read as a value.
                  if (specialties.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Uzmanlık alanları',
                      style: text.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(specialties.join(', '), style: text.titleMedium),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Semantics(
            header: true,
            child: Text('Görünüm', style: text.headlineSmall),
          ),
          const SizedBox(height: AppSpacing.md),
          const ThemeChoiceSelector(),
          const SizedBox(height: AppSpacing.xl),
          SignOutRow(onPressed: actions.signOut),
        ],
      ),
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
