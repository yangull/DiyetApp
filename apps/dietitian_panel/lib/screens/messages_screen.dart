import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/energy.dart';
import '../util/panel_date.dart';
import '../util/breakpoints.dart';
import '../widgets/status_pill.dart';
import '../widgets/tone_pill.dart';
import 'client_detail_screen.dart';

/// In-app messaging, per PLANNING.md P2: chat stays in the product rather than
/// moving to WhatsApp, for one record of care, quality control and KVKK. This
/// screen exists so a dietitian can react to the real thing, not a
/// description of it.
/// Which conversation is open. Outside the screen so the overview's
/// "Mesajı yanıtla" link can open this screen on the right client.
final selectedConversationProvider =
    NotifierProvider<SelectedConversation, String?>(SelectedConversation.new);

class SelectedConversation extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String clientId) => state = clientId;

  /// On a phone the thread is a page: closing it clears the selection, so the
  /// next "Mesajı yanıtla" for the same client opens it again.
  void clear() => state = null;
}

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  /// One draft per client. A single shared controller carried text typed for
  /// one client into the next conversation, where "Gönder" sent it to the
  /// wrong person.
  final _drafts = <String, TextEditingController>{};

  /// True on a phone, and on a window where the thread beside the list would
  /// be narrower than [_minThreadWidth] (a narrow laptop window, large text):
  /// then the list stands alone and a conversation opens as its own page.
  var _singleColumn = false;

  @override
  void dispose() {
    for (final draft in _drafts.values) {
      draft.dispose();
    }
    super.dispose();
  }

  void _openThread(String clientId) {
    final client = ref.read(demoProvider).clientOf(clientId);
    final draft = _drafts.putIfAbsent(clientId, TextEditingController.new);
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(client.name)),
              body: SafeArea(
                top: false,
                child: _ConversationDetail(
                  clientId: clientId,
                  draft: draft,
                  showName: false,
                ),
              ),
            ),
          ),
        )
        .then((_) {
          if (mounted) ref.read(selectedConversationProvider.notifier).clear();
        });
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoProvider);
    final selected = ref.watch(selectedConversationProvider);
    // A client added during an interview disappears on reset.
    final selectedId = demo.clients.any((c) => c.id == selected)
        ? selected!
        : demo.clients.first.id;
    final draft = _drafts.putIfAbsent(selectedId, TextEditingController.new);
    final text = Theme.of(context).textTheme;
    // The client wrote last: reading doesn't clear it, a reply does.
    final awaiting = demo.awaitingReplyCount;
    // Every other tab opens with its name; Mesajlar had none.
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mesajlar', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          awaiting == 0
              ? 'Yanıt bekleyen mesaj yok'
              : '$awaiting yanıt bekleyen konuşma',
          style: text.bodyMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      ],
    );

    // On a phone there is room for one column: the conversation list, and a
    // selected conversation opens as its own page (#38), whoever selected it:
    // a row here or "Mesajı yanıtla" on Genel Bakış. Drafts stay per client.
    ref.listen(selectedConversationProvider, (previous, next) {
      if (next != null && _singleColumn) _openThread(next);
    });
    Widget single() => ListView(
      padding: EdgeInsets.all(context.density.pagePadding),
      children: [
        heading,
        const SizedBox(height: AppSpacing.xl),
        CloudCard(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final client in demo.clients)
                _ConversationRow(
                  client: client,
                  conversation: demo.conversationOf(client.id),
                  selected: false,
                  // Selecting opens the page (the listener above), the
                  // same way "Mesajı yanıtla" on Genel Bakış does.
                  onTap: () => ref
                      .read(selectedConversationProvider.notifier)
                      .select(client.id),
                ),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Three fixed-ish columns need room. On a narrower window the context
        // panel is the one that goes: the thread is the screen's job.
        final showContext = constraints.maxWidth >= 980;
        final listWidth = constraints.maxWidth >= 720 ? 320.0 : 240.0;
        final threadWidth =
            constraints.maxWidth -
            2 * context.density.pagePadding -
            listWidth -
            AppSpacing.lg;
        _singleColumn =
            isPanelPhone(context) ||
            threadWidth <
                _minThreadWidth * MediaQuery.textScalerOf(context).scale(1);
        if (_singleColumn) return single();

        return Padding(
          padding: EdgeInsets.all(context.density.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading,
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: listWidth,
                      child: CloudCard(
                        clipBehavior: Clip.antiAlias,
                        // Scrolls on its own: with 40 clients a plain Column ran
                        // off the bottom and the later conversations were
                        // unreachable.
                        child: ListView(
                          children: [
                            for (final client in demo.clients)
                              _ConversationRow(
                                client: client,
                                conversation: demo.conversationOf(client.id),
                                selected: client.id == selectedId,
                                onTap: () => ref
                                    .read(selectedConversationProvider.notifier)
                                    .select(client.id),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    // On the white canvas, not in a card, so the client's Cloud
                    // Card bubbles read (Can, C27).
                    Expanded(
                      child: _ConversationDetail(
                        clientId: selectedId,
                        draft: draft,
                      ),
                    ),
                    if (showContext) ...[
                      const SizedBox(width: AppSpacing.lg),
                      SizedBox(
                        width: 300,
                        child: _ClientContextPanel(clientId: selectedId),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    required this.client,
    required this.conversation,
    required this.selected,
    required this.onTap,
  });

  final DemoClient client;
  final Conversation conversation;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final last = conversation.lastMessage;

    // The open conversation is a white band in the Cloud Card list, and says
    // so to a screen reader; "Yanıt bekliyor" is read from its pill.
    return Semantics(
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: selected ? palette.inset : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonAvatar(name: client.name),
              const SizedBox(width: ActionRow.gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.name,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              fontWeight: conversation.awaitsReply
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (last != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          // Today: the time; before that: the day.
                          Text(
                            DateUtils.isSameDay(last.sentAt, DateTime.now())
                                ? formatTime(last.sentAt)
                                : formatDate(last.sentAt),
                            style: text.bodySmall?.copyWith(
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      last == null ? 'Henüz mesaj yok' : last.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: palette.textSecondary,
                        fontWeight: conversation.awaitsReply
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    // In words, not a dot alone: a waiting message is news the
                    // eye finds without reading the preview.
                    if (conversation.awaitsReply) ...[
                      const SizedBox(height: AppSpacing.xs),
                      // The selected row is the card's inset colour, so its
                      // neutral pill takes the card's colour instead, or it
                      // vanishes into the band.
                      Theme(
                        data: selected
                            ? Theme.of(context).copyWith(
                                extensions: [
                                  ...Theme.of(context).extensions.values
                                      .where((e) => e is! AppPalette),
                                  palette.copyWith(inset: palette.cloudCard),
                                ],
                              )
                            : Theme.of(context),
                        child: const TonePill(
                          label: 'Yanıt bekliyor',
                          tone: PillTone.neutral,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Beside the thread, what you need in order to answer a message: the day's
/// target, what the plan says, and what this client cannot eat. Answering "mercimek çorbası + salata olur mu?"
/// should not mean leaving the screen.
class _ClientContextPanel extends ConsumerWidget {
  const _ClientContextPanel({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(clientId);
    final plan = demo.planFor(clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final mealStyle = text.bodySmall!.copyWith(color: palette.textSecondary);

    // Scrolls on a short window: the facts and the day's meals are taller
    // than a laptop in landscape leaves under the heading.
    return CloudCard(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.name, style: text.titleMedium),
            Text(
              client.goal,
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ContextFact(
              label: 'Günlük hedef',
              value: '${plan.kcal} kcal',
              hint: 'hesaplanan ${targetEnergy(client)} kcal',
            ),
            Text(
              'Plan durumu',
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            // A status, so the same pill as the client list and record.
            StatusPill(state: plan.state),
            const SizedBox(height: AppSpacing.md),
            _ContextFact(label: 'Beslenme tipi', value: client.dietType),
            // What to be careful about, as pills, not amber words in a grid.
            if (client.allergies.isNotEmpty ||
                client.chronicConditions.isNotEmpty) ...[
              Text(
                'Dikkat edilecekler',
                style: text.bodySmall?.copyWith(color: palette.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final item in [
                    ...client.allergies,
                    ...client.chronicConditions,
                  ])
                    TonePill(label: item, tone: PillTone.warning),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Divider(color: palette.divider),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bugünün öğünleri',
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            // The times in a fixed, right-aligned slot so the meal names
            // start on one edge (Alpino has no tabular figures, #135).
            for (final meal in plan.meals)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A minimum, not a fixed width: the time is free text in
                    // the plan editor and may be longer than "00:00".
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: numberSlotWidth(context, '00:00', mealStyle),
                      ),
                      child: Text(
                        meal.time,
                        textAlign: TextAlign.end,
                        style: mealStyle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(meal.name, style: mealStyle)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContextFact extends StatelessWidget {
  const _ContextFact({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(value, style: text.bodyMedium),
          if (hint != null)
            Text(
              hint!,
              style: text.bodySmall?.copyWith(color: palette.textSecondary),
            ),
        ],
      ),
    );
  }
}

void _openClient(BuildContext context, String clientId) => Navigator.of(context)
    .push(
      MaterialPageRoute<void>(
        builder: (_) => ClientDetailScreen(clientId: clientId),
      ),
    );

/// Narrower than this (at 1× text) the thread's header and composer don't fit
/// beside the list, so the list stands alone.
const _minThreadWidth = 320.0;

/// The message field never gets narrower than this (at 1× text) to make room
/// for the button's label.
const _minFieldWidth = 160.0;

class _ConversationDetail extends ConsumerWidget {
  const _ConversationDetail({
    required this.clientId,
    required this.draft,
    this.showName = true,
  });

  final String clientId;
  final TextEditingController draft;

  /// False on a phone, where the page's app bar already names the client.
  final bool showName;

  void _send(WidgetRef ref) {
    final text = draft.text;
    if (text.trim().isEmpty) return;
    ref.read(demoProvider.notifier).sendMessage(clientId, text);
    draft.clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(clientId);
    final conversation = demo.conversationOf(clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Who this is and where to go from here: the avatar, the name and
        // goal, and a way to the client's record. On a phone the page's app
        // bar already names them.
        // When the column is narrow the action drops under the name instead
        // of pushing the row off the edge.
        if (showName)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              AppSpacing.md,
              0,
              AppSpacing.sm,
            ),
            child: ActionRow(
              lead: PersonAvatar(name: client.name),
              leadWidth: context.density.avatarSize,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name, style: text.titleMedium),
                  Text(
                    client.goal,
                    style: text.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
              actionLabel: 'Danışanı aç',
              onAction: () => _openClient(context, clientId),
            ),
          ),
        // On a phone the page's app bar names the client; the way to their
        // record is a line of its own under it (an app bar action overflowed
        // beside a long name at large text).
        if (!showName)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: EdgeButton(
                child: TextButton(
                  onPressed: () => _openClient(context, clientId),
                  child: const Text('Danışanı aç'),
                ),
              ),
            ),
          ),
        Expanded(
          child: conversation.messages.isEmpty
              ? Center(
                  child: Text(
                    'Bu danışanla henüz mesajlaşmadınız.',
                    style: text.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                )
              // Starts at the top while the thread is short (no empty half
              // above it) and sticks to the newest message once it is long.
              : LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                      horizontal: showName ? 0 : AppSpacing.lg,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(
                          0,
                          constraints.maxHeight - 2 * AppSpacing.lg,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final message in conversation.messages)
                            _MessageBubble(message: message),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        Padding(
          padding: EdgeInsets.all(showName ? 0 : AppSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // A word with the icon: a lone paper plane is a guess. Where the
              // word would squeeze the field (a narrow column, large text) the
              // button falls back to the icon with a tooltip (rule 13).
              final labelWidth =
                  textButtonWidth(context, 'Gönder', icon: true) +
                  2 * AppSpacing.lg;
              final labelled =
                  constraints.maxWidth - labelWidth - AppSpacing.sm >=
                  _minFieldWidth * MediaQuery.textScalerOf(context).scale(1);
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: draft,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Mesaj yazın…',
                      ),
                      onSubmitted: (_) => _send(ref),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  labelled
                      ? FilledButton.icon(
                          onPressed: () => _send(ref),
                          icon: const Icon(AppIcons.send, size: 18),
                          label: const Text('Gönder'),
                        )
                      : IconButton.filled(
                          tooltip: 'Gönder',
                          onPressed: () => _send(ref),
                          icon: const Icon(AppIcons.send, size: 18),
                        ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final fromDietitian = message.sender == MessageSender.dietitian;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: fromDietitian
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                // Charcoal for the dietitian's own words, Cloud Card for the
                // client's: both opaque and measured (C27). Cloud Card text on
                // Charcoal is 14.21:1.
                decoration: BoxDecoration(
                  color: fromDietitian
                      ? context.palette.charcoal
                      : palette.cloudCard,
                  borderRadius: BorderRadius.circular(
                    context.density.cardRadius,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: text.bodyMedium?.copyWith(
                        color: fromDietitian ? palette.onCharcoal : palette.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // The day too once it isn't today, like the list rows: a
                    // message from two days ago read as this morning's.
                    Text(
                      DateUtils.isSameDay(message.sentAt, DateTime.now())
                          ? formatTime(message.sentAt)
                          : '${formatDate(message.sentAt)} '
                                '${formatTime(message.sentAt)}',
                      style: text.bodySmall?.copyWith(
                        color: fromDietitian
                            ? palette.onCharcoal
                            : palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
