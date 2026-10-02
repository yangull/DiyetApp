import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/readable_width.dart';

/// What a dietitian may read about a matched client, and nothing more. The
/// read succeeds because of migration 4's "clients: read via active
/// relationship" policy — before it, this screen could not have existed.
///
/// Only the three columns `clients` has today. The demo panel shows far more
/// (weight history, an energy target, allergies), but those fields exist only
/// in the demo's fake data; showing them here would be inventing a feature.
class RealClientDetailScreen extends ConsumerWidget {
  const RealClientDetailScreen({
    super.key,
    required this.clientId,
    this.fallbackName,
  });

  final String clientId;

  /// The name already known from the list, shown in the app bar while the
  /// detail loads so the screen doesn't open on a blank title.
  final String? fallbackName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_clientDetailProvider(clientId));

    return Scaffold(
      appBar: AppBar(title: Text(fallbackName ?? 'Danışan')),
      body: detail.when(
        loading: () => const AppLoading(label: 'Yükleniyor'),
        error: (_, _) => AppErrorView(
          title: 'Danışan bilgileri yüklenemedi',
          message: 'Bağlantınızı kontrol edip tekrar deneyin.',
          onRetry: () => ref.invalidate(_clientDetailProvider(clientId)),
        ),
        data: (data) => _Detail(detail: data),
      ),
    );
  }
}

final _clientDetailProvider = FutureProvider.family<ClientDetail, String>((
  ref,
  clientId,
) {
  return ref.watch(profileRepositoryProvider).fetchClientDetail(clientId);
});

class _Detail extends StatelessWidget {
  const _Detail({required this.detail});

  final ClientDetail detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final facts = [
      ('Hedef', detail.goal),
      ('Bütçe aralığı', detail.budgetRange),
      ('Sağlık notları', detail.healthNotes),
    ];
    final nothingYet = facts.every((f) => _isEmpty(f.$2));

    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: readablePadding(
          constraints.maxWidth,
          density.pagePadding,
          maxWidth: 720,
        ),
        children: [
          CloudCard(
            child: Padding(
              padding: EdgeInsets.all(density.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Danışan bilgileri', style: text.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  if (nothingYet)
                    Text(
                      'Danışanınız henüz bilgi girmedi.',
                      style: text.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    )
                  else
                    for (final (i, fact) in facts.indexed) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.lg),
                      _Fact(
                        label: fact.$1,
                        value: fact.$2,
                        long: fact.$1 == 'Sağlık notları',
                      ),
                    ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Bu bilgileri danışanınız kendi uygulamasından giriyor. Ölçüm '
            'takibi ve diyet planı henüz bu ekranda yok.',
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

bool _isEmpty(String? value) => value == null || value.trim().isEmpty;

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.long = false});

  final String label;
  final String? value;

  /// A free-text note: read as a paragraph, not as a bold value.
  final bool long;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    // A field its owner left blank shows a dash; when all three are blank the
    // card says so once instead.
    final empty = _isEmpty(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          empty ? '—' : value!,
          semanticsLabel: empty ? 'Girilmemiş' : null,
          style: empty
              ? text.bodyMedium?.copyWith(color: palette.textSecondary)
              : long
              ? text.bodyLarge
              : text.titleMedium,
        ),
      ],
    );
  }
}
