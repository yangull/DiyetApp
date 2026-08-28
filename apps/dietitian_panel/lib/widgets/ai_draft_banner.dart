import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// The visual treatment reserved for AI-written, not-yet-approved content.
/// Violet appears nowhere else in the app, and the dashed edge means the state
/// survives for anyone who cannot separate the hues.
class AiDraftBanner extends StatelessWidget {
  const AiDraftBanner({super.key, required this.note, required this.onApprove});

  final String note;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final violet = context.palette.aiDraft;

    return DottedBorderBox(
      color: violet,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: violet,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Yapay zekâ taslağı · onay bekliyor',
                  style: text.bodyMedium?.copyWith(
                    color: violet,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onApprove,
                  child: const Text('Onayla ve danışana gönder'),
                ),
              ],
            ),
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
              style: text.bodySmall?.copyWith(color: context.palette.textMuted),
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
          color: color.withValues(alpha: 0.04),
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
