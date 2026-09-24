import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/energy.dart';
import '../util/panel_date.dart';
import '../util/turkish.dart';
import '../util/breakpoints.dart';

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

  @override
  void dispose() {
    for (final draft in _drafts.values) {
      draft.dispose();
    }
    super.dispose();
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
    final unread = demo.clients
        .where((c) => demo.conversationOf(c.id).hasUnread)
        .length;
    // Every other tab opens with its name; Mesajlar had none.
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mesajlar', style: text.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          unread == 0 ? 'Hepsi okundu' : '$unread okunmamış konuşma',
          style: text.bodyMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      ],
    );

    // On a phone there is room for one column: the conversation list, and a
    // tap opens the thread as its own page (#38). Drafts stay per client.
    if (isPanelPhone(context)) {
      return ListView(
        padding: EdgeInsets.all(context.density.pagePadding),
        children: [
          heading,
          const SizedBox(height: AppSpacing.xl),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final client in demo.clients)
                  _ConversationRow(
                    client: client,
                    conversation: demo.conversationOf(client.id),
                    selected: false,
                    onTap: () {
                      ref
                          .read(selectedConversationProvider.notifier)
                          .select(client.id);
                      final threadDraft = _drafts.putIfAbsent(
                        client.id,
                        TextEditingController.new,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: Text(client.name)),
                            body: SafeArea(
                              top: false,
                              child: _ConversationDetail(
                                clientId: client.id,
                                draft: threadDraft,
                                showName: false,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Three fixed-ish columns need room. On a narrower window the context
        // panel is the one that goes: the thread is the screen's job.
        final showContext = constraints.maxWidth >= 980;
        final listWidth = constraints.maxWidth >= 720 ? 320.0 : 240.0;

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
                      child: Card(
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
                    // On the grey ground, not in a card, so the client's white
                    // bubbles read (Can, C27).
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

    return Semantics(
      label: conversation.hasUnread ? 'okunmamış mesaj' : null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: selected ? palette.surfaceSubtle : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: text.titleMedium?.copyWith(
                        fontWeight: conversation.hasUnread
                            ? FontWeight.w700
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      last == null ? 'Henüz mesaj yok' : last.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: conversation.hasUnread
                            ? palette.textSecondary
                            : palette.textMuted,
                        fontWeight: conversation.hasUnread
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Black, not green: unread is news, not an action. The bold
              // name and preview carry it too.
              if (conversation.hasUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The thread is bottom-anchored like every chat app, which left the top of
/// the panel empty. Rather than move the messages, the space now carries what
/// you need in order to answer one: the day's target, what the plan says, and
/// what this client cannot eat. Answering "mercimek çorbası + salata olur mu?"
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

    // Scrolls on a short window: the facts and the day's meals are taller
    // than a laptop in landscape leaves under the heading.
    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(client.name, style: text.titleLarge),
            Text(
              client.goal,
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ContextFact(
              label: 'Günlük hedef',
              value: '${plan.kcal} kcal',
              hint: 'hesaplanan ${targetEnergy(client)} kcal',
            ),
            _ContextFact(
              label: 'Plan durumu',
              value: plan.isDraft ? 'Onay bekliyor' : 'Onaylandı',
            ),
            _ContextFact(label: 'Beslenme tipi', value: client.dietType),
            _ContextFact(
              label: 'Alerji / hassasiyet',
              value: client.allergies.isEmpty
                  ? '—'
                  : client.allergies.join(', '),
              warn: client.allergies.isNotEmpty,
            ),
            _ContextFact(
              label: 'Kronik rahatsızlık',
              value: client.chronicConditions.isEmpty
                  ? '—'
                  : client.chronicConditions.join(', '),
              warn: client.chronicConditions.isNotEmpty,
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: palette.borderSubtle),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bugünün öğünleri',
              style: text.labelSmall?.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final meal in plan.meals)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${meal.time}  ${meal.name}',
                  style: text.bodySmall?.copyWith(color: palette.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContextFact extends StatelessWidget {
  const _ContextFact({
    required this.label,
    required this.value,
    this.hint,
    this.warn = false,
  });

  final String label;
  final String value;
  final String? hint;
  final bool warn;

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
            trUpper(label),
            style: text.labelSmall?.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: text.bodyMedium?.copyWith(
              color: warn ? palette.warning : null,
            ),
          ),
          if (hint != null)
            Text(
              hint!,
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
        ],
      ),
    );
  }
}

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
        if (showName)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              AppSpacing.md,
              0,
              AppSpacing.sm,
            ),
            child: Text(client.name, style: text.titleLarge),
          ),
        Expanded(
          child: conversation.messages.isEmpty
              ? Center(
                  child: Text(
                    'Bu danışanla henüz mesajlaşmadınız.',
                    style: text.bodyMedium?.copyWith(color: palette.textMuted),
                  ),
                )
              : ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                    horizontal: showName ? 0 : AppSpacing.lg,
                  ),
                  children: [
                    for (final message in conversation.messages.reversed)
                      _MessageBubble(message: message),
                  ],
                ),
        ),
        Padding(
          padding: EdgeInsets.all(showName ? 0 : AppSpacing.md),
          child: Row(
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
              IconButton(
                tooltip: 'Gönder',
                onPressed: () => _send(ref),
                icon: const Icon(Icons.send_outlined),
              ),
            ],
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
                // White for the client on the grey ground, the pale tint
                // for the dietitian: both measured, both opaque (C27).
                decoration: BoxDecoration(
                  color: fromDietitian
                      ? palette.primaryTint
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    context.density.cardRadius,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.text, style: text.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      formatTime(message.sentAt),
                      style: text.bodySmall?.copyWith(color: palette.textMuted),
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
