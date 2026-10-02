import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../widgets/interview_note.dart';
import '../widgets/readable_width.dart';
import '../demo/demo_repository.dart';
import '../demo/energy.dart';
import '../demo/progress.dart';
import '../util/panel_date.dart';
import '../widgets/status_pill.dart';
import '../widgets/weight_chart.dart';
import 'exchange_plan_editor_screen.dart';
import 'plan_editor_screen.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  const ClientDetailScreen({
    super.key,
    required this.clientId,
    this.showWeights = false,
  });

  final String clientId;

  /// Opens scrolled to the weight card, for the overview's
  /// "Ölçümleri incele" link.
  final bool showWeights;

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  final _weightsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.showWeights) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _weightsKey.currentContext;
        if (target != null) Scrollable.ensureVisible(target);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientId = widget.clientId;
    final demo = ref.watch(demoProvider);
    final client = demo.clients.firstWhere((c) => c.id == clientId);
    final plan = demo.planFor(clientId);
    final weights = demo.weights[clientId] ?? const [];
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      // Not a lazy ListView: the weight card has to be built for
      // showWeights to scroll to it.
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: readablePadding(
            constraints.maxWidth,
            context.density.pagePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CloudCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Diyet planı', style: text.titleLarge),
                          StatusPill(state: plan.state),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${plan.day} · ${plan.kcal} kcal · ${plan.meals.length} öğün',
                        style: text.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          FilledButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlanEditorScreen(clientId: clientId),
                              ),
                            ),
                            child: Text(
                              plan.isDraft ? 'Taslağı düzenle' : 'Planı aç',
                            ),
                          ),
                          // Only where an exchange-list version of the day exists.
                          if (demo.exchangePlanFor(clientId) != null)
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ExchangePlanEditorScreen(
                                    clientId: clientId,
                                  ),
                                ),
                              ),
                              child: const Text('Değişim listesiyle dene'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CloudCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Danışan bilgileri', style: text.titleLarge),
                      const SizedBox(height: AppSpacing.lg),
                      _FactGrid(
                        children: [
                          _Fact(label: 'Yaş', value: '${client.age}'),
                          _Fact(label: 'Boy', value: '${client.heightCm} cm'),
                          _Fact(
                            label: 'Güncel kilo',
                            value: '${formatDecimal(client.weightKg)} kg',
                          ),
                          _Fact(label: 'Hedef', value: client.goal),
                          _Fact(
                            label: 'Hedef kilo',
                            value: client.targetWeightKg == null
                                ? _empty
                                : '${formatDecimal(client.targetWeightKg!)} kg',
                          ),
                          _Fact(
                            label: 'Başlangıç',
                            value: formatDate(client.startedOn),
                          ),
                          _Fact(
                            label: 'Cinsiyet',
                            value: _sexLabel(client.sex),
                          ),
                          _Fact(
                            label: 'Hareket düzeyi',
                            value: _activityLabel(client.activityLevel),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Divider(color: palette.divider),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Sağlık bilgileri', style: text.titleMedium),
                      const SizedBox(height: AppSpacing.lg),
                      _FactGrid(
                        children: [
                          _Fact(label: 'Beslenme tipi', value: client.dietType),
                          _Fact(
                            label: 'Alerji / hassasiyet',
                            value: _listOrDash(client.allergies),
                          ),
                          _Fact(
                            label: 'Kronik rahatsızlık',
                            value: _listOrDash(client.chronicConditions),
                          ),
                          _Fact(
                            label: 'İlaç / takviye',
                            value: _listOrDash(client.medications),
                          ),
                        ],
                      ),
                      if (client.note.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Not',
                          style: text.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          client.note,
                          style: text.bodyMedium?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _EnergyCard(client: client),
              const SizedBox(height: AppSpacing.lg),
              CloudCard(
                key: _weightsKey,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Apart on one line when it fits, stacked when it doesn't.
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Text('Kilo takibi', style: text.titleLarge),
                          if (weights.isNotEmpty)
                            _ProgressLabel(client: client, entries: weights),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (weights.isEmpty)
                        Text(
                          'Henüz ölçüm kaydı yok.',
                          style: text.bodyMedium?.copyWith(
                            color: palette.textSecondary,
                          ),
                        )
                      else ...[
                        WeightChart(
                          entries: weights,
                          targetKg: client.targetWeightKg,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        for (final entry in weights.reversed.take(4))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    formatDate(entry.date),
                                    style: text.bodyMedium?.copyWith(
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                ),
                                // Right-aligned with a minimum width of the
                                // widest weight, so decimals line up and a
                                // narrow card can still squeeze it.
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: numberSlotWidth(
                                      context,
                                      '000,0 kg',
                                      text.bodyLarge!,
                                    ),
                                  ),
                                  child: Text(
                                    '${formatDecimal(entry.kg)} kg',
                                    textAlign: TextAlign.end,
                                    style: text.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      const InterviewNote(
                        'Ölçümleri şimdilik yalnızca görüntülüyoruz; danışan '
                        'kendisi giriyor. Tartımı siz mi alıyorsunuz, hangi '
                        'sıklıkla?',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _MeasurementsCard(measurements: demo.measurementsOf(clientId)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The four readings we guessed a dietitian takes alongside the scale. Shown
/// newest-first with the change since the previous session, because a single
/// column of numbers answers nothing — the question is whether bel çevresi
/// moved while the scale did not.
class _MeasurementsCard extends StatelessWidget {
  const _MeasurementsCard({required this.measurements});

  final List<BodyMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final rows = measurements.reversed.toList();

    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                Text('Vücut ölçümleri', style: text.titleLarge),
                if (rows.isNotEmpty)
                  Text(
                    '${rows.length} ölçüm',
                    style: text.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (rows.isEmpty)
              Text(
                'Bu danışan için kilo dışında ölçüm kaydı yok.',
                style: text.bodyMedium?.copyWith(color: palette.textSecondary),
              )
            else
              // Six columns do not fit a phone: the table keeps its width and
              // scrolls sideways instead of squeezing the numbers.
              _WideTable(
                minWidth: 620,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 96),
                      _MeasurementHead(label: 'Bel'),
                      _MeasurementHead(label: 'Kalça'),
                      _MeasurementHead(label: 'Bel/kalça'),
                      _MeasurementHead(label: 'Yağ %'),
                      _MeasurementHead(label: 'Kas kütlesi'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (var i = 0; i < rows.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(
                              formatDate(rows[i].date),
                              style: text.bodyMedium?.copyWith(
                                color: palette.textSecondary,
                              ),
                            ),
                          ),
                          _MeasurementCell(
                            value: '${formatDecimal(rows[i].waistCm)} cm',
                            change: _delta(rows, i, (m) => m.waistCm),
                          ),
                          _MeasurementCell(
                            value: '${formatDecimal(rows[i].hipCm)} cm',
                            change: _delta(rows, i, (m) => m.hipCm),
                          ),
                          _MeasurementCell(
                            value: formatDecimal(rows[i].waistHipRatio, 2),
                            change: null,
                          ),
                          _MeasurementCell(
                            value: '${formatDecimal(rows[i].bodyFatPct)} %',
                            change: _delta(rows, i, (m) => m.bodyFatPct),
                          ),
                          _MeasurementCell(
                            value: '${formatDecimal(rows[i].muscleMassKg)} kg',
                            change: _delta(rows, i, (m) => m.muscleMassKg),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.md),
            const InterviewNote(
              'Bu dört ölçüm bizim tahminimiz ve yağ / kas değerleri bir '
              'biyoelektrik impedans cihazı varsayıyor. Siz hangilerini, '
              'hangi cihazla, ne sıklıkla alıyorsunuz? Yağsız vücut kütlesini '
              'ölçüyorsanız enerji hesabında Cunningham formülünü '
              'kullanabiliriz.',
            ),
          ],
        ),
      ),
    );
  }

  /// Change against the session before this one. Rows are newest-first, so the
  /// previous session is the *next* index.
  static double? _delta(
    List<BodyMeasurement> rows,
    int i,
    double Function(BodyMeasurement) read,
  ) => i + 1 < rows.length ? read(rows[i]) - read(rows[i + 1]) : null;
}

class _MeasurementHead extends StatelessWidget {
  const _MeasurementHead({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Text(
      label,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: context.palette.textSecondary),
    ),
  );
}

/// One reading, right-aligned so the column's numbers line up, with the change
/// since the last session under it, small and grey.
class _MeasurementCell extends StatelessWidget {
  const _MeasurementCell({required this.value, required this.change});

  final String value;
  final double? change;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value, style: text.bodyMedium),
          if (change != null && change != 0)
            Text(
              '${change! > 0 ? '+' : '−'}${formatDecimal(change!.abs())}',
              style: text.bodySmall?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Deliberately not a green tick: the verdict depends on the client's own
/// hedef kilo, and for a maintenance goal a loss is not good news.
class _ProgressLabel extends StatelessWidget {
  const _ProgressLabel({required this.client, required this.entries});

  final DemoClient client;
  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    final progress = weightProgress(client, entries);
    final color = switch (progress.verdict) {
      ProgressVerdict.onTrack => context.palette.accent,
      ProgressVerdict.offTrack => palette.warning,
      ProgressVerdict.neutral => palette.textSecondary,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          progress.isLoss ? AppIcons.arrowDown : AppIcons.arrowUp,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${formatDecimal(progress.deltaKg.abs())} kg',
          style: text.titleMedium?.copyWith(color: color),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            progress.remainingKg == null
                ? progress.label
                : '${progress.label} · hedefe '
                      '${formatDecimal(progress.remainingKg!.abs())} kg',
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// The derivation behind the plan's calorie target, shown as a chain rather
/// than a result: a dietitian who disagrees needs to see which step is wrong.
class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.client});

  final DemoClient client;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final bmh = basalMetabolicRate(client);
    final factor = activityFactor(client.activityLevel);

    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enerji ihtiyacı', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Yaş, cinsiyet, boy ve kilodan hesaplanıyor; bu bilgiler '
              'değiştiğinde kendiliğinden güncellenir.',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Three facts on the same grid as the client's, the operators in
            // front of the values: loose "×" and "=" between them fell apart
            // on a phone.
            _FactGrid(
              children: [
                _Fact(label: 'BMH', value: '${bmh.round()} kcal'),
                _Fact(
                  label: 'Aktivite katsayısı',
                  value: '× ${formatDecimal(factor)}',
                ),
                _Fact(
                  label: 'Günlük hedef',
                  value: '= ${targetEnergy(client)} kcal',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const InterviewNote(
              'BMH için Harris-Benedict formülü kullanıldı. Cunningham '
              'formülü yağsız vücut kütlesi istiyor; onu ölçmüyoruz. Siz '
              'hangi formülü kullanıyorsunuz, biyoelektrik impedans '
              'ölçüyor musunuz?',
            ),
          ],
        ),
      ),
    );
  }
}

/// An empty value: a dash, read aloud as "Girilmemiş" by [_Fact].
const _empty = '—';

String _listOrDash(List<String> values) =>
    values.isEmpty ? _empty : values.join(', ');

String _sexLabel(Sex sex) => switch (sex) {
  Sex.kadin => 'Kadın',
  Sex.erkek => 'Erkek',
};

String _activityLabel(ActivityLevel level) => switch (level) {
  ActivityLevel.sedanter => 'Hareketsiz',
  ActivityLevel.hafifAktif => 'Az hareketli',
  ActivityLevel.ortaAktif => 'Orta hareketli',
  ActivityLevel.aktif => 'Hareketli',
  ActivityLevel.cokAktif => 'Çok hareketli',
};

/// Label above, value under it: quiet label, regular value; an empty value is
/// a muted dash.
class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final empty = value == _empty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          semanticsLabel: empty ? 'Girilmemiş' : null,
          style: empty
              ? text.bodyLarge?.copyWith(color: palette.textSecondary)
              : text.bodyLarge,
        ),
      ],
    );
  }
}

/// Facts in equal columns that use the card's width: one or two on a phone
/// (by its width and text size), up to four on a computer, so every group shares its column edges and the card
/// has no empty right half.
class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.children});

  final List<Widget> children;

  static const _gap = AppSpacing.lg;
  static const _minColumn = 150.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final room = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 600.0;
        // The gaps count: n columns need n * min + (n - 1) * gap.
        final columns = ((room + _gap) / (_minColumn * scale + _gap))
            .floor()
            .clamp(1, 4);
        final width = (room - _gap * (columns - 1)) / columns;
        return Wrap(
          spacing: _gap,
          runSpacing: AppSpacing.lg,
          children: [
            for (final c in children) SizedBox(width: width, child: c),
          ],
        );
      },
    );
  }
}

/// A table that needs [minWidth] to read: full width when there is room,
/// sideways scrolling when there is not.
class _WideTable extends StatelessWidget {
  const _WideTable({required this.minWidth, required this.children});

  final double minWidth;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
        if (constraints.maxWidth >= minWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: table),
        );
      },
    );
  }
}
