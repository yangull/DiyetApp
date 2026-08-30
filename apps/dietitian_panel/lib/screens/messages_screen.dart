import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../demo/energy.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Three fixed-ish columns need room. On a narrower window the context
        // panel is the one that goes: the thread is the screen's job.
        final showContext = constraints.maxWidth >= 980;
        final listWidth = constraints.maxWidth >= 720 ? 320.0 : 240.0;

        return Padding(
          padding: EdgeInsets.all(context.density.pagePadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: listWidth,
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
              if (showContext) ...[
                const SizedBox(width: AppSpacing.lg),
                SizedBox(
                  width: 300,
                  child: _ClientContextPanel(clientId: selectedId),
                ),
              ],
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

    return Card(
      child: Padding(
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
            label.toUpperCase(),
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
