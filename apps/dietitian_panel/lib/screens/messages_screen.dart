import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../util/panel_date.dart';

/// In-app messaging, per locked decision §2 #2 — chat stays in the product
/// rather than moving to WhatsApp, to protect commission revenue. HANDOFF.md
/// §3 flags this as the decision most likely to get pushback in interviews;
/// this screen exists so a dietitian can react to the real thing, not a
/// description of it.
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  String? _selectedClientId;

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoProvider);
    final selectedId = _selectedClientId ?? demo.clients.first.id;

    return Padding(
      padding: EdgeInsets.all(context.density.pagePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 320,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final client in demo.clients)
                    _ConversationRow(
                      client: client,
                      conversation: demo.conversationOf(client.id),
                      selected: client.id == selectedId,
                      onTap: () =>
                          setState(() => _selectedClientId = client.id),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: _ConversationDetail(clientId: selectedId),
            ),
          ),
        ],
      ),
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

    return InkWell(
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
                  Text(client.name, style: text.titleMedium),
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
            if (conversation.hasUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConversationDetail extends ConsumerStatefulWidget {
  const _ConversationDetail({required this.clientId});

  final String clientId;

  @override
  ConsumerState<_ConversationDetail> createState() =>
      _ConversationDetailState();
}

class _ConversationDetailState extends ConsumerState<_ConversationDetail> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    ref.read(demoProvider.notifier).sendMessage(widget.clientId, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoProvider);
    final client = demo.clientOf(widget.clientId);
    final conversation = demo.conversationOf(widget.clientId);
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.borderSubtle)),
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
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    for (final message in conversation.messages.reversed)
                      _MessageBubble(message: message),
                  ],
                ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: palette.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Mesaj yazın…',
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: _send,
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
                decoration: BoxDecoration(
                  color: fromDietitian
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : palette.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
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
