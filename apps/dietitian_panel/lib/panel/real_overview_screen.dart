import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import 'real_client_detail_screen.dart';
import '../util/turkish.dart';
import '../util/breakpoints.dart';

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
    final inviteButton = FilledButton.icon(
      onPressed: () => _openInviteDialog(context, ref, profile.id),
      icon: const Icon(Icons.person_add_alt, size: 18),
      label: const Text('Danışan davet et'),
    );

    final greeting = Text(
      'Hoş geldiniz, ${profile.fullName}',
      style: text.headlineLarge,
    );
    Widget states({required bool scrollable}) => relationships.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _ErrorState(
        onRetry: () => ref.invalidate(dietitianClientsProvider(profile.id)),
      ),
      data: (rows) {
        if (rows.isEmpty) {
          const empty = Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: _EmptyState(),
          );
          return scrollable
              ? const Center(child: SingleChildScrollView(child: empty))
              : empty;
        }
        final table = _RelationshipTable(
          rows: rows,
          scrollable: scrollable,
          // A name lookup that is still loading shows the row without a
          // name rather than blocking the whole list.
          names: {
            for (final name in names.asData?.value ?? const <ClientName>[])
              name.clientId: name.fullName,
          },
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Without this, a failed name lookup looked the same as clients
            // who have no name: a column of dashes.
            if (names.hasError) ...[
              _NamesErrorNotice(
                onRetry: () =>
                    ref.invalidate(dietitianClientNamesProvider(profile.id)),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (scrollable) Expanded(child: table) else table,
          ],
        );
      },
    );

    // On a phone the whole page scrolls as one: the greeting, the invite
    // button under it at full width, then the list (#38).
    if (isPanelPhone(context)) {
      return ListView(
        padding: EdgeInsets.all(density.pagePadding),
        children: [
          greeting,
          const SizedBox(height: AppSpacing.lg),
          inviteButton,
          const SizedBox(height: AppSpacing.xl),
          states(scrollable: false),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.all(density.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: greeting),
              inviteButton,
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: states(scrollable: true)),
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
    if (email.isEmpty) return;
    Navigator.of(context).pop(email);
  }
}

class _RelationshipTable extends StatelessWidget {
  const _RelationshipTable({
    required this.rows,
    required this.names,
    required this.scrollable,
  });

  final List<ClientRelationship> rows;
  final Map<String, String> names;

  /// False when the page around it already scrolls (the phone layout).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    final children = [
      Card(
        child: Column(
          children: [
            // Column headings only mean something when the columns line up;
            // on a phone each row stacks its own labelled facts.
            if (!isPanelPhone(context))
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
    ];
    return scrollable
        ? ListView(children: children)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
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

    final label =
        name ??
        switch (row.status) {
          RelationshipStatus.active => '—',
          RelationshipStatus.pending => 'Davet bekliyor',
          RelationshipStatus.declined => 'Davet reddedildi',
        };
    final labelStyle = openable
        ? text.titleMedium
        : text.bodyMedium?.copyWith(color: palette.textMuted);

    final Widget content;
    if (isPanelPhone(context)) {
      // Stacked: the row grows with its text instead of clipping a long name
      // or address at a fixed height.
      content = Container(
        constraints: BoxConstraints(minHeight: density.rowHeight),
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
                  Text(label, style: labelStyle),
                  const SizedBox(height: 2),
                  Text(
                    row.invitedEmail,
                    style: text.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RelationshipStatusPill(status: row.status),
                ],
              ),
            ),
            if (openable) Icon(Icons.chevron_right, color: palette.textMuted),
          ],
        ),
      );
    } else {
      content = Container(
        height: density.rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.borderSubtle)),
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(label, style: labelStyle)),
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
    }

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

/// The raw exception used to be printed here. A dietitian can't act on a
/// PostgrestException; what they can do is try again.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

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
            'Bağlantınızı kontrol edip tekrar deneyin.',
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}

class _NamesErrorNotice extends StatelessWidget {
  const _NamesErrorNotice({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Row(
      children: [
        Icon(Icons.error_outline, size: 18, color: palette.warning),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Danışan adları yüklenemedi; liste adsız gösteriliyor.',
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
      ],
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
          'Bir danışanı e-posta adresiyle davet edebilirsiniz. "Diyetisyen '
          'bul" özelliği açıldığında eşleşmeleriniz de burada görünecek.',
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
