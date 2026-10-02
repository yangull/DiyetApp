import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_states.dart';
import 'auth_providers.dart';
import 'models.dart';
import '../theme/app_icons.dart';

/// What an authenticated or mismatched screen needs to act, beyond the data
/// it was handed: refetch the identity (the "Durumu yenile" button), or sign
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
    this.formal = false,
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

  /// Addresses the person as "siz" in the failure messages (the panel).
  final bool formal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync.when(
      loading: () => const _Loading(),
      error: (_, _) => _Failed(
        title: 'Oturum bilgisi alınamadı',
        formal: formal,
        onRetry: () => ref.invalidate(sessionProvider),
        // Retrying can replay the same stored error; a local sign-out
        // replaces it.
        onSignOut: () => ref.read(authRepositoryProvider).signOut(),
      ),
      data: (session) {
        if (session == null) return signedOutBuilder(context);

        final actions = AuthGateActions(
          refreshIdentity: () =>
              ref.invalidate(identityProvider(session.userId)),
          signOut: () => ref.read(authRepositoryProvider).signOut(),
        );

        final identityAsync = ref.watch(identityProvider(session.userId));
        return identityAsync.when(
          loading: () => const _Loading(),
          error: (_, _) => _Failed(
            title: 'Hesap bilgileri yüklenemedi',
            formal: formal,
            onRetry: actions.refreshIdentity,
            onSignOut: actions.signOut,
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
    return AuthMismatchScreen(
      title: 'Bu giriş bu uygulama için değil.',
      actions: actions,
    );
  }
}

/// A signed-in account that belongs to the other app. Names the app to use
/// instead in [message]; signing out is the only way on, so it is the one
/// action (no auto sign-out, PLANNING #39).
class AuthMismatchScreen extends StatelessWidget {
  const AuthMismatchScreen({
    super.key,
    required this.title,
    this.message,
    required this.actions,
  });

  final String title;
  final String? message;
  final AuthGateActions actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppErrorView(
        icon: AppIcons.info,
        title: title,
        message: message,
        actionLabel: 'Çıkış yap',
        onAction: actions.signOut,
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: AppLoading(label: 'Yükleniyor'));
}

class _Failed extends StatelessWidget {
  const _Failed({
    required this.title,
    required this.formal,
    required this.onRetry,
    this.onSignOut,
  });

  final String title;
  final bool formal;
  final VoidCallback onRetry;
  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context) {
    final signOut = onSignOut;
    return Scaffold(
      body: AppErrorView(
        title: title,
        message: formal
            ? 'Bağlantınızı kontrol edip tekrar deneyin.'
            : 'Bağlantını kontrol edip tekrar dene.',
        onRetry: onRetry,
        actionLabel: signOut == null ? null : 'Çıkış yap',
        onAction: signOut,
      ),
    );
  }
}
