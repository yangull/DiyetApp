import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';
import '../widgets/readable_width.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
          Text('Hatırlatma ayarları', style: text.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Danışanlarınıza otomatik gönderilecek hatırlatmaları buradan '
            'açıp kapatırsınız.',
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: r.dayBefore,
                  onChanged: (v) => notifier.toggleReminder('dayBefore', v),
                  title: const Text('Randevudan 1 gün önce'),
                  subtitle: const Text(
                    'Danışan randevusunu unutmasın diye akşamdan hatırlatılır.',
                  ),
                ),
                Divider(height: 1, color: palette.borderSubtle),
                SwitchListTile(
                  value: r.hoursBefore,
                  onChanged: (v) => notifier.toggleReminder('hoursBefore', v),
                  title: const Text('Randevudan 2 saat önce'),
                  subtitle: const Text('Son dakika iptallerini azaltır.'),
                ),
                if (kShowMoney) ...[
                  Divider(height: 1, color: palette.borderSubtle),
                  SwitchListTile(
                    value: r.paymentReminder,
                    onChanged: (v) => notifier.toggleReminder('payment', v),
                    title: const Text('Ödenmemiş seans hatırlatması'),
                    subtitle: const Text(
                      'Seans sonrası ödeme yapılmadıysa danışana hatırlatılır.',
                    ),
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
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Bu ekran görüşme için hazırlanmıştır. Hangi hatırlatmaların işinize '
            'yaradığını, hangilerinin danışanı rahatsız ettiğini sizden '
            'öğrenmek istiyoruz.',
            style: text.bodySmall?.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}
