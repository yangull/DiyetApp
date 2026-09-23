import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'today_tab.dart';

/// The client app's home (PLANNING #51, redesigned as "Sıcak", #131): two
/// tabs, Bugün and Profil. More tabs arrive when their features ship for
/// everyone, not per user (design-system "Redesign Sıcak").
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({
    super.key,
    required this.identity,
    required this.actions,
  });

  final AuthedIdentity identity;
  final AuthGateActions actions;

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bugün's green hero runs under the status bar; Profil keeps the inset.
      body: _tab == 0
          ? TodayTab(
              identity: widget.identity,
              onOpenGoals: () => setState(() => _tab = 1),
            )
          // Bugün sets light status-bar icons for its green hero; Profil sits
          // on the light ground and has to set them back to dark.
          : AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: SafeArea(
                child: _ProfilTab(
                  identity: widget.identity,
                  actions: widget.actions,
                ),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Bugün',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _ProfilTab extends StatelessWidget {
  const _ProfilTab({required this.identity, required this.actions});

  final AuthedIdentity identity;
  final AuthGateActions actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    return ListView(
      padding: EdgeInsets.all(density.pagePadding),
      children: [
        Text('Profil', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AD SOYAD',
                  style: text.labelSmall?.copyWith(color: palette.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  identity.profile.fullName.isEmpty
                      ? '—'
                      : identity.profile.fullName,
                  style: text.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _HedeflerimForm(
          userId: identity.profile.id,
          detail: identity.clientDetail,
        ),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton(
          onPressed: actions.signOut,
          child: const Text('Çıkış yap'),
        ),
      ],
    );
  }
}

/// The only place these three columns are ever written. Without it a client's
/// row stays empty forever and a matched dietitian has nothing to read.
class _HedeflerimForm extends ConsumerStatefulWidget {
  const _HedeflerimForm({required this.userId, required this.detail});

  final String userId;
  final ClientDetail? detail;

  @override
  ConsumerState<_HedeflerimForm> createState() => _HedeflerimFormState();
}

class _HedeflerimFormState extends ConsumerState<_HedeflerimForm> {
  late final _goal = TextEditingController(text: widget.detail?.goal ?? '');
  late final _budget = TextEditingController(
    text: widget.detail?.budgetRange ?? '',
  );
  late final _notes = TextEditingController(
    text: widget.detail?.healthNotes ?? '',
  );

  var _saving = false;

  @override
  void dispose() {
    _goal.dispose();
    _budget.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hedeflerim', style: text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Bu bilgileri yalnızca kabul ettiğin diyetisyen görebilir.',
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _goal,
              decoration: const InputDecoration(labelText: 'Hedefim'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _budget,
              decoration: const InputDecoration(labelText: 'Bütçe aralığım'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Sağlık notlarım'),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateClientDetail(
            userId: widget.userId,
            goal: _emptyToNull(_goal.text),
            budgetRange: _emptyToNull(_budget.text),
            healthNotes: _emptyToNull(_notes.text),
          );
      ref.invalidate(clientDetailProvider(widget.userId));
      messenger.showSnackBar(
        const SnackBar(content: Text('Bilgilerin kaydedildi.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Kaydedilemedi. Tekrar dene.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
