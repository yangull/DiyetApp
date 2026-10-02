import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../widgets/readable_width.dart';
import '../widgets/status_pill.dart';
import 'client_detail_screen.dart';
import 'intake_form_screen.dart';
import '../util/breakpoints.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final _search = TextEditingController();

  /// Null means "every goal"; null plan state means "draft and approved".
  String? _goal;
  PlanState? _planState;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    final query = trLower(_search.text.trim());
    final goals = {for (final c in demo.clients) c.goal}.toList()..sort();
    final clients = _matching(demo);

    final phone = isPanelPhone(context);
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Danışanlarınız', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${demo.clients.length} aktif · ${demo.draftCount} plan '
          'onay bekliyor',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
      ],
    );
    final addButton = FilledButton.icon(
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const IntakeFormScreen())),
      icon: const Icon(AppIcons.add, size: 18),
      label: const Text('Danışan ekle'),
    );

    // The weight column: a slot sized to its widest value, the number
    // right-aligned in it so the decimals line up (#135).
    final kgStyle = text.bodyMedium!;
    final kgWidth = numberSlotWidth(context, '000,0 kg', kgStyle);

    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: readablePadding(
          constraints.maxWidth,
          density.pagePadding,
          maxWidth: kDashboardWidth,
        ),
        children: [
          // On a phone the heading and its button share a row while they fit.
          if (phone)
            LayoutBuilder(
              builder: (context, c) {
                // Side by side only when the whole heading word and the button
                // both fit, measured at the current text size.
                final headingPainter = TextPainter(
                  text: TextSpan(
                    text: 'Danışanlarınız',
                    style: text.headlineLarge,
                  ),
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                  maxLines: 1,
                )..layout();
                final buttonWidth =
                    textButtonWidth(context, 'Danışan ekle', icon: true) +
                    AppSpacing.lg;
                final side =
                    c.maxWidth >=
                    headingPainter.width + AppSpacing.md + buttonWidth;
                headingPainter.dispose();
                return side
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: heading),
                          const SizedBox(width: AppSpacing.md),
                          addButton,
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          heading,
                          const SizedBox(height: AppSpacing.lg),
                          addButton,
                        ],
                      );
              },
            )
          else
            Row(
              children: [
                Expanded(child: heading),
                addButton,
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
          if (phone)
            // One row while it fits: search takes what the filter button
            // leaves. At large text the button drops under the search.
            // Clearing the filters happens inside the sheet.
            LayoutBuilder(
              builder: (context, c) {
                final filter = OutlinedButton.icon(
                  onPressed: () => _showFilters(goals),
                  icon: const Icon(AppIcons.filter, size: 18),
                  label: Text(
                    _activeFilters == 0
                        ? 'Filtrele'
                        : 'Filtrele · $_activeFilters',
                  ),
                );
                final filterWidth =
                    textButtonWidth(context, 'Filtrele · 2', icon: true) +
                    AppSpacing.lg;
                if (c.maxWidth < 170 + AppSpacing.sm + filterWidth) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _searchField(query),
                      const SizedBox(height: AppSpacing.md),
                      filter,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _searchField(query)),
                    const SizedBox(width: AppSpacing.sm),
                    filter,
                  ],
                );
              },
            )
          else
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              // The dropdown carries a label above it; the others sit on its
              // box, so they line up at the bottom.
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                SizedBox(width: 260, child: _searchField(query)),
                SizedBox(
                  width: 220,
                  child: LabeledDropdown<String?>(
                    label: 'Hedef',
                    value: _goal,
                    onChanged: (value) => setState(() => _goal = value),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tüm hedefler'),
                      ),
                      for (final goal in goals)
                        DropdownMenuItem(
                          value: goal,
                          child: Text(goal, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  ),
                ),
                FilterChip(
                  label: const Text('Onay bekleyen'),
                  selected: _planState == PlanState.aiDraft,
                  onSelected: (on) => setState(
                    () => _planState = on ? PlanState.aiDraft : null,
                  ),
                ),
                FilterChip(
                  label: const Text('Onaylanan'),
                  selected: _planState == PlanState.approved,
                  onSelected: (on) => setState(
                    () => _planState = on ? PlanState.approved : null,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          CloudCard(
            child: Column(
              children: [
                if (!phone)
                  Container(
                    constraints: BoxConstraints(minHeight: density.rowHeight),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    // No band of its own inside the Cloud Card: the divider below
                    // separates the column names from the rows.
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: palette.divider),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: density.avatarSize + ActionRow.gap),
                        _head(context, 'Danışan', flex: 3),
                        _head(context, 'Hedef', flex: 3),
                        SizedBox(
                          width: kgWidth,
                          child: Text(
                            'Kilo',
                            textAlign: TextAlign.end,
                            style: text.bodySmall?.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        _head(context, 'Plan durumu', flex: 3),
                      ],
                    ),
                  ),
                if (clients.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeFilters > 0
                              ? 'Bu filtrelerle eşleşen danışan yok.'
                              : 'Aramanızla eşleşen danışan yok.',
                          style: text.bodyMedium?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                        if (_activeFilters > 0)
                          EdgeButton(
                            child: TextButton(
                              onPressed: () => setState(() {
                                _goal = null;
                                _planState = null;
                              }),
                              child: const Text('Filtreleri temizle'),
                            ),
                          ),
                      ],
                    ),
                  ),
                for (final client in clients)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClientDetailScreen(clientId: client.id),
                      ),
                    ),
                    child: phone
                        ? _PhoneClientRow(
                            client: client,
                            state: demo.planFor(client.id).state,
                          )
                        : Container(
                            constraints: BoxConstraints(
                              minHeight: density.rowHeight,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: palette.divider),
                              ),
                            ),
                            child: Row(
                              children: [
                                PersonAvatar(name: client.name),
                                const SizedBox(width: ActionRow.gap),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    client.name,
                                    style: text.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    client.goal,
                                    style: text.bodyMedium?.copyWith(
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: kgWidth,
                                  child: Text(
                                    '${formatDecimal(client.weightKg)} kg',
                                    textAlign: TextAlign.end,
                                    style: kgStyle,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: StatusPill(
                                      state: demo.planFor(client.id).state,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DemoClient> _matching(DemoState demo) {
    final query = trLower(_search.text.trim());
    return [
      for (final client in demo.clients)
        if ((query.isEmpty || trLower(client.name).contains(query)) &&
            (_goal == null || client.goal == _goal) &&
            (_planState == null || demo.planFor(client.id).state == _planState))
          client,
    ];
  }

  int get _activeFilters =>
      (_goal == null ? 0 : 1) + (_planState == null ? 0 : 1);

  Widget _searchField(String query) => TextField(
    controller: _search,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      hintText: 'Danışan ara',
      prefixIcon: const Icon(AppIcons.search, size: 20),
      suffixIcon: query.isEmpty
          ? null
          : IconButton(
              icon: const Icon(AppIcons.close, size: 18),
              tooltip: 'Aramayı temizle',
              onPressed: () => setState(_search.clear),
            ),
    ),
  );

  /// The phone's filters: the same goal and plan-status choices as the wide
  /// row, applied as they are tapped, with the result count on the button.
  Future<void> _showFilters(List<String> goals) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final text = Theme.of(sheetContext).textTheme;
          void update(VoidCallback change) {
            setState(change);
            setSheetState(() {});
          }

          Widget choice(String label, bool selected, VoidCallback onTap) =>
              ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => onTap(),
              );

          final count = _matching(ref.read(demoProvider)).length;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                sheetContext.density.pagePadding,
                0,
                sheetContext.density.pagePadding,
                sheetContext.density.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Filtrele', style: text.headlineMedium),
                      ),
                      if (_activeFilters > 0)
                        EdgeButton(
                          end: true,
                          child: TextButton(
                            onPressed: () => update(() {
                              _goal = null;
                              _planState = null;
                            }),
                            child: const Text('Temizle'),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Hedef', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final goal in goals)
                        choice(
                          goal,
                          _goal == goal,
                          // Tapping the chosen one again clears it.
                          () =>
                              update(() => _goal = _goal == goal ? null : goal),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Plan durumu', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      choice(
                        'Onay bekleyen',
                        _planState == PlanState.aiDraft,
                        () => update(
                          () => _planState = _planState == PlanState.aiDraft
                              ? null
                              : PlanState.aiDraft,
                        ),
                      ),
                      choice(
                        'Onaylanan',
                        _planState == PlanState.approved,
                        () => update(
                          () => _planState = _planState == PlanState.approved
                              ? null
                              : PlanState.approved,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text('$count danışanı göster'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _head(BuildContext context, String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: context.palette.textSecondary),
      ),
    );
  }
}

/// A client on a phone (#128 on a narrow screen): name and plan status on the
/// first line, goal and weight under it. The row grows with its text.
class _PhoneClientRow extends StatelessWidget {
  const _PhoneClientRow({required this.client, required this.state});

  final DemoClient client;
  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    return Container(
      constraints: BoxConstraints(minHeight: context.density.rowHeight),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${client.goal} · ${formatDecimal(client.weightKg)} kg',
                  style: text.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                StatusPill(state: state),
              ],
            ),
          ),
          Icon(AppIcons.chevronRight, color: palette.textSecondary),
        ],
      ),
    );
  }
}
