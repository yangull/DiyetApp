import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../demo/demo_models.dart';

/// One series, so no legend: the title names it. Recessive grid, 2px line,
/// emphasised endpoint with a direct label — no number on every point.
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.entries});

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: CustomPaint(
        painter: _WeightPainter(
          entries: entries,
          line: AppColors.primary,
          grid: context.palette.borderSubtle,
          label: context.palette.textMuted,
          surface: AppColors.surface,
          labelStyle: Theme.of(context).textTheme.bodySmall!
              .copyWith(color: context.palette.textMuted),
          valueStyle: Theme.of(context).textTheme.titleMedium!
              .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WeightPainter extends CustomPainter {
  _WeightPainter({
    required this.entries,
    required this.line,
    required this.grid,
    required this.label,
    required this.surface,
    required this.labelStyle,
    required this.valueStyle,
  });

  final List<WeightEntry> entries;
  final Color line;
  final Color grid;
  final Color label;
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
    final minKg = kgs.reduce((a, b) => a < b ? a : b) - 1;
    final maxKg = kgs.reduce((a, b) => a > b ? a : b) + 1;
    final plotW = size.width - leftPad - rightPad;
    final plotH = size.height - topPad - bottomPad;

    Offset pointAt(int i) {
      final x = leftPad + plotW * (i / (entries.length - 1));
      final y = topPad + plotH * (1 - (kgs[i] - minKg) / (maxKg - minKg));
      return Offset(x, y);
    }

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = topPad + plotH * (i / 3);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + plotW, y),
        gridPaint,
      );
      _text(
        canvas,
        (maxKg - (maxKg - minKg) * (i / 3)).toStringAsFixed(0),
        Offset(0, y - 7),
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

    final last = pointAt(entries.length - 1);
    canvas.drawCircle(last, 6, Paint()..color = surface);
    canvas.drawCircle(last, 4.5, Paint()..color = line);
    _text(
      canvas,
      '${kgs.last.toStringAsFixed(1)} kg',
      Offset(last.dx + 10, last.dy - 10),
      valueStyle,
    );

    _text(canvas, 'Haz', Offset(leftPad, size.height - 16), labelStyle);
    _text(
      canvas,
      'Ağu',
      Offset(leftPad + plotW - 20, size.height - 16),
      labelStyle,
    );
  }

  void _text(Canvas canvas, String value, Offset at, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(_WeightPainter old) => old.entries != entries;
}
