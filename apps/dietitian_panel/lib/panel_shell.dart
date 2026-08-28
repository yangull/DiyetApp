import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo/demo_repository.dart';
import 'screens/appointments_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/payments_screen.dart';
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
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: Text('Mesajlar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: Text('Ödemeler'),
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
            trailing: const Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _ResetDemoButton(),
                ),
              ),
            ),
          ),
          VerticalDivider(width: 1, color: palette.borderSubtle),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                OverviewScreen(onOpenClients: () => setState(() => _index = 1)),
                const ClientsScreen(),
                const AppointmentsScreen(),
                const MessagesScreen(),
                const PaymentsScreen(),
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

/// Between interviews the panel has to go back to a known state. Everything a
/// dietitian typed is kept until this is pressed.
class _ResetDemoButton extends ConsumerWidget {
  const _ResetDemoButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Demoyu sıfırla',
      icon: Icon(Icons.restart_alt, color: context.palette.textMuted),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Demoyu sıfırla'),
            content: const Text(
              'Bu görüşmede yapılan tüm değişiklikler silinir ve '
              'başlangıç verileri geri gelir.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sıfırla'),
              ),
            ],
          ),
        );
        if (confirmed ?? false) ref.read(demoProvider.notifier).resetDemo();
      },
    );
  }
}
