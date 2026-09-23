import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../util/breakpoints.dart';

class PanelDestination {
  const PanelDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The panel's frame for both entry points: a labelled rail on wide screens,
/// a bottom bar on phones (PLANNING #38, #53). The bottom bar only navigates;
/// anything that is an action goes in [phoneTopActions] instead.
class AdaptiveNavScaffold extends StatelessWidget {
  const AdaptiveNavScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.railTrailing,
    this.phoneTopActions,
  });

  final List<PanelDestination> destinations;

  /// Null when the body shows something that is not a destination (the
  /// demo's settings on wide screens): no destination is highlighted.
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget body;

  /// Wide screens only: pinned to the bottom of the rail.
  final Widget? railTrailing;

  /// Phones only: a slim strip above the body for labelled actions that have
  /// no place in a navigation bar.
  final List<Widget>? phoneTopActions;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (isPanelPhone(context)) {
      final actions = phoneTopActions;
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (actions != null && actions.isNotEmpty)
                Container(
                  color: palette.surfaceSubtle,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
              Expanded(child: body),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex ?? 0,
          onDestinationSelected: onSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor: palette.surfaceSubtle,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
              trailing: railTrailing,
            ),
            VerticalDivider(width: 1, color: palette.borderSubtle),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
