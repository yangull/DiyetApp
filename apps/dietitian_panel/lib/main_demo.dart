import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'panel_shell.dart';

/// The interview demo: no login, straight to the five-destination rail
/// running on fake in-memory data (see `lib/demo/`). This is what Can drives
/// live in front of a dietitian — see HANDOFF.md §1. Run it explicitly:
///
/// ```sh
/// flutter run -t lib/main_demo.dart -d web-server \
///   --web-hostname 0.0.0.0 --web-port 8081
/// ```
///
/// `lib/main.dart` is the real, auth-gated panel and does not touch this file.
void main() {
  runApp(const ProviderScope(child: DietitianPanelDemoApp()));
}

class DietitianPanelDemoApp extends StatelessWidget {
  const DietitianPanelDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellkit Panel (Demo)',
      // This is driven in front of dietitians and captured for screenshots;
      // the debug ribbon in the corner is noise in both settings.
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(AppDensity.compact),
      home: const PanelShell(),
    );
  }
}
