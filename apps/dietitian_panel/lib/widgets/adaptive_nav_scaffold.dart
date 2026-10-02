import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../util/breakpoints.dart';

const _extendedRailWidth = 220.0;
const _extendedRailMinWindow = 900.0;

/// Where an extended rail's icons start, so the mark and anything pinned to
/// the rail line up with them.
const kRailInset = 28.0;

/// The brand mark at the top of an extended rail.
class RailMark extends StatelessWidget {
  const RailMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.only(
        start: kRailInset,
        top: AppSpacing.lg,
        bottom: AppSpacing.xl,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: WellkitMark(size: 40),
      ),
    );
  }
}

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
/// a screen that needs an action there puts it in its own header.
class AdaptiveNavScaffold extends StatelessWidget {
  const AdaptiveNavScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.railTrailing,
    this.railLeading,
    this.compactRailTrailing,
    this.extendedRail = false,
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

  /// What the narrow (not extended) rail shows at its foot instead of
  /// [railTrailing]; null leaves it empty. Give it an [Expanded] to pin it to
  /// the bottom.
  final Widget? compactRailTrailing;

  /// Wide screens only: pinned to the top of the rail, above the entries.
  final Widget? railLeading;

  /// Wide windows only (from [_extendedRailMinWindow]): labels beside the
  /// icons in a wider rail, instead of the rail's stacked captions under them.
  final bool extendedRail;

  @override
  Widget build(BuildContext context) {
    if (isPanelPhone(context)) {
      return Scaffold(
        body: SafeArea(bottom: false, child: body),
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

    // The extended rail needs room: on a tablet or a narrow window the page
    // would lose a third of its width, so it keeps the compact rail there,
    // with its own (smaller) trailing widget.
    final extended =
        extendedRail &&
        MediaQuery.sizeOf(context).width >= _extendedRailMinWindow;
    // The rail centres its leading and trailing widgets in its own width, so
    // an extended rail gives them that width to align inside. It grows with
    // the text, as the labels do.
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
              extended: extended,
              minExtendedWidth: railWidth,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: extended && railLeading != null
                  ? SizedBox(width: railWidth, child: railLeading)
                  : null,
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
              trailing: extended
                  ? (railTrailing == null
                        ? null
                        : Expanded(
                            child: SizedBox(
                              width: railWidth,
                              child: railTrailing,
                            ),
                          ))
                  : compactRailTrailing,
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
