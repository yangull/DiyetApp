import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/edge_button.dart';
import '../theme/tokens/app_spacing.dart';
import 'cloud_card.dart';
import 'wellkit_mark.dart';

/// The one waiting state: a spinner with an optional line under it, centred.
/// [AppLoading.card] reserves a card's height instead, so the page doesn't
/// jump when the data arrives.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.label}) : card = false;

  const AppLoading.card({super.key, this.label}) : card = true;

  /// Read aloud, and shown under the spinner.
  final String? label;
  final bool card;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final palette = context.palette;
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!card) ...[
          const WellkitMark(size: 40),
          const SizedBox(height: AppSpacing.lg),
        ],
        // The visible line is what a screen reader reads, once.
        CircularProgressIndicator(
          semanticsLabel: label == null ? 'Yükleniyor' : null,
        ),
        if (label != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: palette.textSecondary),
          ),
        ],
      ],
    );
    if (!card) return Center(child: body);
    return CloudCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 168),
        child: Center(child: body),
      ),
    );
  }
}

/// The small spinner inside a button that is waiting on a request.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: const CircularProgressIndicator(strokeWidth: 2),
  );
}

enum _ErrorShape { page, card, notice }

/// Something failed, said in words the person can act on (never the raw
/// exception). Retry is the main action ([onRetry], the filled pill); the
/// quiet one beside it ([actionLabel], an Ink text action) is for the way out:
/// "Çıkış yap", or an action that doesn't need the failed data.
///
/// [AppErrorView] fills the page, centred; [AppErrorView.card] sits in a
/// Cloud Card, left-aligned; [AppErrorView.notice] is one line with a text
/// retry, for a part of a screen that still works.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.error_outline,
  }) : assert((actionLabel == null) == (onAction == null)),
       _shape = _ErrorShape.page;

  const AppErrorView.card({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.error_outline,
  }) : assert((actionLabel == null) == (onAction == null)),
       _shape = _ErrorShape.card;

  const AppErrorView.notice({
    super.key,
    required String message,
    required VoidCallback this.onRetry,
  }) : title = message,
       message = null,
       actionLabel = null,
       onAction = null,
       icon = Icons.error_outline,
       _shape = _ErrorShape.notice;

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final _ErrorShape _shape;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    if (_shape == _ErrorShape.notice) {
      return Row(
        children: [
          Icon(icon, size: 18, color: palette.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
          ),
          EdgeButton(
            end: true,
            child: TextButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ),
        ],
      );
    }

    final centred = _shape == _ErrorShape.page;
    final message = this.message;
    final retry = onRetry;
    final action = onAction;
    final actionLabel = this.actionLabel;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centred
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Icon(icon, size: centred ? 40 : 28, color: palette.textSecondary),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          liveRegion: true,
          child: Text(
            title,
            style: centred ? text.titleLarge : text.headlineSmall,
            textAlign: centred ? TextAlign.center : TextAlign.start,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            textAlign: centred ? TextAlign.center : TextAlign.start,
          ),
        ],
        if (retry != null || (action != null && actionLabel != null)) ...[
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: centred ? WrapAlignment.center : WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (retry != null)
                FilledButton(
                  onPressed: retry,
                  child: const Text('Tekrar dene'),
                ),
              if (action != null && actionLabel != null)
                TextButton(onPressed: action, child: Text(actionLabel)),
            ],
          ),
        ],
      ],
    );

    if (centred) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: content,
          ),
        ),
      );
    }
    return CloudCard(
      child: Padding(
        padding: EdgeInsets.all(context.density.cardPadding),
        child: content,
      ),
    );
  }
}

/// Nothing here yet: what it is, and what to do about it. The action is a
/// pill only when it is the first step ([onAction] with [actionLabel]).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final message = this.message;
    final icon = this.icon;
    final actionLabel = this.actionLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 28, color: palette.textSecondary),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(title, style: text.titleLarge),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ],
    );
  }
}
