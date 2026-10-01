import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_flow_screen.dart';
import 'auth/verification_status_screen.dart';
import 'panel/real_panel_shell.dart';
import 'util/breakpoints.dart';

/// The real panel: login/signup → pending or rejected screen → the
/// two-destination approved shell (PLANNING.md §2.3 #52–53). For the
/// unauthenticated five-tab interview demo running on fake data, see
/// `lib/main_demo.dart` instead — this file does not touch it.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.isConfigured) {
    runApp(const _ConfigMissingApp());
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );
  runApp(const ProviderScope(child: DietitianPanelApp()));
}

/// Assumes Supabase is already initialized — `main()` only builds this once
/// it is, so tests can wrap it in a `ProviderScope` with fake repositories
/// and never touch the network.
class DietitianPanelApp extends ConsumerWidget {
  const DietitianPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Wellkit Panel',
      theme: AppTheme.light(AppDensity.compact),
      darkTheme: AppTheme.dark(AppDensity.compact),
      themeMode: ref.watch(themeModeProvider),
      // The density follows the input (#135); the builder picks it.
      builder: panelThemeBuilder,
      home: AuthGate(
        expectedRole: UserRole.dietitian,
        formal: true,
        signedOutBuilder: (context) => const AuthFlowScreen(),
        mismatchBuilder: (context, role, actions) => AuthMismatchScreen(
          title: 'Bu hesap bir danışan hesabı.',
          message:
              'Danışanlar Wellkit uygulamasını kullanır. '
              'Oradan giriş yapabilirsiniz.',
          actions: actions,
        ),
        authenticatedBuilder: (context, identity, actions) {
          // Safe: AuthGate only calls this once identity.profile.role ==
          // expectedRole (dietitian), and identityProvider always populates
          // dietitianDetail for that role (auth_providers.dart).
          final status = identity.dietitianDetail!.verificationStatus;
          if (status == VerificationStatus.approved) {
            return RealPanelShell(identity: identity, actions: actions);
          }
          return VerificationStatusScreen(status: status, actions: actions);
        },
      ),
    );
  }
}

class _ConfigMissingApp extends StatelessWidget {
  const _ConfigMissingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellkit Panel',
      theme: AppTheme.light(AppDensity.compact),
      builder: panelThemeBuilder,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Supabase yapılandırması eksik. --dart-define-from-file ile '
              'env/dev.json kullanarak çalıştırın.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
