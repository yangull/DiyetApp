import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return ListView(
      padding: EdgeInsets.all(density.pagePadding),
      children: [
        CloudCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Danışan bilgileri', style: text.titleLarge),
                const SizedBox(height: AppSpacing.lg),
                _Fact(label: 'Hedef', value: detail.goal),
                const SizedBox(height: AppSpacing.lg),
                _Fact(label: 'Bütçe aralığı', value: detail.budgetRange),
                const SizedBox(height: AppSpacing.lg),
                _Fact(label: 'Sağlık notları', value: detail.healthNotes),
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
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    // Null is the expected state for a client who hasn't filled in their own
    // form yet, so it gets a plain label rather than looking like a failure.
    final empty = value == null || value!.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.bodySmall?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          empty ? 'Bilgi girilmemiş' : value!,
          style: empty
              ? text.bodyMedium?.copyWith(color: palette.textSecondary)
              : text.titleMedium,
        ),
      ],
    );
  }
}
