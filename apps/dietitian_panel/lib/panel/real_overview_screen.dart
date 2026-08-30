import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import 'real_client_detail_screen.dart';

/// The dietitian's real client list. Two calls back this screen: the
/// relationship rows (which include pending invites, so an invite is visible
/// while it waits) and `list_my_clients()` for the names of the active ones,
/// joined here by client id. Names do not come from the relationship rows
/// because a matched client's name lives in `profiles`, which is read through
/// a narrow projection rather than a blanket policy — see migration 4.
class RealOverviewScreen extends ConsumerWidget {
  const RealOverviewScreen({super.key, required this.profile});

  final AppProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final density = context.density;
    final relationships = ref.watch(dietitianClientsProvider(profile.id));
    final names = ref.watch(dietitianClientNamesProvider(profile.id));

    return Padding(
      padding: EdgeInsets.all(density.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Hoş geldiniz, ${profile.fullName}',
                  style: text.headlineLarge,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openInviteDialog(context, ref, profile.id),
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: const Text('Danışan davet et'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: relationships.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(error: error),
              data: (rows) => rows.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: _EmptyState(),
                      ),
                    )
                  : _RelationshipTable(
                      rows: rows,
                      // A name lookup that is still loading shows the row
                      // without a name rather than blocking the whole list.
                      names: {
                        for (final name
                            in names.asData?.value ?? const <ClientName>[])
                          name.clientId: name.fullName,
                      },
                    ),
            ),
          ),
        ],
      ),
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
      title: const Text('Danışan davet et'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 360,
            child: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Danışanın e-posta adresi',
              ),
              onSubmitted: (_) => _submit(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Davet, danışanınız aynı e-posta ile Wellkit\'e kayıt olup '
            'uygulamayı açtığında görünür. Şimdilik e-posta gönderilmiyor.',
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeçin'),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text('Davet gönderin'),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final email = _controller.text.trim();
    if (email.isEmpty) return;
    Navigator.of(context).pop(email);
  }
}

class _RelationshipTable extends StatelessWidget {
  const _RelationshipTable({required this.rows, required this.names});

  final List<ClientRelationship> rows;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    return ListView(
      children: [
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
                    _head(context, 'E-posta', flex: 4),
                    _head(context, 'Durum', flex: 3),
                  ],
                ),
              ),
              for (final row in rows)
                _RelationshipRow(row: row, name: names[row.clientId]),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Bekleyen davetler, danışan kabul edene kadar açılamaz.',
          style: text.bodySmall?.copyWith(color: palette.textMuted),
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

class _RelationshipRow extends StatelessWidget {
  const _RelationshipRow({required this.row, required this.name});

  final ClientRelationship row;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;
    // Only an accepted relationship has a client row to open.
    final openable = row.isActive && row.clientId != null;

    final content = Container(
      height: density.rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name ?? (openable ? '—' : 'Davet bekliyor'),
              style: openable
                  ? text.titleMedium
                  : text.bodyMedium?.copyWith(color: palette.textMuted),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              row.invitedEmail,
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _RelationshipStatusPill(status: row.status),
            ),
          ),
        ],
      ),
    );

    if (!openable) return content;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RealClientDetailScreen(
            clientId: row.clientId!,
            fallbackName: name,
          ),
        ),
      ),
      child: content,
    );
  }
}

/// Deliberately not `widgets/status_pill.dart`: that one is typed to
/// [PlanState] and its purple carries one specific meaning — "a machine wrote
/// this and no dietitian has approved it" (PLANNING.md §2 #57). Reusing it for
/// an invite's status would dilute that.
class _RelationshipStatusPill extends StatelessWidget {
  const _RelationshipStatusPill({required this.status});

  final RelationshipStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (label, color) = switch (status) {
      RelationshipStatus.active => ('Aktif', AppColors.primary),
      RelationshipStatus.pending => ('Davet bekliyor', palette.textSecondary),
      RelationshipStatus.declined => ('Reddedildi', palette.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: palette.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Danışan listesi yüklenemedi', style: text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$error',
            style: text.bodySmall?.copyWith(color: palette.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.people_outline, size: 40, color: palette.textMuted),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Henüz danışanınız yok',
          style: text.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bir danışanı e-posta adresiyle davet edebilirsiniz. Marketplace '
          'açıldığında eşleşmeleriniz de burada görünecek.',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
