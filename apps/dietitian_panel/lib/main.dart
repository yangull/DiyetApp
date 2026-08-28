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
      theme: AppTheme.light(AppDensity.compact),
      home: const _PanelPlaceholder(),
    );
  }
}

class _PanelPlaceholder extends StatelessWidget {
  const _PanelPlaceholder();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    return Scaffold(
      appBar: AppBar(title: const Text('Diyetisyen Paneli')),
      body: Padding(
        padding: EdgeInsets.all(density.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Danışanlarınız', style: text.headlineLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Henüz danışanınız yok. Marketplace yayına girdiğinde '
              'danışanlarınız burada listelenecek.',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppConfig.isConfigured
                  ? 'Supabase yapılandırması yüklendi'
                  : 'Supabase yapılandırması eksik',
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
