import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// PLANNING.md §2.3 #52: no panel frame while a dietitian isn't approved —
/// deliberately, so approval reads as a real unlock rather than a settings
/// toggle. `pending` and `rejected` share this layout with a different
/// message; `approved` never reaches this widget.
class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({
    super.key,
    required this.status,
    required this.actions,
  });

  final VerificationStatus status;
  final AuthGateActions actions;

  @override
  Widget build(BuildContext context) {
    assert(status != VerificationStatus.approved);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final rejected = status == VerificationStatus.rejected;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      rejected
                          ? Icons.error_outline
                          : Icons.hourglass_top_outlined,
                      size: 40,
                      color: rejected ? palette.warning : palette.textMuted,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      rejected
                          ? 'Başvurunuz Onaylanmadı'
                          : 'Başvurunuz İnceleniyor',
                      style: text.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      rejected
                          ? 'Başvurunuz bu haliyle onaylanmadı. Sorularınız '
                                'için bizimle iletişime geçebilirsiniz.'
                          : 'Ekibimiz bilgilerinizi inceliyor. Onaylandığında '
                                'panele otomatik olarak yönlendirileceksiniz.',
                      style: text.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (!rejected)
                      FilledButton(
                        onPressed: actions.refreshIdentity,
                        child: const Text('Durumu Yenile'),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: actions.signOut,
                      child: const Text('Çıkış yapın'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
