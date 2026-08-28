import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';
import '../demo/energy.dart';
import '../export/plan_pdf.dart';
import '../widgets/export_plan_button.dart';
import '../widgets/ai_draft_banner.dart';
import '../widgets/macro_summary.dart';
import '../widgets/status_pill.dart';

/// The screen this whole product turns on: the AI draft a dietitian edits and
/// approves. Rows are real text fields so the plan can be changed live during
/// an interview.
class PlanEditorScreen extends ConsumerWidget {
  const PlanEditorScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clients.firstWhere((c) => c.id == clientId);
    final plan = demo.planFor(clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: Text('${client.name} · ${plan.day}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(child: StatusPill(state: plan.state)),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(context.density.pagePadding),
        children: [
          if (plan.isDraft) ...[
            AiDraftBanner(
              note: plan.aiNote ?? '',
              onApprove: () {
                ref.read(demoProvider.notifier).approve(clientId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan onaylandı ve danışana gönderildi.'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          Row(
            children: [
              Text('Günlük hedef', style: text.titleLarge),
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: '${plan.kcal}',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(suffixText: 'kcal'),
                  onChanged: (v) => ref
                      .read(demoProvider.notifier)
                      .setKcal(clientId, int.tryParse(v) ?? plan.kcal),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // The computed number sits beside the field rather than in it:
              // whether a dietitian overrides it is itself the thing to learn.
              Flexible(
                child: Text(
                  'Hesaplanan: ${targetEnergy(client)} kcal',
                  style: text.bodyMedium?.copyWith(color: palette.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ExportPlanButton(
            enabled: !plan.isDraft,
            filename: '${client.name} - ${plan.day}',
            build: () => buildPlanPdf(
              client: client,
              plan: plan,
              targetKcal: targetEnergy(client),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MacroSummary(kcal: plan.kcal, macros: demo.macros[clientId]!),
          const SizedBox(height: AppSpacing.xl),
          for (var m = 0; m < plan.meals.length; m++) ...[
            _MealCard(clientId: clientId, mealIndex: m),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Bu ekran görüşme için hazırlanmış bir taslaktır. Bir diyet '
            'listesinde gerçekte hangi alanların bulunması gerektiğini '
            'sizden öğrenmek istiyoruz.',
            style: text.bodySmall?.copyWith(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends ConsumerWidget {
  const _MealCard({required this.clientId, required this.mealIndex});

  final String clientId;
  final int mealIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final meal = demo.planFor(clientId).meals[mealIndex];
    final notifier = ref.read(demoProvider.notifier);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(meal.name, style: text.titleLarge),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 96,
                  child: TextFormField(
                    initialValue: meal.time,
                    decoration: const InputDecoration(isDense: true),
                    style: text.bodyMedium,
                    onChanged: (v) =>
                        notifier.setMealTime(clientId, mealIndex, v),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => notifier.addItem(clientId, mealIndex),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Besin ekle'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < meal.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        key: ValueKey('$clientId-$mealIndex-$i-food'),
                        initialValue: meal.items[i].food,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Besin',
                        ),
                        onChanged: (v) => notifier.editItem(
                          clientId,
                          mealIndex,
                          i,
                          v,
                          meal.items[i].amount,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        key: ValueKey('$clientId-$mealIndex-$i-amount'),
                        initialValue: meal.items[i].amount,
                        decoration: const InputDecoration(
                          isDense: true,
                          hintText: 'Miktar',
                        ),
                        onChanged: (v) => notifier.editItem(
                          clientId,
                          mealIndex,
                          i,
                          meal.items[i].food,
                          v,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Satırı sil',
                      onPressed: () =>
                          notifier.removeItem(clientId, mealIndex, i),
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
