import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'profile_tab.dart';
import 'today_tab.dart';

/// The client app's home (PLANNING #51, redesigned as "Sıcak", #131): two
/// tabs, Bugün and Profil. More tabs arrive when their features ship for
/// everyone, not per user (design-system "Redesign Sıcak").
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({
    super.key,
    required this.identity,
    required this.actions,
  });

  final AuthedIdentity identity;
  final AuthGateActions actions;

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bugün's green hero runs under the status bar; Profil keeps the inset.
      body: _tab == 0
          ? TodayTab(identity: widget.identity)
          // Bugün sets light status-bar icons for its green hero; Profil sits
          // on the light ground and has to set them back to dark.
          : AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: SafeArea(
                child: ProfileTab(
                  identity: widget.identity,
                  actions: widget.actions,
                ),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Bugün',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
