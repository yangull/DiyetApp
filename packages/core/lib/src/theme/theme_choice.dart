import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// Light, dark or the phone's setting (Can, 1 Oct 2026, was C43). Follows
/// the system until the user picks; the pick is saved on the device, not in
/// the account.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'wellkit.themeMode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = ThemeMode.values.asNameMap()[prefs.getString(_key)];
      if (saved != null && ref.mounted) state = saved;
    } catch (_) {
      // No storage (a test, a blocked browser): keep following the system.
    }
  }

  Future<void> choose(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // The choice still applies for this session.
    }
  }
}

/// The three-way choice for a settings screen: "Sistem", "Açık", "Koyu".
class ThemeChoiceSelector extends ConsumerWidget {
  const ThemeChoiceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    // The control grows with the text, not only its words, and never gets
    // smaller than 40: on a roomy settings page the compact 32 looked tiny.
    final height = math.max(
      40.0,
      MediaQuery.textScalerOf(context).scale(context.density.controlHeight),
    );
    // Fills the width it is given, up to a cap, instead of hugging its words.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SegmentedButton<ThemeMode>(
          expandedInsets: EdgeInsets.zero,
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(48, height)),
          ),
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
            ButtonSegment(value: ThemeMode.light, label: Text('Açık')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Koyu')),
          ],
          selected: {mode},
          onSelectionChanged: (choice) =>
              ref.read(themeModeProvider.notifier).choose(choice.single),
        ),
      ),
    );
  }
}
