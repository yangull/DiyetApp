import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';
import '../demo/energy.dart';
import '../export/plan_pdf.dart';
import '../widgets/export_plan_button.dart';
import '../widgets/interview_note.dart';
import '../widgets/macro_summary.dart';
import '../widgets/plan_editor_layout.dart';

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

    final target = targetEnergy(client);

    return PlanEditorLayout(
      title: '${client.name} · ${plan.day}',
      state: plan.state,
      aiNote: plan.aiNote ?? '',
      onApprove: () => ref.read(demoProvider.notifier).approve(clientId),
      plannedKcal: plan.kcal,
      targetKcal: target,
      energy: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Günlük hedef', style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.sm),
          // The computed number sits beside the field rather than in it:
          // whether a dietitian overrides it is itself the thing to learn.
          Text(
            'Hesaplanan: $target kcal',
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
      export: ExportPlanButton(
        enabled: !plan.isDraft,
        filename: '${client.name} - ${plan.day}',
        build: () =>
            buildPlanPdf(client: client, plan: plan, targetKcal: target),
      ),
      summary: MacroSummary(kcal: plan.kcal, macros: demo.macros[clientId]!),
      meals: [
        for (var m = 0; m < plan.meals.length; m++)
          _MealCard(clientId: clientId, mealIndex: m),
      ],
      footer: const [
        InterviewNote(
          'Bu ekran görüşme için hazırlanmış bir taslaktır. Bir diyet '
          'listesinde gerçekte hangi alanların bulunması gerektiğini '
          'sizden öğrenmek istiyoruz.',
        ),
      ],
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

    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(meal.name, style: text.titleLarge),
                // The time is a field you can change: it says "Saat" and has
                // a clock, instead of being a bare box.
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 18,
                      color: palette.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Saat',
                      style: text.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < meal.items.length; i++) ...[
              // Keyed by the item, not its index: after a row above is
              // deleted, the fields move with their food instead of keeping
              // the deleted row's text.
              if (i > 0) Divider(color: palette.divider, height: 1),
              Row(
                key: ObjectKey(meal.items[i]),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: _InlineField(
                      initialValue: meal.items[i].food,
                      hint: 'Besin',
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
                    child: _InlineField(
                      initialValue: meal.items[i].amount,
                      hint: 'Miktar',
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
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            // Below the rows, where the new row appears; the header has no
            // room for it on a phone.
            // The icon lines up with the fields above.
            EdgeButton(
              child: TextButton.icon(
                onPressed: () => notifier.addItem(clientId, mealIndex),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Besin ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A food or an amount as plain text on the card: no box of its own, a line
/// under it while it is being edited. A plan of twenty foods is a list, not
/// twenty bordered boxes (audit D4.2, X8).
class _InlineField extends StatelessWidget {
  const _InlineField({
    required this.initialValue,
    required this.hint,
    required this.onChanged,
  });

  final String initialValue;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: text.bodyLarge,
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        hintText: hint,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.ink),
        ),
        // Row height follows the density (48 on touch, tighter on a
        // computer), never below 8 px of air.
        contentPadding: EdgeInsets.symmetric(
          vertical: ((context.density.controlHeight - 24) / 2).clamp(8.0, 16.0),
        ),
      ),
    );
  }
}
