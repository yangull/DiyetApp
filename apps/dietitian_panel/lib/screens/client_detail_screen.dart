import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/energy.dart';
import '../util/panel_date.dart';
import '../widgets/status_pill.dart';
import '../widgets/weight_chart.dart';
import 'exchange_plan_editor_screen.dart';
import 'plan_editor_screen.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clients.firstWhere((c) => c.id == clientId);
    final plan = demo.planFor(clientId);
    final weights = demo.weights[clientId] ?? const [];
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(title: Text(client.name)),
      body: ListView(
        padding: EdgeInsets.all(context.density.pagePadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Danışan bilgileri', style: text.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.x3,
                    runSpacing: AppSpacing.lg,
                    children: [
                      _Fact(label: 'Yaş', value: '${client.age}'),
                      _Fact(label: 'Boy', value: '${client.heightCm} cm'),
                      _Fact(
                        label: 'Güncel kilo',
                        value: '${client.weightKg.toStringAsFixed(1)} kg',
                      ),
                      _Fact(label: 'Hedef', value: client.goal),
                      _Fact(
                        label: 'Başlangıç',
                        value: formatDate(client.startedOn),
                      ),
                      _Fact(label: 'Cinsiyet', value: _sexLabel(client.sex)),
                      _Fact(
                        label: 'Hareket düzeyi',
                        value: _activityLabel(client.activityLevel),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: palette.borderSubtle),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Sağlık bilgileri', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.x3,
                    runSpacing: AppSpacing.lg,
                    children: [
                      _Fact(label: 'Beslenme tipi', value: client.dietType),
                      _Fact(
                        label: 'Alerji / hassasiyet',
                        value: _listOrDash(client.allergies),
                      ),
                      _Fact(
                        label: 'Kronik rahatsızlık',
                        value: _listOrDash(client.chronicConditions),
                      ),
                      _Fact(
                        label: 'İlaç / takviye',
                        value: _listOrDash(client.medications),
                      ),
                    ],
                  ),
                  if (client.note.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'NOT',
                      style: text.labelSmall?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      client.note,
                      style: text.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _EnergyCard(client: client),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Diyet planı', style: text.titleLarge),
                      const SizedBox(width: AppSpacing.md),
                      StatusPill(state: plan.state),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${plan.day} · ${plan.kcal} kcal · ${plan.meals.length} öğün',
                    style: text.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PlanEditorScreen(clientId: clientId),
                          ),
                        ),
                        child: Text(
                          plan.isDraft ? 'Taslağı düzenle' : 'Planı aç',
                        ),
                      ),
                      // Only where an exchange-list version of the day exists.
                      if (demo.exchangePlanFor(clientId) != null)
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExchangePlanEditorScreen(clientId: clientId),
                            ),
                          ),
                          child: const Text('Değişim listesiyle dene'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Ölçüm geçmişi', style: text.titleLarge),
                      const Spacer(),
                      Text(
                        '${weights.length} ölçüm · haftalık',
                        style: text.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (weights.isEmpty)
                    Text(
                      'Henüz ölçüm kaydı yok.',
                      style: text.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
                    )
                  else ...[
                    WeightChart(entries: weights),
                    const SizedBox(height: AppSpacing.lg),
                    for (final entry in weights.reversed.take(4))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 96,
                              child: Text(
                                formatDate(entry.date),
                                style: text.bodyMedium?.copyWith(
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.kg.toStringAsFixed(1)} kg',
                              style: text.titleMedium?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ölçümleri şimdilik yalnızca görüntülüyoruz. Kilo dışında '
                    'hangi ölçümleri aldığınızı sizden öğrenmek istiyoruz.',
                    style: text.bodySmall?.copyWith(color: palette.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The derivation behind the plan's calorie target, shown as a chain rather
/// than a result: a dietitian who disagrees needs to see which step is wrong.
class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.client});

  final DemoClient client;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final bmh = basalMetabolicRate(client);
    final factor = activityFactor(client.activityLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enerji ihtiyacı', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Yaş, cinsiyet, boy ve kilodan hesaplanıyor; bu bilgiler '
              'değiştiğinde kendiliğinden güncellenir.',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.x3,
              runSpacing: AppSpacing.lg,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Fact(label: 'BMH', value: '${bmh.round()} kcal'),
                Text(
                  '×',
                  style: text.titleLarge?.copyWith(color: palette.textMuted),
                ),
                _Fact(
                  label: 'Aktivite katsayısı',
                  value: factor.toStringAsFixed(1),
                ),
                Text(
                  '=',
                  style: text.titleLarge?.copyWith(color: palette.textMuted),
                ),
                _Fact(
                  label: 'Günlük hedef',
                  value: '${targetEnergy(client)} kcal',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'BMH için Harris-Benedict formülü kullanıldı. Cunningham '
              'formülü yağsız vücut kütlesi istiyor; onu ölçmüyoruz. Siz '
              'hangi formülü kullanıyorsunuz, biyoelektrik impedans '
              'ölçüyor musunuz?',
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

String _listOrDash(List<String> values) =>
    values.isEmpty ? '—' : values.join(', ');

String _sexLabel(Sex sex) => switch (sex) {
  Sex.kadin => 'Kadın',
  Sex.erkek => 'Erkek',
};

String _activityLabel(ActivityLevel level) => switch (level) {
  ActivityLevel.sedanter => 'Hareketsiz',
  ActivityLevel.hafifAktif => 'Az hareketli',
  ActivityLevel.ortaAktif => 'Orta hareketli',
  ActivityLevel.aktif => 'Hareketli',
  ActivityLevel.cokAktif => 'Çok hareketli',
};

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: text.labelSmall?.copyWith(color: context.palette.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: text.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
