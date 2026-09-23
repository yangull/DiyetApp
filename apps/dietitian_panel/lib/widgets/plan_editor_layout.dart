import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../demo/demo_models.dart';
import '../util/breakpoints.dart';
import 'ai_draft_banner.dart';
import 'status_pill.dart';

/// Below this width the side panel folds into the scrolling column and the
/// approve button moves to a bar pinned to the bottom (PLANNING.md #38).
const kPlanEditorWideBreakpoint = 1100.0;

/// The page both plan editors share, so that in an interview dietitians compare
/// the two plan models rather than two page layouts (UI review #10).
///
/// Status, energy and "Onayla" stay in view while the meals scroll: on a wide
/// screen in a side panel, on a narrow one in a pinned bottom bar. The meal
/// column is capped so food labels stay near their controls.
class PlanEditorLayout extends StatelessWidget {
  const PlanEditorLayout({
    super.key,
    required this.title,
    required this.state,
    required this.aiNote,
    required this.onApprove,
    required this.plannedKcal,
    required this.targetKcal,
    required this.energy,
    required this.export,
    this.summary,
    required this.meals,
    required this.footer,
  });

  final String title;
  final PlanState state;
  final String aiNote;
  final VoidCallback onApprove;
  final int plannedKcal;
  final int targetKcal;
  final Widget energy;
  final Widget export;
  final Widget? summary;
  final List<Widget> meals;
  final List<Widget> footer;

  bool get _isDraft => state == PlanState.aiDraft;

  void _approve(BuildContext context) {
    onApprove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan onaylandı ve danışana gönderildi.')),
    );
  }

  List<Widget> _panel(BuildContext context, {required bool withApprove}) => [
    if (_isDraft) ...[
      AiDraftBanner(
        note: aiNote,
        onApprove: withApprove ? () => _approve(context) : null,
      ),
      const SizedBox(height: AppSpacing.lg),
    ],
    Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: energy,
      ),
    ),
    const SizedBox(height: AppSpacing.lg),
    export,
    if (summary != null) ...[const SizedBox(height: AppSpacing.lg), summary!],
  ];

  List<Widget> _work() => [
    for (final meal in meals) ...[meal, const SizedBox(height: AppSpacing.md)],
    const SizedBox(height: AppSpacing.sm),
    ...footer,
  ];

  @override
  Widget build(BuildContext context) {
    final padding = context.density.pagePadding;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= kPlanEditorWideBreakpoint;
        // A phone's app bar has no room for the title and the pill. The
        // draft banner already says "onay bekliyor", so only "Onaylı" needs
        // a place at the top of the page.
        final phone = isPanelPhone(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: phone
                ? null
                : [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.lg),
                      child: Center(child: StatusPill(state: state)),
                    ),
                  ],
          ),
          body: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: ListView(
                          padding: EdgeInsets.all(padding),
                          children: _work(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320 + padding,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          padding,
                          padding,
                          padding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _panel(context, withApprove: true),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: EdgeInsets.all(padding),
                  children: [
                    if (phone && !_isDraft) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: StatusPill(state: state),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    ..._panel(context, withApprove: false),
                    const SizedBox(height: AppSpacing.xl),
                    ..._work(),
                  ],
                ),
          bottomNavigationBar: !wide && _isDraft
              ? _ApproveBar(
                  plannedKcal: plannedKcal,
                  targetKcal: targetKcal,
                  onApprove: () => _approve(context),
                )
              : null,
        );
      },
    );
  }
}

class _ApproveBar extends StatelessWidget {
  const _ApproveBar({
    required this.plannedKcal,
    required this.targetKcal,
    required this.onApprove,
  });

  final int plannedKcal;
  final int targetKcal;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: palette.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          // On a phone the figures sit above a full-width button.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final figures = Text(
                'Plan $plannedKcal kcal · hedef $targetKcal kcal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
              final button = FilledButton(
                onPressed: onApprove,
                child: const Text('Onayla ve danışana gönder'),
              );
              return constraints.maxWidth < 560
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        figures,
                        const SizedBox(height: AppSpacing.sm),
                        button,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: figures),
                        const SizedBox(width: AppSpacing.md),
                        button,
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
