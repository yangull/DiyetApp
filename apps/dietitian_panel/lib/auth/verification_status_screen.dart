import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Placeholder until C16 (who answers a rejected dietitian) is decided.
const kSupportEmail = 'destek@wellkit.app';

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

    final icon = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: palette.canvas, shape: BoxShape.circle),
      child: Icon(
        rejected ? AppIcons.info : AppIcons.waiting,
        size: 28,
        color: rejected ? palette.warning : palette.textSecondary,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.density.pagePadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: WellkitMark(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CloudCard(
                    child: Padding(
                      padding: EdgeInsets.all(context.density.cardPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExcludeSemantics(child: icon),
                          const SizedBox(height: AppSpacing.lg),
                          Semantics(
                            header: true,
                            child: Text(
                              rejected
                                  ? 'Başvurunuz Onaylanmadı'
                                  : 'Başvurunuz İnceleniyor',
                              style: text.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            rejected
                                ? 'Başvurunuz bu haliyle onaylanmadı. '
                                      'Sorularınız için bize yazabilirsiniz:'
                                : 'Ekibimiz bilgilerinizi inceliyor. '
                                      'Onaylandığında panele otomatik olarak '
                                      'yönlendirileceksiniz.',
                            style: text.bodyMedium?.copyWith(
                              color: palette.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (rejected) ...[
                            const SizedBox(height: AppSpacing.xs),
                            SelectableText(
                              kSupportEmail,
                              style: text.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          if (!rejected) ...[
                            FilledButton(
                              onPressed: actions.refreshIdentity,
                              child: const Text('Durumu yenile'),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          TextButton(
                            onPressed: actions.signOut,
                            child: const Text('Çıkış yap'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
