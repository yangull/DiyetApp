import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The client app's first real screen (PLANNING.md §2.3 #51): two tabs,
/// Ana Sayfa and Profil. Everything on Ana Sayfa is real — the greeting uses
/// the signed-in name, and a pending dietitian invite is a live row — except
/// the two path cards, which are unbuilt and carry a single honest "Yakında"
/// tag rather than a fake tap target (§2.3 #50). Phase 1 turns them into the
/// marketplace entry points.
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
      body: SafeArea(
        child: _tab == 0
            ? _AnaSayfaTab(profile: widget.identity.profile)
            : _ProfilTab(identity: widget.identity, actions: widget.actions),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
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

class _AnaSayfaTab extends ConsumerWidget {
  const _AnaSayfaTab({required this.profile});

  final AppProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final firstName = profile.fullName.isEmpty
        ? 'Danışan'
        : profile.fullName.split(' ').first;
    final invites = ref.watch(pendingInvitesProvider);

    return ListView(
      padding: EdgeInsets.all(density.pagePadding),
      children: [
        Text('Merhaba, $firstName', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bugün nasıl ilerlemek istersin?',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Nothing is shown while this loads or if it fails: an invite is an
        // addition to the screen, not something it depends on.
        for (final invite
            in invites.asData?.value ?? const <ClientRelationship>[])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _InviteCard(invite: invite),
          ),
        const _PathCard(
          title: 'Diyetisyenle çalış',
          body: 'Sana uygun diyetisyeni seç, planınızı birlikte oluşturun.',
        ),
        const SizedBox(height: AppSpacing.md),
        const _PathCard(
          title: 'Yapay zekâ ile ilerle',
          body: 'Yapay zekâ destekli beslenme planı ve düzenli takip.',
        ),
      ],
    );
  }
}

/// The inviting dietitian's name. Readable before accepting because the
/// invite's insert policy requires an approved dietitian, and migration 1's
/// "profiles: read approved dietitians" policy is still in force.
final _inviterProvider = FutureProvider.family<AppProfile, String>((
  ref,
  dietitianId,
) {
  return ref.watch(profileRepositoryProvider).fetchProfile(dietitianId);
});

class _InviteCard extends ConsumerWidget {
  const _InviteCard({required this.invite});

  final ClientRelationship invite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final inviter = ref.watch(_inviterProvider(invite.dietitianId));
    // Never the invited email: that is the client's own address, and this
    // card asks them to grant a stranger access to their health data. Who is
    // asking has to be on the card.
    final name = inviter.asData?.value.fullName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name == null
                  ? 'Bir diyetisyen sizi davet etti'
                  : '$name sizi davet etti',
              style: text.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kabul ederseniz diyetisyeniniz hedefinizi ve sağlık '
              'notlarınızı görebilir.',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                FilledButton(
                  onPressed: () => _respond(context, ref, accept: true),
                  child: const Text('Kabul et'),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: () => _respond(context, ref, accept: false),
                  child: const Text('Reddet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref, {
    required bool accept,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(clientRelationshipRepositoryProvider);
    try {
      if (accept) {
        await repo.acceptInvite(invite.id);
      } else {
        await repo.declineInvite(invite.id);
      }
      ref.invalidate(pendingInvitesProvider);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('İşlem tamamlanamadı. Tekrar deneyin.')),
      );
    }
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.title, required this.body});

  final String title;
  final String body;

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
            Row(
              children: [
                Expanded(child: Text(title, style: text.titleLarge)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surfaceSubtle,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Yakında',
                    style: text.labelSmall?.copyWith(color: palette.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
          ],
        ),
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
              'Bu bilgileri yalnızca kabul ettiğiniz diyetisyen görebilir.',
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
      messenger.showSnackBar(
        const SnackBar(content: Text('Bilgileriniz kaydedildi.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Kaydedilemedi. Tekrar deneyin.')),
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
