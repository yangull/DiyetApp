import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// PLANNING.md §2.3 #53: an honest empty state. There is no client data to
/// show yet — Faz 1 hasn't built the marketplace match that would produce
/// any — so this says that plainly rather than showing fake numbers.
class RealOverviewScreen extends StatelessWidget {
  const RealOverviewScreen({super.key, required this.profile});

  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    return Padding(
      padding: EdgeInsets.all(density.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hoş geldiniz, ${profile.fullName}', style: text.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Danışan yönetimi henüz açılmadı.',
            style: text.bodyLarge?.copyWith(color: palette.textSecondary),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: _EmptyState(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.people_outline, size: 40, color: palette.textMuted),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Henüz danışanınız yok',
          style: text.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Wellkit marketplace\'i açıldığında danışan eşleşmeleriniz '
          'burada görünecek.',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
