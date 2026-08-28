import 'package:core/core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ClientApp());
}

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellkit',
      theme: AppTheme.light(AppDensity.comfortable),
      home: const _HomePlaceholder(),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    return Scaffold(
      appBar: AppBar(title: const Text('Wellkit')),
      body: Padding(
        padding: EdgeInsets.all(density.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Merhaba, Can', style: text.headlineLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Bugün nasıl ilerlemek istersin?',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _PathCard(
              title: 'Diyetisyenle çalış',
              body: 'Sana uygun diyetisyeni seç, planınızı birlikte oluşturun.',
            ),
            const SizedBox(height: AppSpacing.md),
            const _PathCard(
              title: 'Yapay zekâ ile ilerle',
              body: 'Yapay zekâ destekli beslenme planı ve düzenli takip.',
            ),
            const Spacer(),
            Text(
              AppConfig.isConfigured
                  ? 'Supabase yapılandırması yüklendi'
                  : 'Supabase yapılandırması eksik',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: text.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
