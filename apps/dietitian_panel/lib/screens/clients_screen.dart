import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../widgets/status_pill.dart';
import 'client_detail_screen.dart';
import 'intake_form_screen.dart';

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
    final clients = [
      for (final client in demo.clients)
        if ((query.isEmpty || client.name.toLowerCase().contains(query)) &&
            (_goal == null || client.goal == _goal) &&
            (_planState == null || demo.planFor(client.id).state == _planState))
          client,
    ];

    return ListView(
      padding: EdgeInsets.all(density.pagePadding),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Danışanlarınız', style: text.headlineLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${demo.clients.length} aktif · ${demo.draftCount} plan '
                    'onay bekliyor',
                    style: text.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const IntakeFormScreen()),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Danışan ekle'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
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
              ),
            ),
            DropdownMenu<String?>(
              initialSelection: _goal,
              label: const Text('Hedef'),
              width: 220,
              onSelected: (value) => setState(() => _goal = value),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Tüm hedefler'),
                for (final goal in goals)
                  DropdownMenuEntry(value: goal, label: goal),
              ],
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
              Container(
                height: density.rowHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                  child: Container(
                    height: density.rowHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
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
                          child: Text(client.name, style: text.titleMedium),
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
                            '${client.weightKg.toStringAsFixed(1)} kg',
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

  Widget _head(BuildContext context, String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: context.palette.textMuted),
      ),
    );
  }
}
