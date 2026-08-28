import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_repository.dart';
import '../widgets/status_pill.dart';
import 'client_detail_screen.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    return ListView(
      padding: EdgeInsets.all(density.pagePadding),
      children: [
        Text('Danışanlarınız', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${demo.clients.length} aktif · ${demo.draftCount} plan onay bekliyor',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
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
              for (final client in demo.clients)
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
