import 'package:flutter/material.dart';

import '../demo/demo_models.dart';
import 'tone_pill.dart';

/// State is never carried by color alone: every pill has a label.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.state});

  final PlanState state;

  @override
  Widget build(BuildContext context) {
    return state == PlanState.aiDraft
        ? const TonePill(
            label: 'Taslak · onay bekliyor',
            tone: PillTone.aiDraft,
          )
        : const TonePill(label: 'Onaylı', tone: PillTone.approved);
  }
}
