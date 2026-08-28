import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final notifier = ref.read(demoProvider.notifier);
    final r = demo.reminders;
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return ListView(
      padding: EdgeInsets.all(context.density.pagePadding),
      children: [
        Text('Hatırlatmalar', style: text.headlineLarge),
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
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Gönderim kanalı', style: text.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: RadioGroup<String>(
            groupValue: r.channel,
            onChanged: (v) => notifier.setChannel(v!),
            child: Column(
              children: [
                const RadioListTile<String>(
                  value: 'push',
                  title: Text('Uygulama bildirimi'),
                  subtitle: Text(
                    'Ücretsiz. Danışanın uygulamayı yüklemiş olması gerekir.',
                  ),
                ),
                Divider(height: 1, color: palette.borderSubtle),
                const RadioListTile<String>(
                  value: 'sms',
                  title: Text('SMS'),
                  subtitle: Text(
                    'Uygulama gerekmez, ancak mesaj başına ücretlidir.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Bu ekran görüşme için hazırlanmıştır. Hangi hatırlatmaların işinize '
          'yaradığını, hangilerinin danışanı rahatsız ettiğini sizden '
          'öğrenmek istiyoruz.',
          style: text.bodySmall?.copyWith(color: palette.textMuted),
        ),
      ],
    );
  }
}
