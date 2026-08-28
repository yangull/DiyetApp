import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_flow_screen.dart';
import 'auth/verification_status_screen.dart';
import 'panel/real_panel_shell.dart';

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
class DietitianPanelApp extends StatelessWidget {
  const DietitianPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellkit Panel',
      theme: AppTheme.light(AppDensity.compact),
      home: AuthGate(
        expectedRole: UserRole.dietitian,
        signedOutBuilder: (context) => const AuthFlowScreen(),
        authenticatedBuilder: (context, identity, actions) {
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
    final theme = AppTheme.light(AppDensity.compact);
    return MaterialApp(
      title: 'Wellkit Panel',
      theme: theme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Supabase yapılandırması eksik. --dart-define-from-file ile '
              'env/dev.json kullanarak çalıştırın.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
