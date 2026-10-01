import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_flow_screen.dart';
import 'home/client_home_screen.dart';

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
  runApp(const ProviderScope(child: ClientApp()));
}

/// Assumes Supabase is already initialized — `main()` only builds this once
/// it is, so tests can wrap it in a `ProviderScope` with fake repositories
/// and never touch the network.
class ClientApp extends ConsumerWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Wellkit',
      theme: AppTheme.light(AppDensity.comfortable),
      darkTheme: AppTheme.dark(AppDensity.comfortable),
      themeMode: ref.watch(themeModeProvider),
      home: AuthGate(
        expectedRole: UserRole.client,
        signedOutBuilder: (context) => const AuthFlowScreen(),
        mismatchBuilder: (context, role, actions) => AuthMismatchScreen(
          title: 'Bu hesap bir diyetisyen hesabı.',
          message:
              'Diyetisyenler Wellkit Panel uygulamasını kullanır. '
              'Oradan giriş yapabilirsin.',
          actions: actions,
        ),
        authenticatedBuilder: (context, identity, actions) =>
            ClientHomeScreen(identity: identity, actions: actions),
      ),
    );
  }
}

class _ConfigMissingApp extends StatelessWidget {
  const _ConfigMissingApp();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light(AppDensity.comfortable);
    return MaterialApp(
      title: 'Wellkit',
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
