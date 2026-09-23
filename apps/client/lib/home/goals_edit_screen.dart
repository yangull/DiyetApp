import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_widgets.dart';

/// The only place the client's goal, budget range and health note are ever
/// written (PLANNING #104). Without it a client's row stays empty forever and
/// a matched dietitian has nothing to read.
class GoalsEditScreen extends ConsumerStatefulWidget {
  const GoalsEditScreen({super.key, required this.userId, this.detail});

  final String userId;
  final ClientDetail? detail;

  static Future<void> open(
    BuildContext context, {
    required String userId,
    ClientDetail? detail,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GoalsEditScreen(userId: userId, detail: detail),
      ),
    );
  }

  @override
  ConsumerState<GoalsEditScreen> createState() => _GoalsEditScreenState();
}

class _GoalsEditScreenState extends ConsumerState<GoalsEditScreen> {
  late final _goal = TextEditingController(text: widget.detail?.goal ?? '');
  late final _budget = TextEditingController(
    text: widget.detail?.budgetRange ?? '',
  );
  late final _notes = TextEditingController(
    text: widget.detail?.healthNotes ?? '',
  );

  var _saving = false;

  @override
  void dispose() {
    _goal.dispose();
    _budget.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;
    final density = context.density;

    return Scaffold(
      appBar: AppBar(title: const Text('Hedeflerim')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.all(density.pagePadding),
          children: [
            Text(
              'Bu bilgileri yalnızca kabul ettiğin diyetisyen görebilir.',
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _goal,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Hedefim'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _budget,
              decoration: const InputDecoration(labelText: 'Bütçe aralığım'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _notes,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Sağlık notlarım',
                hintText: 'Alerji, hastalık, kullandığın ilaçlar…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Kaydediliyor…' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateClientDetail(
            userId: widget.userId,
            goal: _emptyToNull(_goal.text),
            budgetRange: _emptyToNull(_budget.text),
            healthNotes: _emptyToNull(_notes.text),
          );
      ref.invalidate(clientDetailProvider(widget.userId));
      messenger.showSnackBar(
        const SnackBar(content: Text('Bilgilerin kaydedildi.')),
      );
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Kaydedilemedi. Tekrar dene.')),
      );
      if (mounted) setState(() => _saving = false);
    }
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
