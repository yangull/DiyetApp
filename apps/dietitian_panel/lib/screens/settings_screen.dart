import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';
import '../widgets/readable_width.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.showHeading = true});

  /// False when the page is pushed with its name in the app bar (a phone), so
  /// the header is one layer, not a bare back arrow over a large heading.
  final bool showHeading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final notifier = ref.read(demoProvider.notifier);
    final r = demo.reminders;
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: readablePadding(
          constraints.maxWidth,
          context.density.pagePadding,
        ),
        children: [
          if (showHeading) ...[
            Text('Hatırlatma ayarları', style: text.headlineLarge),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            'Danışanlarınıza otomatik gönderilecek hatırlatmaları buradan '
            'açıp kapatırsınız.',
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          CloudCard(
            child: Column(
              children: [
                _ReminderSwitch(
                  value: r.dayBefore,
                  onChanged: (v) => notifier.toggleReminder('dayBefore', v),
                  title: 'Randevudan 1 gün önce',
                  subtitle: 'Danışan randevusunu unutmasın diye akşamdan hatırlatılır.',
                ),
                Divider(height: 1, color: palette.divider),
                _ReminderSwitch(
                  value: r.hoursBefore,
                  onChanged: (v) => notifier.toggleReminder('hoursBefore', v),
                  title: 'Randevudan 2 saat önce',
                  subtitle: 'Son dakika iptallerini azaltır.',
                ),
                if (kShowMoney) ...[
                  Divider(height: 1, color: palette.divider),
                  _ReminderSwitch(
                    value: r.paymentReminder,
                    onChanged: (v) => notifier.toggleReminder('payment', v),
                    title: 'Ödenmemiş seans hatırlatması',
                    subtitle: 'Seans sonrası ödeme yapılmadıysa danışana hatırlatılır.',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Push only, no SMS channel to choose: PLANNING.md #127.
          Text(
            'Hatırlatmalar uygulama bildirimi olarak gönderilir; SMS '
            'kullanılmaz.',
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text('Görünüm', style: text.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: ThemeChoiceSelector(),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'Bu ekran görüşme için hazırlanmıştır. Hangi hatırlatmaların işinize '
            'yaradığını, hangilerinin danışanı rahatsız ettiğini sizden '
            'öğrenmek istiyoruz.',
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// A reminder's switch with its state in words beside it, so on and off are
/// not told by the thumb's position alone (rule 10).
class _ReminderSwitch extends StatelessWidget {
  const _ReminderSwitch({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final wordStyle = text.bodyMedium?.copyWith(
      color: context.palette.textSecondary,
    );
    return MergeSemantics(
      // Like SwitchListTile: one focus stop and one role (the switch), so a
      // screen reader says "switch, on" rather than "button, switch".
      child: ListTile(
        internalAddSemanticForOnTap: false,
        onTap: () => onChanged(!value),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The switch already tells a screen reader its state. A slot as
            // wide as "Kapalı", so the title doesn't reflow on each flip.
            ExcludeSemantics(
              child: SizedBox(
                width: numberSlotWidth(context, 'Kapalı', wordStyle!),
                child: Text(
                  value ? 'Açık' : 'Kapalı',
                  textAlign: TextAlign.end,
                  style: wordStyle,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ExcludeFocus(
              child: Switch(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
