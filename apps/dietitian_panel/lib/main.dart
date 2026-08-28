import 'package:core/core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DietitianPanelApp());
}

class DietitianPanelApp extends StatelessWidget {
  const DietitianPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diyetisyen Paneli',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const _HomePlaceholder(title: 'Diyetisyen Paneli'),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          AppConfig.isConfigured
              ? 'Supabase yapılandırması yüklendi'
              : 'Supabase yapılandırması eksik',
        ),
      ),
    );
  }
}
