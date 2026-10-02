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
    // Taller as the labels grow, so the line keeps its room at large text.
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      height: 170 + 40 * (scale - 1).clamp(0, 2),
      child: CustomPaint(
        painter: _WeightPainter(
          entries: entries,
          targetKg: targetKg,
          line: context.palette.accent,
          grid: context.palette.divider,
          target: context.palette.textSecondary,
          surface: context.palette.cloudCard,
          labelStyle: Theme.of(context).textTheme.bodySmall!
              .copyWith(color: context.palette.textSecondary),
          valueStyle: Theme.of(context).textTheme.titleMedium!
              .copyWith(fontWeight: FontWeight.w600),
          // The labels grow with the system text size like any other text.
          textScaler: MediaQuery.textScalerOf(context),
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
    required this.textScaler,
  });

  final List<WeightEntry> entries;
  final double? targetKg;
  final Color line;
  final Color grid;
  final Color target;
  final Color surface;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    // The date labels sit under the plot and the end value's label is
    // centred on its point, so both margins grow with the text.
    final dateHeight = _size('00 Eyl', labelStyle).height;
    final topPad = _size('0', valueStyle).height / 2 + 2;
    final bottomPad = dateHeight + 6;

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

    String tick(double kg) =>
        step < 1 ? formatDecimal(kg) : formatDecimal(kg, 0);
    // The axis is as wide as its widest label and the right margin as wide as
    // the end value or the target label, so neither is cut off or crowded.
    var tickWidth = 0.0;
    for (var i = 0; i <= divisions; i++) {
      final w = _size(tick(maxKg - step * i), labelStyle).width;
      if (w > tickWidth) tickWidth = w;
    }
    final leftPad = tickWidth + 8;
    final valueLabel = '${formatDecimal(kgs.last)} kg';
    final targetLabel = targetKg == null
        ? null
        : 'hedef ${formatDecimal(targetKg!)} kg';
    final valueSize = _size(valueLabel, valueStyle);
    final targetSize = targetLabel == null
        ? null
        : _size(targetLabel, labelStyle);
    final rightPad =
        10 +
        (targetSize != null && targetSize.width > valueSize.width
            ? targetSize.width
            : valueSize.width) +
        2;

    final plotW = size.width - leftPad - rightPad;
    // Large text in a narrow card can leave no room for the line at all.
    if (plotW <= 0) return;
    final plotH = size.height - topPad - bottomPad;
    if (plotH <= 0) return;

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
      final label = tick(kg);
      final labelSize = _size(label, labelStyle);
      _text(
        canvas,
        label,
        Offset(tickWidth, y - labelSize.height / 2),
        labelStyle,
        alignRight: true,
      );
    }

    final last = pointAt(entries.length - 1);
    final valueTop = last.dy - valueSize.height / 2;
    final valueHeight = valueSize.height;

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
        targetLabel!,
        Offset(
          leftPad + plotW + 10,
          targetLabelTop(
            targetY: y,
            labelHeight: targetSize!.height,
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
    _text(canvas, valueLabel, Offset(last.dx + 10, valueTop), valueStyle);

    // Read off the data rather than hard-coded, so the axis cannot go stale.
    _text(
      canvas,
      formatDate(entries.first.date),
      Offset(leftPad, size.height - dateHeight),
      labelStyle,
    );
    _text(
      canvas,
      formatDate(entries.last.date),
      Offset(leftPad + plotW, size.height - dateHeight),
      labelStyle,
      alignRight: true,
    );
  }

  Size _size(String value, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    final size = tp.size;
    tp.dispose();
    return size;
  }

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
      textScaler: textScaler,
    )..layout();
    tp.paint(canvas, alignRight ? at.translate(-tp.width, 0) : at);
  }

  @override
  bool shouldRepaint(_WeightPainter old) =>
      old.entries != entries ||
      old.targetKg != targetKg ||
      old.textScaler != textScaler ||
      old.labelStyle != labelStyle ||
      old.valueStyle != valueStyle ||
      old.line != line ||
      old.grid != grid ||
      old.target != target ||
      old.surface != surface;
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
