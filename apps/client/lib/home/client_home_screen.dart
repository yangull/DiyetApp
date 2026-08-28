import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// The client app's first real screen (PLANNING.md §2.3 #51): two tabs,
/// Ana Sayfa and Profil. Everything on Ana Sayfa is real — the greeting uses
/// the signed-in name — except the two path cards, which are unbuilt and
/// carry a single honest "Yakında" tag rather than a fake tap target
/// (§2.3 #50). Phase 1 turns them into the marketplace entry points.
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({
    super.key,
    required this.profile,
    required this.actions,
  });

  final AppProfile profile;
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
            ? _AnaSayfaTab(profile: widget.profile)
            : _ProfilTab(profile: widget.profile, actions: widget.actions),
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

class _AnaSayfaTab extends StatelessWidget {
  const _AnaSayfaTab({required this.profile});

  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    final firstName = profile.fullName.isEmpty
        ? 'Danışan'
        : profile.fullName.split(' ').first;

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
  const _ProfilTab({required this.profile, required this.actions});

  final AppProfile profile;
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
                  profile.fullName.isEmpty ? '—' : profile.fullName,
                  style: text.titleMedium,
                ),
              ],
            ),
          ),
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
