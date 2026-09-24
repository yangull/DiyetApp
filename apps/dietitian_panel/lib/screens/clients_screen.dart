import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../widgets/status_pill.dart';
import 'client_detail_screen.dart';
import 'intake_form_screen.dart';
import '../util/turkish.dart';
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

    final query = _search.text.trim().toLowerCase();
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
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Danışan ekle'),
    );

    return ListView(
      padding: EdgeInsets.all(density.pagePadding),
      children: [
        // On a phone the button sits under the heading at full width.
        if (phone) ...[
          heading,
          const SizedBox(height: AppSpacing.lg),
          addButton,
        ] else
          Row(
            children: [
              Expanded(child: heading),
              addButton,
            ],
          ),
        const SizedBox(height: AppSpacing.xl),
        if (phone) ...[
          // Search stays in view; goal and plan status wait behind one button
          // (Can, C28): four controls took 40 % of the screen before the
          // first client.
          _searchField(query),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showFilters(goals),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(
                  _activeFilters == 0
                      ? 'Filtrele'
                      : 'Filtrele · $_activeFilters',
                ),
              ),
              if (_activeFilters > 0)
                TextButton(
                  style: AppTheme.quietButton,
                  onPressed: () => setState(() {
                    _goal = null;
                    _planState = null;
                  }),
                  child: const Text('Temizle'),
                ),
            ],
          ),
        ] else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 260, child: _searchField(query)),
              // Not DropdownMenu: its arrow button is a fixed 48 px, which
              // the theme can't reach, so it stood taller than the search
              // field beside it. This one has a 24 px content floor instead,
              // so its padding is trimmed to land on the same 38 px.
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String?>(
                  initialValue: _goal,
                  isExpanded: true,
                  iconSize: 20,
                  decoration: const InputDecoration(
                    labelText: 'Hedef',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                  ),
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
                onSelected: (on) =>
                    setState(() => _planState = on ? PlanState.aiDraft : null),
              ),
              FilterChip(
                label: const Text('Onaylanan'),
                selected: _planState == PlanState.approved,
                onSelected: (on) =>
                    setState(() => _planState = on ? PlanState.approved : null),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: Column(
            children: [
              if (!phone)
                Container(
                  constraints: BoxConstraints(minHeight: density.rowHeight),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceSubtle,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(density.cardRadius),
                    ),
                  ),
                  child: Row(
                    children: [
                      _head(context, 'Danışan', flex: 3),
                      _head(context, 'Hedef', flex: 3),
                      _head(context, 'Kilo', flex: 2),
                      _head(context, 'Plan durumu', flex: 3),
                    ],
                  ),
                ),
              if (clients.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Bu filtrelerle eşleşen danışan yok.',
                    style: text.bodyMedium?.copyWith(color: palette.textMuted),
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
                              top: BorderSide(color: palette.borderSubtle),
                            ),
                          ),
                          child: Row(
                            children: [
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
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${formatDecimal(client.weightKg)} kg',
                                  style: text.bodyMedium?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
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
    );
  }

  List<DemoClient> _matching(DemoState demo) {
    final query = _search.text.trim().toLowerCase();
    return [
      for (final client in demo.clients)
        if ((query.isEmpty || client.name.toLowerCase().contains(query)) &&
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
      prefixIcon: const Icon(Icons.search, size: 20),
      suffixIcon: query.isEmpty
          ? null
          : IconButton(
              icon: const Icon(Icons.close, size: 18),
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

          // On the white sheet an unselected chip needs a grey fill to read
          // as a chip; on the grey ground the theme's white does that.
          Widget choice(String label, bool selected, VoidCallback onTap) =>
              ChoiceChip(
                label: Text(label),
                selected: selected,
                backgroundColor: sheetContext.palette.surfaceSubtle,
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
                  Text('Filtrele', style: text.headlineMedium),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Hedef', style: text.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      choice(
                        'Tüm hedefler',
                        _goal == null,
                        () => update(() => _goal = null),
                      ),
                      for (final goal in goals)
                        choice(
                          goal,
                          _goal == goal,
                          () => update(() => _goal = goal),
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
                        'Tümü',
                        _planState == null,
                        () => update(() => _planState = null),
                      ),
                      choice(
                        'Onay bekleyen',
                        _planState == PlanState.aiDraft,
                        () => update(() => _planState = PlanState.aiDraft),
                      ),
                      choice(
                        'Onaylanan',
                        _planState == PlanState.approved,
                        () => update(() => _planState = PlanState.approved),
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
        trUpper(label),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: context.palette.textMuted),
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
        border: Border(top: BorderSide(color: palette.borderSubtle)),
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
          Icon(Icons.chevron_right, color: palette.textMuted),
        ],
      ),
    );
  }
}
