import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/energy.dart';
import '../export/plan_pdf.dart';
import '../widgets/export_plan_button.dart';
import '../widgets/interview_note.dart';
import '../widgets/plan_editor_layout.dart';

/// The same plan as [PlanEditorScreen], built the way the research says Turkish
/// dietitians actually build one: exchange counts per group, with the food
/// chosen from a substitution sheet. Shown next to the freeform editor so a
/// dietitian can point at the one that matches their practice — the question
/// this screen exists to answer is which model is right, not which is prettier.
/// A gap between the plan and the target past which "Fark" takes the warning
/// colour. A guess, to ask dietitians about (QUESTIONS.md DT20).
const kExchangeGapWarningKcal = 100;

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
          // The gap sits beside the two numbers it is the difference of, so
          // the eye reads one row, not two places.
          Wrap(
            spacing: AppSpacing.x3,
            runSpacing: AppSpacing.md,
            children: [
              _Figure(label: 'Planda', value: '${plan.kcal} kcal'),
              _Figure(label: 'Hedef', value: '$target kcal', muted: true),
              Semantics(
                label: difference,
                excludeSemantics: true,
                child: _Figure(
                  label: 'Fark',
                  value: _signed(plan.kcal - target),
                  warn: (plan.kcal - target).abs() > kExchangeGapWarningKcal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
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
        const InterviewNote(
          'Bu ekran bir deneme: planı besin ve miktar yazarak mı, yoksa '
          'değişim listesiyle mi kuruyorsunuz? Gruplar, ölçüler ve kalori '
          'değerleri örnektir — sizin kullandığınız tabloyu öğrenmek '
          'istiyoruz.',
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    this.muted = false,
    this.warn = false,
  });

  final String label;
  final String value;
  final bool muted;

  /// A gap worth a second look: the figure takes the warning colour.
  final bool warn;

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
            color: warn
                ? palette.warning
                : muted
                ? palette.textSecondary
                : null,
          ),
        ),
      ],
    );
  }
}

/// "+120 kcal" / "−746 kcal": the gap with its sign.
String _signed(int gap) =>
    gap == 0 ? '0 kcal' : '${gap > 0 ? '+' : '−'}${gap.abs()} kcal';

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

    final kcalStyle = text.bodyMedium!.copyWith(color: palette.textSecondary);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The kcal column needs room: on a narrow card (or at large text)
          // it moves under the group's name instead of squeezing it.
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final inline = constraints.maxWidth >= 330 * scale;
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kExchangeGroupLabels[line.group] ?? line.group.name,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    // Wraps instead of being cut off: the second example is part
                    // of what the group means.
                    Text(
                      examples.take(2).join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                    if (!inline) Text('${line.kcal} kcal', style: kcalStyle),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StepButton(
                icon: AppIcons.remove,
                tooltip: 'Azalt',
                onPressed: line.count == 0
                    ? null
                    : () => setCount(line.count - 1),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${line.count}',
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
              ),
              _StepButton(
                icon: AppIcons.add,
                tooltip: 'Artır',
                onPressed: () => setCount(line.count + 1),
              ),
              if (inline) ...[
                const SizedBox(width: AppSpacing.sm),
                // Right-aligned in a slot sized to the widest value, so the kcal
                // column lines up row to row.
                SizedBox(
                  width: numberSlotWidth(context, '0000 kcal', kcalStyle),
                  child: Text(
                    '${line.kcal} kcal',
                    textAlign: TextAlign.end,
                    style: kcalStyle,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// A round stepper button on the card: a quiet disc, no outline, 40 px to
/// touch.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      // The theme sets one foreground for every state, so a disabled button
      // looked like an enabled one: this one fades.
      style:
          IconButton.styleFrom(
            backgroundColor: palette.canvas,
            disabledBackgroundColor: palette.canvas,
            minimumSize: const Size(40, 40),
          ).copyWith(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? palette.textSecondary.withValues(alpha: 0.45)
                  : palette.ink,
            ),
          ),
      icon: Icon(icon, size: 20),
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
