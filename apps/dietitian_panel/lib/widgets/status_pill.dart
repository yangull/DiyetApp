import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../demo/demo_models.dart';

/// State is never carried by color alone: every pill has a label.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.state});

  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final draft = state == PlanState.aiDraft;
    final color = draft ? context.palette.aiDraft : AppColors.primary;
    final label = draft ? 'Taslak · onay bekliyor' : 'Onaylı';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
