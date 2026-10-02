import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../util/breakpoints.dart';

const _extendedRailWidth = 220.0;

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
    this.railLeading,
    this.extendedRail = false,
    this.phoneTopActions,
  });

  final List<PanelDestination> destinations;

  /// Null when the body shows something that is not a destination (the
  /// demo's settings on wide screens): no destination is highlighted.
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget body;

  /// Wide screens only: pinned to the bottom of the rail. An extended rail
  /// gives it the rail's width and the free height, so align inside it.
  final Widget? railTrailing;

  /// Wide screens only: pinned to the top of the rail, above the entries.
  final Widget? railLeading;

  /// Wide screens only: labels beside the icons in a wider rail, instead of
  /// the rail's stacked captions under them.
  final bool extendedRail;

  /// Phones only: a row above the body for labelled actions that have
  /// no place in a navigation bar.
  final List<Widget>? phoneTopActions;

  @override
  Widget build(BuildContext context) {
    if (isPanelPhone(context)) {
      final actions = phoneTopActions;
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // On the canvas, not a band of its own: a strip holding one
              // button read as a second app bar.
              if (actions != null && actions.isNotEmpty)
                Padding(
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
        bottomNavigationBar: FloatingNavBar(
          child: NavigationBar(
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
        ),
      );
    }

    // The rail centres its leading and trailing widgets in its own width, so
    // an extended rail gives them that width to align inside.
    final railWidth =
        _extendedRailWidth *
        math.min(MediaQuery.textScalerOf(context).scale(1), 1.6);
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              extended: extendedRail,
              minExtendedWidth: railWidth,
              labelType: extendedRail
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: extendedRail && railLeading != null
                  ? SizedBox(width: railWidth, child: railLeading)
                  : railLeading,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
              trailing: extendedRail && railTrailing != null
                  ? Expanded(
                      child: SizedBox(width: railWidth, child: railTrailing),
                    )
                  : railTrailing,
            ),
            // The rail and the page are both white: a hairline separates them.
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
