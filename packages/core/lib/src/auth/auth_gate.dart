import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'models.dart';

/// What an authenticated or mismatched screen needs to act, beyond the data
/// it was handed: refetch the identity (the "Durumu Yenile" button), or sign
/// out (every screen past the login form needs an escape hatch).
class AuthGateActions {
  const AuthGateActions({required this.refreshIdentity, required this.signOut});

  final VoidCallback refreshIdentity;
  final Future<void> Function() signOut;
}

/// The signed-in / signed-out / loading / error router PLANNING.md §2.3 #45
/// calls "kalıcı ürün kodu" (permanent product code): it owns the session
/// stream, the profile + detail fetch, and the reverse-app check from §2.3
/// #39 (a dietitian in the client app, or a client in the panel, sees a
/// full-screen message instead of the wrong home screen — no auto sign-out).
///
/// What it deliberately does NOT own: which screen a dietitian sees for
/// `pending` vs `approved` vs `rejected`. That branch is app-specific, so it
/// lives in the [authenticatedBuilder] each app supplies.
class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    required this.expectedRole,
    required this.signedOutBuilder,
    required this.authenticatedBuilder,
    this.mismatchBuilder,
  });

  final UserRole expectedRole;
  final WidgetBuilder signedOutBuilder;
  final Widget Function(
    BuildContext context,
    AuthedIdentity identity,
    AuthGateActions actions,
  )
  authenticatedBuilder;
  final Widget Function(
    BuildContext context,
    UserRole actualRole,
    AuthGateActions actions,
  )?
  mismatchBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      loading: () => const _CenteredSpinner(),
      error: (error, _) => _CenteredError(message: '$error'),
      data: (session) {
        if (session == null) return signedOutBuilder(context);

        final actions = AuthGateActions(
          refreshIdentity: () =>
              ref.invalidate(identityProvider(session.userId)),
          signOut: () => ref.read(authRepositoryProvider).signOut(),
        );

        final identityAsync = ref.watch(identityProvider(session.userId));
        return identityAsync.when(
          loading: () => const _CenteredSpinner(),
          error: (error, _) => _CenteredError(
            message: '$error',
            onRetry: actions.refreshIdentity,
          ),
          data: (identity) {
            if (identity.profile.role != expectedRole) {
              final builder = mismatchBuilder ?? _defaultMismatch;
              return builder(context, identity.profile.role, actions);
            }
            return authenticatedBuilder(context, identity, actions);
          },
        );
      },
    );
  }

  static Widget _defaultMismatch(
    BuildContext context,
    UserRole actualRole,
    AuthGateActions actions,
  ) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 40),
              const SizedBox(height: 16),
              const Text(
                'Bu giriş bu uygulama için değil.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: actions.signOut,
                child: const Text('Çıkış yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredSpinner extends StatelessWidget {
  const _CenteredSpinner();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _CenteredError extends StatelessWidget {
  const _CenteredError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Tekrar dene'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
