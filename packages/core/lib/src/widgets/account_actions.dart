import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/edge_button.dart';
import '../theme/tokens/app_spacing.dart';
import 'cloud_card.dart';

/// The link under a login or sign-up form that switches to the other one
/// ("Hesabın yok mu? Kayıt ol"). Left, on the fields' edge, in both apps.
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: EdgeButton(
        child: TextButton(onPressed: onPressed, child: Text(label)),
      ),
    );
  }
}

/// "Çıkış yap" on a profile screen: a row of its own in a Cloud Card, set
/// apart from the content above it, so it doesn't read as one more link.
class SignOutRow extends StatelessWidget {
  const SignOutRow({super.key, required this.onPressed});

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return CloudCard(
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: MediaQuery.textScalerOf(context).scale(22),
                    color: palette.ink,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Çıkış yap',
                      style: Theme.of(context).textTheme.titleMedium,
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
