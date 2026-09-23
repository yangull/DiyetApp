import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/adaptive_nav_scaffold.dart';

import 'real_overview_screen.dart';
import 'real_profile_screen.dart';

/// The approved dietitian's actual shell (PLANNING.md §2.3 #53): only two
/// destinations (a rail on wide screens, a bottom bar on phones, #38) for now, Genel Bakış and Profil. The client list lives
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
    return AdaptiveNavScaffold(
      selectedIndex: _index,
      onSelected: (i) => setState(() => _index = i),
      destinations: const [
        PanelDestination(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Genel Bakış',
        ),
        PanelDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'Profil',
        ),
      ],
      body: IndexedStack(
        index: _index,
        children: [
          RealOverviewScreen(profile: widget.identity.profile),
          RealProfileScreen(identity: widget.identity, actions: widget.actions),
        ],
      ),
    );
  }
}
