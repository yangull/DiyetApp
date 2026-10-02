import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/progress.dart';
import '../widgets/interview_note.dart';
import '../widgets/weight_chart.dart';
import '../widgets/readable_width.dart';

/// Content this wide or wider lays the charts out two to a row, so a computer
/// screen neither stretches each chart to 1100 px nor scrolls past five.
const _twoColumnWidth = 900.0;

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = readablePadding(
          constraints.maxWidth,
          context.density.pagePadding,
        );
        final content = constraints.maxWidth - padding.horizontal;
        final columns = content >= _twoColumnWidth ? 2 : 1;
        final cardWidth = (content - AppSpacing.md * (columns - 1)) / columns;

        return ListView(
          padding: padding,
          children: [
            Text('Takip ve raporlar', style: text.headlineLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Danışan başına kilo seyri, hedef kilosuna göre.',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            const InterviewNote(
              'Kilo koruma hedefindeki bir danışanda düşüş de dikkat '
              'gerektirir; bu ayrımı doğru mu kuruyoruz, ve hangi ölçümleri '
              'düzenli takip ediyorsunuz?',
            ),
            const SizedBox(height: AppSpacing.lg),
            _SummaryCard(clients: demo.clients, weights: demo.weights),
            SizedBox(height: context.density.sectionGap),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final client in demo.clients)
                  SizedBox(
                    width: cardWidth,
                    child: _ChartCard(
                      client: client,
                      entries: demo.weights[client.id] ?? const [],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

Color _verdictColor(BuildContext context, ProgressVerdict verdict) =>
    switch (verdict) {
      ProgressVerdict.onTrack => context.palette.accent,
      ProgressVerdict.offTrack => context.palette.warning,
      ProgressVerdict.neutral => context.palette.textSecondary,
    };

/// One client's figures for the summary. With fewer than two weigh-ins there
/// is no change to judge yet (a client just added through "Yeni danışan"), so
/// the row says so instead of calling a zero change off track.
class _Figures {
  _Figures(DemoClient client, this.entries)
    : progress = entries.length < 2 ? null : weightProgress(client, entries),
      target = client.targetWeightKg;

  final List<WeightEntry> entries;
  final WeightProgress? progress;
  final double? target;

  double? get last => entries.isEmpty ? null : entries.last.kg;

  String get verdict =>
      progress?.label ?? (entries.isEmpty ? 'tartım yok' : 'tek tartım');

  ProgressVerdict get tone => progress?.verdict ?? ProgressVerdict.neutral;

  String? get remaining => remainingToTarget(
    target: target,
    last: last,
    direction: progress?.direction,
  );
}

/// What is left to the hedef kilo, or "hedefte" once a client losing or
/// gaining has reached or passed it: an absolute distance past the target read
/// as kilos still to go. Null without a target or a weight.
@visibleForTesting
String? remainingToTarget({
  required double? target,
  required double? last,
  required GoalDirection? direction,
}) {
  if (target == null || last == null) return null;
  final left = target - last;
  final reached = switch (direction) {
    GoalDirection.losing => left >= 0,
    GoalDirection.gaining => left <= 0,
    _ => false,
  };
  return reached ? 'hedefte' : '${formatDecimal(left.abs())} kg';
}

/// Every client on one line each: the last weight, the change and what is
/// left to the hedef kilo, in right-aligned slots so the decimals line up
/// (#135). Where the four columns don't fit beside a name (a phone, large
/// text) each row keeps the change and the last weight on the right and says
/// what is left under the name; where even that is tight, the figures drop
/// under the name.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.clients, required this.weights});

  final List<DemoClient> clients;
  final Map<String, List<WeightEntry>> weights;

  /// The least a name gets beside the figures (at 1× text).
  static const _minNameWidth = 140.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final caption = text.bodySmall!.copyWith(color: palette.textSecondary);
    final number = text.titleMedium!;
    final scale = MediaQuery.textScalerOf(context).scale(1);

    return CloudCard(
      child: Padding(
        padding: EdgeInsets.all(context.density.cardPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final numberSlot = numberSlotWidth(context, '000,0 kg', number);
            // In the table each column is as wide as its value or its
            // header, whichever is wider, so a header never wraps.
            final tableSlot = [
              numberSlot,
              numberSlotWidth(context, 'Son tartım', caption),
              numberSlotWidth(context, 'Hedefe kalan', caption),
            ].reduce(math.max);
            final wide =
                constraints.maxWidth >=
                3 * tableSlot +
                    _ChangeValue.iconSlot +
                    3 * AppSpacing.lg +
                    _minNameWidth * scale;
            final slot = wide ? tableSlot : numberSlot;
            final changeSlot = slot + _ChangeValue.iconSlot;
            final stacked =
                !wide &&
                constraints.maxWidth - changeSlot - AppSpacing.md <
                    _minNameWidth * scale;
            Widget cell(String label, double width) => SizedBox(
              width: width,
              child: Text(label, textAlign: TextAlign.end, style: caption),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Özet', style: text.titleLarge),
                const SizedBox(height: AppSpacing.md),
                if (wide)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(child: Text('Danışan', style: caption)),
                        cell('Son tartım', slot),
                        const SizedBox(width: AppSpacing.lg),
                        cell('Değişim', changeSlot),
                        const SizedBox(width: AppSpacing.lg),
                        cell('Hedefe kalan', slot),
                      ],
                    ),
                  ),
                for (final (i, client) in clients.indexed) ...[
                  if (i > 0 || wide) Divider(height: 1, color: palette.divider),
                  _SummaryRow(
                    name: client.name,
                    figures: _Figures(client, weights[client.id] ?? const []),
                    wide: wide,
                    stacked: stacked,
                    slot: slot,
                    changeSlot: changeSlot,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.name,
    required this.figures,
    required this.wide,
    required this.stacked,
    required this.slot,
    required this.changeSlot,
  });

  final String name;
  final _Figures figures;
  final bool wide;
  final bool stacked;
  final double slot;
  final double changeSlot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final number = text.titleMedium!;
    final muted = number.copyWith(color: palette.textSecondary);
    final caption = text.bodySmall!.copyWith(color: palette.textSecondary);
    final last = figures.last;
    final remaining = figures.remaining;
    final lastLabel = last == null ? '—' : '${formatDecimal(last)} kg';

    Widget value(String label, TextStyle style) => SizedBox(
      width: slot,
      child: Text(label, textAlign: TextAlign.end, style: style),
    );

    final verdict = TextSpan(
      text: figures.verdict,
      style: caption.copyWith(color: _verdictColor(context, figures.tone)),
    );
    final who = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: text.titleMedium),
        Text.rich(
          wide || remaining == null
              ? verdict
              : TextSpan(
                  children: [
                    verdict,
                    TextSpan(
                      text: remaining == 'hedefte'
                          ? ' · hedefte'
                          : ' · kalan $remaining',
                      style: caption,
                    ),
                  ],
                ),
        ),
      ],
    );

    if (wide) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(child: who),
            value(lastLabel, last == null ? muted : number),
            const SizedBox(width: AppSpacing.lg),
            SizedBox(
              width: changeSlot,
              child: _ChangeValue(progress: figures.progress, style: number),
            ),
            const SizedBox(width: AppSpacing.lg),
            value(remaining ?? '—', remaining == null ? muted : number),
          ],
        ),
      );
    }

    final figuresColumn = SizedBox(
      width: changeSlot,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ChangeValue(progress: figures.progress, style: number),
          Text(lastLabel, textAlign: TextAlign.end, style: caption),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                who,
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: figuresColumn,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: who),
                const SizedBox(width: AppSpacing.md),
                figuresColumn,
              ],
            ),
    );
  }
}

/// The change since the first weigh-in, right-aligned: the arrow says which
/// way the scale moved, the colour whether that is what this client wanted.
/// No change to judge yet is a grey dash; no movement has no arrow.
class _ChangeValue extends StatelessWidget {
  const _ChangeValue({required this.progress, required this.style});

  final WeightProgress? progress;
  final TextStyle style;

  static const iconSlot = 16.0 + 4.0;

  @override
  Widget build(BuildContext context) {
    final progress = this.progress;
    if (progress == null) {
      return Text(
        '—',
        textAlign: TextAlign.end,
        style: style.copyWith(color: context.palette.textSecondary),
      );
    }
    final color = _verdictColor(context, progress.verdict);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (progress.deltaKg != 0) ...[
          Icon(
            progress.isLoss ? AppIcons.arrowDown : AppIcons.arrowUp,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            '${formatDecimal(progress.deltaKg.abs())} kg',
            textAlign: TextAlign.end,
            style: style.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.client, required this.entries});

  final DemoClient client;
  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    return CloudCard(
      child: Padding(
        padding: EdgeInsets.all(context.density.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wraps rather than overflows on a phone or at large text.
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(client.name, style: text.titleLarge),
                Text(
                  client.goal,
                  style: text.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // A line needs two points; one weigh-in would leave a blank box.
            if (entries.length < 2)
              Text(
                'Grafik ikinci tartımdan sonra görünür.',
                style: text.bodyMedium?.copyWith(color: palette.textSecondary),
              )
            else
              WeightChart(entries: entries, targetKg: client.targetWeightKg),
          ],
        ),
      ),
    );
  }
}
