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
import 'widgets/adaptive_nav_scaffold.dart';

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
    void reset() => setState(() {
      _session++;
      _index = 0;
    });

    return AdaptiveNavScaffold(
      selectedIndex: _index == _settingsIndex ? null : _index,
      onSelected: (i) => setState(() => _index = i),
      destinations: const [
        PanelDestination(
          icon: AppIcons.dashboard,
          selectedIcon: AppIcons.dashboardActive,
          label: 'Genel Bakış',
        ),
        PanelDestination(
          icon: AppIcons.clients,
          selectedIcon: AppIcons.clientsActive,
          label: 'Danışanlar',
        ),
        PanelDestination(
          icon: AppIcons.appointments,
          selectedIcon: AppIcons.appointmentsActive,
          label: 'Randevular',
        ),
        PanelDestination(
          icon: AppIcons.messages,
          selectedIcon: AppIcons.messagesActive,
          label: 'Mesajlar',
        ),
        if (kShowMoney)
          PanelDestination(
            icon: AppIcons.payments,
            selectedIcon: AppIcons.paymentsActive,
            label: 'Ödemeler',
          ),
        PanelDestination(
          icon: AppIcons.progress,
          selectedIcon: AppIcons.progressActive,
          label: 'Takip',
        ),
      ],
      extendedRail: true,
      railLeading: const RailMark(),
      compactRailTrailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RailUtilityButton(
                  icon: AppIcons.notifications,
                  label: 'Hatırlatma ayarları',
                  selected: _index == _settingsIndex,
                  onPressed: () => setState(() => _index = _settingsIndex),
                  stacked: true,
                ),
                const SizedBox(height: AppSpacing.md),
                _ResetDemoButton(onReset: reset, stacked: true),
              ],
            ),
          ),
        ),
      ),
      railTrailing: Align(
        alignment: AlignmentDirectional.bottomStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: kRailInset - AppSpacing.md,
            end: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RailUtilityButton(
                icon: AppIcons.notifications,
                label: 'Hatırlatma ayarları',
                selected: _index == _settingsIndex,
                onPressed: () => setState(() => _index = _settingsIndex),
              ),
              _ResetDemoButton(onReset: reset),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        key: ValueKey(_session),
        // On a phone, settings are a pushed page, never a stack index.
        index: _index,
        children: [
          OverviewScreen(
            onOpenClients: () => setState(() => _index = 1),
            onOpenAppointments: () => setState(() => _index = 2),
            onOpenMessages: () => setState(() => _index = 3),
            // A bottom bar only navigates, so on phones the demo's two
            // utilities sit behind one labelled button in this screen's header.
            onOpenDemoMenu: () => _showDemoSheet(context, onReset: reset),
          ),
          const ClientsScreen(),
          const AppointmentsScreen(),
          const MessagesScreen(),
          if (kShowMoney) const PaymentsScreen(),
          const ReportsScreen(),
          const SettingsScreen(),
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
    this.stacked = false,
  });

  /// Icon over label in a narrow rail, instead of a row.
  final bool stacked;

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Like a rail destination: black and 600 when selected, grey otherwise.
    final color = selected
        ? context.palette.ink
        : context.palette.textSecondary;
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(fontWeight: selected ? FontWeight.w600 : null);
    if (stacked) {
      return TextButton(
        style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(color)),
        onPressed: onPressed,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: AppSpacing.xs),
              Text(label, textAlign: TextAlign.center, style: style),
            ],
          ),
        ),
      );
    }
    return TextButton.icon(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(color),
        alignment: AlignmentDirectional.centerStart,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: style),
    );
  }
}

/// Between interviews the panel has to go back to a known state. Everything a
/// dietitian typed is kept until this is pressed. Icon and label, like the
/// rail items above it: an icon alone would be a guess (docs/design-system.md,
/// rule 12).
class _ResetDemoButton extends ConsumerWidget {
  const _ResetDemoButton({required this.onReset, this.stacked = false});

  final VoidCallback onReset;
  final bool stacked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = context.palette.textSecondary;
    final label = Theme.of(context).textTheme.labelMedium;
    if (stacked) {
      return TextButton(
        style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(muted)),
        onPressed: () => _confirmReset(context, ref, onReset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.reset),
            const SizedBox(height: AppSpacing.xs),
            Text('Sıfırla', style: label),
          ],
        ),
      );
    }
    return TextButton.icon(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(muted),
        alignment: AlignmentDirectional.centerStart,
      ),
      onPressed: () => _confirmReset(context, ref, onReset),
      icon: const Icon(AppIcons.reset),
      label: Text('Sıfırla', style: label),
    );
  }
}

Future<void> _confirmReset(
  BuildContext context,
  WidgetRef ref,
  VoidCallback onReset,
) async {
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
          style: AppTheme.destructive(context),
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
}

/// The phone version of the rail's foot: reminder settings as a page, and the
/// demo reset behind its usual confirmation.
void _showDemoSheet(BuildContext context, {required VoidCallback onReset}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Consumer(
      builder: (sheetContext, ref, _) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(AppIcons.notifications),
              title: const Text('Hatırlatma ayarları'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      // The page's own heading names it; a title here too
                      // said it twice.
                      appBar: AppBar(),
                      body: const SettingsScreen(),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.reset),
              title: const Text('Demoyu sıfırla'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmReset(context, ref, onReset);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
