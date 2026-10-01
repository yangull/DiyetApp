import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/energy.dart';
import '../export/plan_pdf.dart';
import '../widgets/export_plan_button.dart';
import '../widgets/plan_editor_layout.dart';

/// The same plan as [PlanEditorScreen], built the way the research says Turkish
/// dietitians actually build one: exchange counts per group, with the food
/// chosen from a substitution sheet. Shown next to the freeform editor so a
/// dietitian can point at the one that matches their practice — the question
/// this screen exists to answer is which model is right, not which is prettier.
class ExchangePlanEditorScreen extends ConsumerWidget {
  const ExchangePlanEditorScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clients.firstWhere((c) => c.id == clientId);
    final plan = demo.exchangePlanFor(clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final target = targetEnergy(client);
    final difference = plan == null ? '' : _differenceLabel(plan.kcal, target);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: Text(client.name)),
        body: Center(
          child: Text(
            'Bu danışan için değişim listesi hazırlanmadı.',
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ),
      );
    }

    return PlanEditorLayout(
      title: '${client.name} · Değişim listesi',
      state: plan.state,
      aiNote: plan.aiNote ?? '',
      onApprove: () =>
          ref.read(demoProvider.notifier).approveExchangePlan(clientId),
      plannedKcal: plan.kcal,
      targetKcal: target,
      energy: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.x3,
            runSpacing: AppSpacing.md,
            children: [
              _Figure(label: 'Planda', value: '${plan.kcal} kcal'),
              _Figure(label: 'Hedef', value: '$target kcal', muted: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(difference, style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Plan, toplam değişim sayılarından; hedef, danışanın yaş, '
            'cinsiyet, boy ve kilosundan hesaplanıyor. Grup kalorileri '
            'örnek değerlerdir.',
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
      export: ExportPlanButton(
        enabled: !plan.isDraft,
        filename: '${client.name} - değişim listesi',
        build: () => buildExchangePlanPdf(
          client: client,
          plan: plan,
          targetKcal: target,
        ),
      ),
      meals: [
        for (var m = 0; m < plan.meals.length; m++)
          _MealCard(clientId: clientId, mealIndex: m),
      ],
      footer: [
        const _SubstitutionSheet(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Bu ekran bir deneme: planı besin ve miktar yazarak mı, yoksa '
          'değişim listesiyle mi kuruyorsunuz? Gruplar, ölçüler ve kalori '
          'değerleri örnektir — sizin kullandığınız tabloyu öğrenmek '
          'istiyoruz.',
          style: text.bodySmall?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, this.muted = false});

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: text.headlineMedium?.copyWith(
            color: muted ? palette.textSecondary : null,
          ),
        ),
      ],
    );
  }
}

/// Reading two numbers and subtracting them is work the screen can do.
String _differenceLabel(int planned, int target) {
  final gap = planned - target;
  if (gap == 0) return 'Hedefe tam oturuyor';
  return gap > 0
      ? 'Hedefin $gap kcal üzerinde'
      : 'Hedefin ${-gap} kcal altında';
}

class _MealCard extends ConsumerWidget {
  const _MealCard({required this.clientId, required this.mealIndex});

  final String clientId;
  final int mealIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final meal = demo.exchangePlanFor(clientId)!.meals[mealIndex];
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.md,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(meal.name, style: text.titleLarge),
                      Text(
                        meal.time,
                        style: text.bodyMedium?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '${meal.kcal} kcal',
                  style: text.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var l = 0; l < meal.lines.length; l++)
              _LineRow(
                clientId: clientId,
                mealIndex: mealIndex,
                lineIndex: l,
                line: meal.lines[l],
              ),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends ConsumerWidget {
  const _LineRow({
    required this.clientId,
    required this.mealIndex,
    required this.lineIndex,
    required this.line,
  });

  final String clientId;
  final int mealIndex;
  final int lineIndex;
  final ExchangeLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final notifier = ref.read(demoProvider.notifier);
    final examples = kExchangeFoods[line.group] ?? const <String>[];

    void setCount(int value) =>
        notifier.setExchangeCount(clientId, mealIndex, lineIndex, value);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kExchangeGroupLabels[line.group] ?? line.group.name,
                  style: text.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  examples.take(2).join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: palette.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Azalt',
            onPressed: line.count == 0 ? null : () => setCount(line.count - 1),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${line.count}',
              textAlign: TextAlign.center,
              style: text.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Artır',
            onPressed: () => setCount(line.count + 1),
          ),
          SizedBox(
            width: 72,
            child: Text(
              '${line.kcal} kcal',
              textAlign: TextAlign.right,
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// The half that makes the model recognisable: what one exchange looks like on
/// a plate. Read-only here — a dietitian's own list is their own asset, and
/// whether they'd want to edit it is one of the things to ask.
class _SubstitutionSheet extends StatelessWidget {
  const _SubstitutionSheet();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Değişim listesi', style: text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Bir grubun içindeki her seçenek birbirinin yerine geçer.',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final group in ExchangeGroup.values)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                title: Text(
                  kExchangeGroupLabels[group] ?? group.name,
                  style: text.titleMedium,
                ),
                subtitle: Text(
                  '1 değişim · ${kExchangeKcal[group]} kcal',
                  style: text.bodySmall?.copyWith(color: palette.textSecondary),
                ),
                children: [
                  for (final food in kExchangeFoods[group] ?? const <String>[])
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          food,
                          style: text.bodyMedium?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
