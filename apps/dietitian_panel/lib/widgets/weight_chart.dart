import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../demo/demo_models.dart';
import '../util/panel_date.dart';

/// One series, so no legend: the title names it. Recessive grid, 2px line,
/// emphasised endpoint with a direct label — no number on every point.
///
/// [targetKg] draws the hedef kilo as a dashed line, which also fixes what the
/// scale used to imply: without it, every chart filled its own height and a
/// client holding steady looked identical to one dropping fast.
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.entries, this.targetKg});

  final List<WeightEntry> entries;
  final double? targetKg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: CustomPaint(
        painter: _WeightPainter(
          entries: entries,
          targetKg: targetKg,
          line: AppColors.accent,
          grid: context.palette.divider,
          target: context.palette.textSecondary,
          surface: context.palette.cloudCard,
          labelStyle: Theme.of(context).textTheme.bodySmall!
              .copyWith(color: context.palette.textSecondary),
          valueStyle: Theme.of(context).textTheme.titleMedium!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Steps a person reads without doing arithmetic. The old axis divided the
/// raw min–max range into thirds, which produced ticks like 79 / 77 / 74 / 71
/// — uneven spacing that makes the slope between them lie.
const _niceSteps = [0.5, 1.0, 2.0, 2.5, 5.0, 10.0, 20.0];

class _WeightPainter extends CustomPainter {
  _WeightPainter({
    required this.entries,
    required this.targetKg,
    required this.line,
    required this.grid,
    required this.target,
    required this.surface,
    required this.labelStyle,
    required this.valueStyle,
  });

  final List<WeightEntry> entries;
  final double? targetKg;
  final Color line;
  final Color grid;
  final Color target;
  final Color surface;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    const leftPad = 44.0;
    const rightPad = 56.0;
    const topPad = 14.0;
    const bottomPad = 24.0;

    final kgs = entries.map((e) => e.kg).toList();
    var lo = kgs.reduce((a, b) => a < b ? a : b);
    var hi = kgs.reduce((a, b) => a > b ? a : b);
    // The target only widens the axis, never narrows it: a goal far below the
    // current weight should be visible, not clipped off the bottom.
    if (targetKg != null) {
      lo = lo < targetKg! ? lo : targetKg!;
      hi = hi > targetKg! ? hi : targetKg!;
    }

    final step = _niceSteps.firstWhere(
      (s) => (hi - lo) / s <= 4,
      orElse: () => _niceSteps.last,
    );
    final minKg = (lo / step).floorToDouble() * step;
    final maxKg = (hi / step).ceilToDouble() * step;
    final divisions = ((maxKg - minKg) / step).round().clamp(1, 8);

    final plotW = size.width - leftPad - rightPad;
    final plotH = size.height - topPad - bottomPad;

    double yFor(double kg) =>
        topPad + plotH * (1 - (kg - minKg) / (maxKg - minKg));
    // Spaced by date, not by index: a weigh-in three weeks after the last one
    // must sit three weeks away, or the gap vanishes and the slope lies.
    final start = entries.first.date;
    final span = entries.last.date.difference(start).inMinutes;
    double xFor(DateTime date) => span == 0
        ? leftPad + plotW
        : leftPad + plotW * date.difference(start).inMinutes / span;
    Offset pointAt(int i) => Offset(xFor(entries[i].date), yFor(kgs[i]));

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= divisions; i++) {
      final kg = maxKg - step * i;
      final y = yFor(kg);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + plotW, y),
        gridPaint,
      );
      _text(
        canvas,
        step < 1 ? formatDecimal(kg) : formatDecimal(kg, 0),
        Offset(0, y - 7),
        labelStyle,
      );
    }

    final last = pointAt(entries.length - 1);
    final valueTop = last.dy - 10;
    final valueHeight = _measure('${formatDecimal(kgs.last)} kg', valueStyle);

    if (targetKg != null) {
      final y = yFor(targetKg!);
      final dash = Paint()
        ..color = target
        ..strokeWidth = 1.5;
      for (var x = leftPad; x < leftPad + plotW; x += 8) {
        final end = (x + 4).clamp(leftPad, leftPad + plotW);
        canvas.drawLine(Offset(x, y), Offset(end, y), dash);
      }
      _text(
        canvas,
        'hedef',
        Offset(
          leftPad + plotW + 6,
          targetLabelTop(
            targetY: y,
            labelHeight: _measure('hedef', labelStyle),
            valueTop: valueTop,
            valueHeight: valueHeight,
          ),
        ),
        labelStyle,
      );
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < entries.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(last, 6, Paint()..color = surface);
    canvas.drawCircle(last, 4.5, Paint()..color = line);
    _text(
      canvas,
      '${formatDecimal(kgs.last)} kg',
      Offset(last.dx + 10, valueTop),
      valueStyle,
    );

    // Read off the data rather than hard-coded, so the axis cannot go stale.
    _text(
      canvas,
      formatDayMonthShort(entries.first.date),
      Offset(leftPad, size.height - 16),
      labelStyle,
    );
    _text(
      canvas,
      formatDayMonthShort(entries.last.date),
      Offset(leftPad + plotW, size.height - 16),
      labelStyle,
      alignRight: true,
    );
  }

  double _measure(String value, TextStyle style) => (TextPainter(
    text: TextSpan(text: value, style: style),
    textDirection: TextDirection.ltr,
  )..layout()).height;

  void _text(
    Canvas canvas,
    String value,
    Offset at,
    TextStyle style, {
    bool alignRight = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, alignRight ? at.translate(-tp.width, 0) : at);
  }

  @override
  bool shouldRepaint(_WeightPainter old) =>
      old.entries != entries || old.targetKg != targetKg;
}

/// Where the "hedef" label goes: centred on the target line, unless the last
/// weight's label is there (a weight close to its target, like 58,2 over
/// 58,0). Then it takes the nearest spot that clears that label.
@visibleForTesting
double targetLabelTop({
  required double targetY,
  required double labelHeight,
  required double valueTop,
  required double valueHeight,
}) {
  bool clear(double top) =>
      top >= valueTop + valueHeight || top + labelHeight <= valueTop;
  final onLine = targetY - labelHeight / 2;
  // Nearest to the line first: on it, just below or above it, then clear of
  // the value label altogether.
  final candidates = [
    onLine,
    targetY + 3,
    targetY - labelHeight - 3,
    valueTop + valueHeight + 2,
    valueTop - labelHeight - 2,
  ]..sort((a, b) => (a - onLine).abs().compareTo((b - onLine).abs()));
  return candidates.firstWhere(clear, orElse: () => onLine);
}
