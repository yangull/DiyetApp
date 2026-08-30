import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'real_overview_screen.dart';
import 'real_profile_screen.dart';

/// The approved dietitian's actual shell (PLANNING.md §2.3 #53): only two
/// rail destinations for now, Genel Bakış and Profil. The client list lives
/// inside Genel Bakış, and a client's detail screen is pushed over the shell
/// rather than given its own destination — no destinations are pre-added for
/// features that don't exist yet.
///
/// This is deliberately not `PanelShell` (`lib/panel_shell.dart`), which is
/// the five-destination interview demo running on fake data. Conflating the
/// two would let fake data leak into what a real dietitian sees.
class RealPanelShell extends StatefulWidget {
  const RealPanelShell({
    super.key,
    required this.identity,
    required this.actions,
  });

  final AuthedIdentity identity;
  final AuthGateActions actions;

  @override
  State<RealPanelShell> createState() => _RealPanelShellState();
}

class _RealPanelShellState extends State<RealPanelShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            backgroundColor: palette.surfaceSubtle,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Genel Bakış'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profil'),
              ),
            ],
          ),
          VerticalDivider(width: 1, color: palette.borderSubtle),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                RealOverviewScreen(profile: widget.identity.profile),
                RealProfileScreen(
                  identity: widget.identity,
                  actions: widget.actions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
