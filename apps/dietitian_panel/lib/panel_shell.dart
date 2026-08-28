import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'screens/appointments_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';

class PanelShell extends StatefulWidget {
  const PanelShell({super.key});

  @override
  State<PanelShell> createState() => _PanelShellState();
}

class _PanelShellState extends State<PanelShell> {
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
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Danışanlar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event),
                label: Text('Randevular'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: Text('Takip'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_none),
                selectedIcon: Icon(Icons.notifications),
                label: Text('Hatırlatmalar'),
              ),
            ],
          ),
          VerticalDivider(width: 1, color: palette.borderSubtle),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                OverviewScreen(onOpenClients: () => setState(() => _index = 1)),
                const ClientsScreen(),
                const AppointmentsScreen(),
                const ReportsScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
