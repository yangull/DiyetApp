import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// The visual treatment reserved for AI-written, not-yet-approved content.
/// Violet appears nowhere else in the app, and the dashed edge means the state
/// survives for anyone who cannot separate the hues.
///
/// Only the notice: the approve action is a button of its own beside it (the
/// side panel) or in the pinned bottom bar (a phone), so a notice and an
/// action are not merged in one box.
class AiDraftBanner extends StatelessWidget {
  const AiDraftBanner({super.key, required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final violet = context.palette.aiDraft;

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: violet, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'Yapay zekâ taslağı · onay bekliyor',
            style: text.bodyMedium?.copyWith(
              color: violet,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return DottedBorderBox(
      color: violet,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            const SizedBox(height: AppSpacing.md),
            Text(
              note,
              style: text.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Danışan bu planı siz onaylayana kadar göremez.',
              style: text.bodySmall?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: context.density.cardRadius,
      ),
      child: Container(
        decoration: BoxDecoration(
          // The measured tint (#EEEBF6), not an unmeasured alpha of violet.
          color: context.palette.aiDraftTint,
          borderRadius: BorderRadius.circular(context.density.cardRadius),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
