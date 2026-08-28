import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'panel_shell.dart';

void main() {
  runApp(const ProviderScope(child: DietitianPanelApp()));
}

class DietitianPanelApp extends StatelessWidget {
  const DietitianPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellkit Panel',
      theme: AppTheme.light(AppDensity.compact),
      home: const PanelShell(),
    );
  }
}
