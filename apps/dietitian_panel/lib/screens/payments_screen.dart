import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../util/panel_date.dart';

/// The commission model made visible, per locked decision §2 #3 (build order:
/// core → dietitian marketplace) and Open Question #1 (the commission rate
/// itself isn't set — %${(kCommissionRate * 100).round()} below is a
/// placeholder to react to, not an announcement).
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return ListView(
      padding: EdgeInsets.all(context.density.pagePadding),
      children: [
        Text('Ödemeler', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tamamlanan seanslardan platform komisyonu düşüldükten sonra size '
          'kalan tutar.',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Brüt kazanç',
                  value: '${demo.grossEarnings} ₺',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryCard(
                  label:
                      'Platform komisyonu (%${(kCommissionRate * 100).round()})',
                  value: '-${demo.commissionTotal} ₺',
                  muted: true,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryCard(
                  label: 'Net kazanç',
                  value: '${demo.netEarnings} ₺',
                  emphasise: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Tamamlanan seanslar', style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Column(
            children: [
              if (demo.completed.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Henüz tamamlanan seans yok.',
                    style: text.bodyMedium?.copyWith(color: palette.textMuted),
                  ),
                ),
              for (var i = 0; i < demo.completed.length; i++)
                _PayoutRow(appointment: demo.completed[i], showDivider: i > 0),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    this.muted = false,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool muted;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: text.labelSmall?.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: text.headlineLarge?.copyWith(
                color: muted
                    ? palette.textMuted
                    : emphasise
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutRow extends ConsumerWidget {
  const _PayoutRow({required this.appointment, required this.showDivider});

  final Appointment appointment;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(appointment.clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final commission = (appointment.fee * kCommissionRate).round();
    final net = appointment.fee - commission;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: palette.borderSubtle))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: text.titleMedium),
                Text(
                  formatDate(appointment.at),
                  style: text.bodySmall?.copyWith(color: palette.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${appointment.fee} ₺',
              style: text.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            child: Text(
              '-$commission ₺',
              style: text.bodyMedium?.copyWith(
                color: palette.textMuted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$net ₺',
              style: text.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            appointment.paid ? 'Tahsil edildi' : 'Bekliyor',
            style: text.bodySmall?.copyWith(
              color: appointment.paid ? AppColors.primary : palette.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
