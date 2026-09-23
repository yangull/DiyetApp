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

  /// Bumped by "Sıfırla". The screens hold state of their own (filters,
  /// message drafts, the selected goal) that resetting the repository does not
  /// reach, so a reset remounts them: a fresh interview starts from nothing.
  int _session = 0;

  /// Settings sit after the rail's destinations in the stack, but not on the
  /// rail itself: they are configuration, not a daily work screen.
  static const _settingsIndex = kShowMoney ? 6 : 5;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index == _settingsIndex ? null : _index,
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
              if (kShowMoney)
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
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RailUtilityButton(
                        icon: Icons.notifications_none,
                        label: 'Hatırlatma ayarları',
                        selected: _index == _settingsIndex,
                        onPressed: () =>
                            setState(() => _index = _settingsIndex),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ResetDemoButton(
                        onReset: () => setState(() {
                          _session++;
                          _index = 0;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(width: 1, color: palette.borderSubtle),
          Expanded(
            child: IndexedStack(
              key: ValueKey(_session),
              index: _index,
              children: [
                OverviewScreen(
                  onOpenClients: () => setState(() => _index = 1),
                  onOpenAppointments: () => setState(() => _index = 2),
                  onOpenMessages: () => setState(() => _index = 3),
                ),
                const ClientsScreen(),
                const AppointmentsScreen(),
                const MessagesScreen(),
                if (kShowMoney) const PaymentsScreen(),
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

/// A rail-bottom entry for configuration, set apart from the daily screens.
/// Called "Hatırlatmalar" on the rail, it read like a list of reminders to
/// act on and opened switches instead.
class _RailUtilityButton extends StatelessWidget {
  const _RailUtilityButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : context.palette.textSecondary;
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: color),
      onPressed: onPressed,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Between interviews the panel has to go back to a known state. Everything a
/// dietitian typed is kept until this is pressed. Icon and label, like the
/// rail items above it: an icon alone would be a guess (docs/design-system.md,
/// rule 12).
class _ResetDemoButton extends ConsumerWidget {
  const _ResetDemoButton({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = context.palette.textMuted;
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: muted),
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
        if (confirmed ?? false) {
          ref.read(demoProvider.notifier).resetDemo();
          ref.invalidate(selectedConversationProvider);
          onReset();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restart_alt),
          const SizedBox(height: AppSpacing.xs),
          Text('Sıfırla', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
