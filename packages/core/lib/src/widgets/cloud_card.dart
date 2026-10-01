import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A card in Bevel's style (PLANNING #135): Cloud Card, no border, no shadow,
/// radius from the density. It re-themes its contents with [onCloudCard], so a
/// secondary pill, a progress track or a neutral pill inside it turns white
/// instead of vanishing into the card. Use it instead of a bare [Card].
class CloudCard extends StatelessWidget {
  const CloudCard({super.key, required this.child, this.clipBehavior});

  final Widget child;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: clipBehavior,
      child: Theme(data: onCloudCard(theme), child: child),
    );
  }
}
