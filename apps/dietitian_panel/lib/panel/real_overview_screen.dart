import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../util/breakpoints.dart';
import '../widgets/readable_width.dart';
import '../widgets/tone_pill.dart';
import 'real_client_detail_screen.dart';

/// The real panel's Genel Bakış in direction B (PLANNING #133): one focal card
/// (how many clients are active, and the screen's one filled action, "Danışan
/// davet et"), then the clients and the invites under small-capital labels.
/// Wide screens put the invites in a second column. Only what exists is drawn
/// (rule 4): no plans, triage or agenda until those features ship.
///
/// Two calls back this screen: the relationship rows (which include pending
/// invites, so an invite is visible while it waits) and `list_my_clients()`
/// for the names of the active ones, joined here by client id. Names do not
/// come from the relationship rows because a matched client's name lives in
/// `profiles`, which is read through a narrow projection rather than a
/// blanket policy — see migration 4.
class RealOverviewScreen extends ConsumerWidget {
  const RealOverviewScreen({super.key, required this.profile});

  final AppProfile profile;

  static const _twoColumnsFrom = 1000.0;
  static const _sideWidth = 396.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationships = ref.watch(dietitianClientsProvider(profile.id));
    final names = ref.watch(dietitianClientNamesProvider(profile.id));
    void invite() => _openInviteDialog(context, ref, profile.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _twoColumnsFrom;
        final content = relationships.when(
          loading: () => const AppLoading.card(label: 'Danışanlar yükleniyor'),
          error: (_, _) => AppErrorView.card(
            title: 'Danışan listesi yüklenemedi',
            message: 'Bağlantınızı kontrol edip tekrar deneyin.',
            onRetry: () => ref.invalidate(dietitianClientsProvider(profile.id)),
            // Inviting doesn't need the list, so a failed load doesn't take
            // it away.
            actionLabel: 'Danışan davet et',
            onAction: invite,
          ),
          data: (rows) {
            final active = rows.where((r) => r.isActive).toList();
            final invites = rows.where((r) => !r.isActive).toList();
            // A blank name (the profiles default) counts as no name.
            final nameOf = {
              for (final name in names.asData?.value ?? const <ClientName>[])
                if (name.fullName.trim().isNotEmpty)
                  name.clientId: name.fullName,
            };
            final focal = _ClientsFocalCard(
              active: active.length,
              waiting: invites.where((r) => r.isPending).length,
              onInvite: invite,
            );
            if (rows.isEmpty) return focal;

            final clients = [
              if (active.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.x3),
                SectionLabel('Danışanlar', count: '${active.length}'),
                const SizedBox(height: AppSpacing.sm),
                // Without this, a failed name lookup looked the same as
                // clients who have no name.
                if (names.hasError) ...[
                  AppErrorView.notice(
                    message:
                        'Danışan adları yüklenemedi; adreslerle gösteriliyor.',
                    onRetry: () => ref.invalidate(
                      dietitianClientNamesProvider(profile.id),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _ClientsCard(rows: active, names: nameOf),
              ],
            ];
            final invitesSection = [
              SectionLabel('Davetler', count: '${invites.length}'),
              const SizedBox(height: AppSpacing.sm),
              _InvitesCard(rows: invites),
              if (invites.any((r) => r.isPending)) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bekleyen davetler, danışan kabul edene kadar açılamaz.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.palette.textSecondary),
                ),
              ],
            ];

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [focal, ...clients],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  SizedBox(
                    width: _sideWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: invites.isEmpty
                          ? const [_NoInvitesNote()]
                          : invitesSection,
                    ),
                  ),
                ],
              );
            }
            // A waiting invite needs an answer sooner than the client list
            // needs scrolling, so it comes first on a phone.
            final invitesBlock = [
              if (invites.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.x3),
                ...invitesSection,
              ],
            ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                focal,
                if (invites.any((r) => r.isPending)) ...[
                  ...invitesBlock,
                  ...clients,
                ] else ...[
                  ...clients,
                  ...invitesBlock,
                ],
              ],
            );
          },
        );

        return SingleChildScrollView(
          padding: readablePadding(
            constraints.maxWidth,
            context.density.pagePadding,
            maxWidth: kDashboardWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(name: profile.fullName),
              const SizedBox(height: AppSpacing.xxl),
              content,
            ],
          ),
        );
      },
    );
  }
}

/// Inner padding of every card here, as on the demo's Genel Bakış.
double _cardPadding(BuildContext context) => context.density.cardPadding;

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final first = _firstName(name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatTodayLabel(DateTime.now()),
          style: text.bodyMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          first.isEmpty ? 'Hoş geldiniz' : 'Hoş geldiniz, $first',
          style: isPanelPhone(context)
              ? text.headlineMedium
              : text.headlineLarge,
        ),
      ],
    );
  }
}

/// "Dyt. Deniz Arslan" greets as "Deniz": the title and the surname make a
/// heading too long for a phone.
String _firstName(String fullName) {
  final words = fullName
      .split(RegExp(r'\s+'))
      .where(
        (w) =>
            w.isNotEmpty &&
            !RegExp(
              r'^(dyt|dt|uzm|dr|prof|doç|doc)\.?$',
              caseSensitive: false,
            ).hasMatch(w),
      )
      .toList();
  return words.isEmpty ? '' : words.first;
}

/// The screen's focal card and its one filled action. With no clients yet it
/// is the empty state: what to do first.
class _ClientsFocalCard extends StatelessWidget {
  const _ClientsFocalCard({
    required this.active,
    required this.waiting,
    required this.onInvite,
  });

  final int active;
  final int waiting;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    // Layout follows the width; density follows the input (#135).
    final wide = !isPanelPhone(context);
    final pad = _cardPadding(context);
    final button = FilledButton.icon(
      onPressed: onInvite,
      icon: const Icon(AppIcons.invite, size: 18),
      label: const Text('Danışan davet et'),
    );
    final caption = Text(
      waiting > 0
          ? '$waiting davet yanıt bekliyor.'
          : active == 0
          ? 'Bir danışanı e-posta adresiyle davet ederek başlayın.'
          : 'Yeni bir danışanı e-posta adresiyle davet edebilirsiniz.',
      style: (wide ? text.bodyLarge : text.bodyMedium)?.copyWith(
        color: palette.textSecondary,
      ),
    );
    final words = active == 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  waiting == 0
                      ? 'Henüz danışanınız yok'
                      : 'Henüz aktif danışanınız yok',
                  style: text.headlineSmall,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              caption,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      '$active',
                      style: AppTypography.figures(
                        wide ? 48 : 56,
                        wide ? 52 : 60,
                      ).copyWith(color: context.palette.ink, letterSpacing: -1),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'aktif danışan',
                        semanticsLabel: '$active aktif danışan',
                        style: text.headlineSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              caption,
            ],
          );

    return CloudCard(
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(1);
            // Beside the words on a wide card; under them on a phone or at
            // large text, full width there like the client app's main action.
            if (wide && constraints.maxWidth >= 560 * scale) {
              return Row(
                children: [
                  Expanded(child: words),
                  const SizedBox(width: AppSpacing.lg),
                  button,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                words,
                const SizedBox(height: AppSpacing.lg),
                button,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Active clients: the avatar, the name and the address; the whole row opens
/// the record (the chevron says so).
class _ClientsCard extends StatelessWidget {
  const _ClientsCard({required this.rows, required this.names});

  final List<ClientRelationship> rows;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) {
    final pad = _cardPadding(context);
    final inset = pad + context.density.avatarSize + ActionRow.gap;
    return CloudCard(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, row) in rows.indexed) ...[
              if (i > 0) Divider(indent: inset),
              _ClientRow(row: row, name: names[row.clientId]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({required this.row, required this.name});

  final ClientRelationship row;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final pad = _cardPadding(context);
    final name = this.name;
    final clientId = row.clientId;
    // A name lookup that is still loading, or failed, shows the address in
    // the name's place rather than a dash.
    final title = name ?? row.invitedEmail;

    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: context.density.rowHeight + 16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.sm),
        child: Row(
          children: [
            PersonAvatar(name: name),
            const SizedBox(width: ActionRow.gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleMedium),
                  if (name != null)
                    Text(
                      row.invitedEmail,
                      style: text.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            if (clientId != null)
              Icon(
                AppIcons.chevronRight,
                size: isPanelPhone(context) ? 24 : 20,
                color: palette.textSecondary,
              ),
          ],
        ),
      ),
    );
    if (clientId == null) return content;
    void open() => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RealClientDetailScreen(clientId: clientId, fallbackName: name),
      ),
    );
    // excludeSemantics drops the InkWell's own tap action, so it is restated.
    return Semantics(
      button: true,
      label: '$title, danışanı aç',
      onTap: open,
      excludeSemantics: true,
      child: InkWell(onTap: open, child: content),
    );
  }
}

/// Pending and declined invites: an address and what became of it. Neither
/// can be opened until a client accepts. Deliberately not
/// `widgets/status_pill.dart`: that one is typed to [PlanState], and its
/// violet means "a machine wrote this" (#57).
class _InvitesCard extends StatelessWidget {
  const _InvitesCard({required this.rows});

  final List<ClientRelationship> rows;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final pad = _cardPadding(context);
    final avatar = context.density.avatarSize;
    final inset = pad + avatar + ActionRow.gap;
    return CloudCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, row) in rows.indexed) ...[
              if (i > 0) Divider(indent: inset),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: context.density.rowHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: pad,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          width: avatar,
                          height: avatar,
                          decoration: BoxDecoration(
                            color: palette.canvas,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppIcons.mail,
                            size: avatar * 0.55,
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: ActionRow.gap),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, c) {
                            // The pill beside the address when both fit, under
                            // it on a narrow phone or at large text.
                            final stacked =
                                c.maxWidth <
                                200 * MediaQuery.textScalerOf(context).scale(1);
                            final declined =
                                row.status == RelationshipStatus.declined;
                            final pill = TonePill(
                              label: declined ? 'Reddedildi' : 'Bekliyor',
                              tone: declined
                                  ? PillTone.warning
                                  : PillTone.neutral,
                            );
                            final email = Text(
                              row.invitedEmail,
                              style: text.bodyLarge,
                              overflow: TextOverflow.ellipsis,
                            );
                            if (stacked) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  email,
                                  const SizedBox(height: AppSpacing.xs),
                                  pill,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: email),
                                const SizedBox(width: AppSpacing.sm),
                                pill,
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The invites column when nothing waits: it says where invites will show.
class _NoInvitesNote extends StatelessWidget {
  const _NoInvitesNote();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Davetler'),
        const SizedBox(height: AppSpacing.sm),
        CloudCard(
          child: Padding(
            padding: EdgeInsets.all(_cardPadding(context)),
            child: Text(
              'Bekleyen davet yok. Davet ettiğiniz danışanlar kabul edene '
              'kadar burada görünür.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.palette.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openInviteDialog(
  BuildContext context,
  WidgetRef ref,
  String profileId,
) async {
  // Captured before the await: the dialog is an async gap, and this helper
  // has no State of its own to check `mounted` against afterwards.
  final messenger = ScaffoldMessenger.of(context);
  final email = await showDialog<String>(
    context: context,
    builder: (_) => const _InviteDialog(),
  );
  if (email == null) return;

  try {
    await ref
        .read(clientRelationshipRepositoryProvider)
        .inviteClient(dietitianId: profileId, email: email);
    ref.invalidate(dietitianClientsProvider(profileId));
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Davet oluşturuldu. Danışanınız Wellkit\'e kayıt olup uygulamayı '
          'açtığında daveti görecek.',
        ),
      ),
    );
  } on PostgrestException catch (e) {
    // 23505 covers both unique indexes: a pending invite to the same address,
    // and re-inviting someone who is already an active client.
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          e.code == '23505'
              ? 'Bu e-posta için zaten bir davet var.'
              : 'Davet gönderilemedi. Lütfen tekrar deneyin.',
        ),
      ),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Davet gönderilemedi. Lütfen tekrar deneyin.'),
      ),
    );
  }
}

class _InviteDialog extends StatefulWidget {
  const _InviteDialog();

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_error != null) setState(() => _error = null);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return AlertDialog(
      // The field opens the keyboard at once; on a phone the content scrolls
      // instead of overflowing.
      scrollable: true,
      title: const Text('Danışan davet et'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledField(
              label: 'Danışanın e-posta adresi',
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              errorText: _error,
              onSubmitted: (_) => _submit(context),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Danışanınız bu adresle Wellkit\'e kayıt olup uygulamayı açtığında '
              'daveti görür. '
              'Ona ayrıca haber vermeniz gerekir.',
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text('Davet gönder'),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final email = _controller.text.trim();
    if (!_looksLikeEmail(email)) {
      setState(
        () => _error = email.isEmpty
            ? 'E-posta adresini girin.'
            : 'Geçerli bir e-posta adresi girin.',
      );
      return;
    }
    Navigator.of(context).pop(email);
  }
}

bool _looksLikeEmail(String value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
