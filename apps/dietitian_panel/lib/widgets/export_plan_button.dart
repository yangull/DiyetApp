import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Hands the plan over as a printable document.
///
/// Disabled until the plan is approved: a PDF is the one artifact that leaves
/// the panel and reaches a client, so locked decision §2 #1 — no unapproved AI
/// plan reaches a client — is enforced here too, not only in the UI that shows
/// the draft.
class ExportPlanButton extends StatefulWidget {
  const ExportPlanButton({
    super.key,
    required this.enabled,
    required this.filename,
    required this.build,
  });

  final bool enabled;
  final String filename;
  final Future<Uint8List> Function() build;

  @override
  State<ExportPlanButton> createState() => _ExportPlanButtonState();
}

class _ExportPlanButtonState extends State<ExportPlanButton> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final bytes = await widget.build();
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: widget.filename,
      );
    } catch (error) {
      if (!mounted) return;
      // Printing goes through the browser, which can decline for reasons the
      // panel cannot see. Say so rather than leaving a dead button.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('PDF oluşturulamadı: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: widget.enabled && !_busy ? _export : null,
          icon: _busy
              ? const ButtonSpinner(size: 16)
              : const Icon(AppIcons.pdf, size: 18),
          label: const Text('PDF olarak ver'),
        ),
        if (!widget.enabled)
          Text(
            'Plan onaylanmadan danışana verilemez.',
            style: text.bodySmall?.copyWith(color: palette.textSecondary),
          ),
      ],
    );
  }
}
