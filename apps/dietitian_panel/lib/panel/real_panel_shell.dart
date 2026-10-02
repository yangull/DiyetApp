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

/// Where the rail's icons start, so the mark and the name line up with them.
const _railInset = 28.0;

class _RealPanelShellState extends State<RealPanelShell> {
  int _index = 0;
  final _overviewNavigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AdaptiveNavScaffold(
      extendedRail: true,
      railLeading: const Padding(
        padding: EdgeInsetsDirectional.only(
          start: _railInset,
          top: AppSpacing.lg,
          bottom: AppSpacing.xl,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: WellkitMark(size: 40),
        ),
      ),
      railTrailing: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: _railInset,
            end: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          child: Text(
            widget.identity.profile.fullName,
            style: text.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      selectedIndex: _index,
      onSelected: (i) {
        // Tapping the current tab again returns to its first screen.
        if (i == _index) {
          _overviewNavigator.currentState?.popUntil((r) => r.isFirst);
        }
        setState(() => _index = i);
      },
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
          // A client's record opens inside this tab, so the rail or the bottom
          // bar stays on screen and Profil is one tap away.
          NavigatorPopHandler(
            // Only while this tab is showing: a hidden tab must not eat the
            // system back press.
            enabled: _index == 0,
            onPopWithResult: (_) => _overviewNavigator.currentState?.maybePop(),
            child: Navigator(
              key: _overviewNavigator,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) =>
                    RealOverviewScreen(profile: widget.identity.profile),
              ),
            ),
          ),
          RealProfileScreen(identity: widget.identity, actions: widget.actions),
        ],
      ),
    );
  }
}
