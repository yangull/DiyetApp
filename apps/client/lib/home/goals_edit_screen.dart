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
    final density = context.density;

    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Hedeflerim')),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.all(density.pagePadding),
            children: [
              const _PrivacyNote(),
              const SizedBox(height: AppSpacing.xl),
              LabeledField(
                label: 'Hedefim',
                hint: 'Örn. 5 kilo vermek, daha dengeli beslenmek',
                controller: _goal,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.md),
              LabeledField(
                label: 'Bütçe aralığım',
                hint: 'Örn. ayda 1.000–2.000 TL',
                controller: _budget,
              ),
              const SizedBox(height: AppSpacing.md),
              LabeledField(
                label: 'Sağlık notlarım',
                hint: 'Alerji, hastalık, kullandığın ilaçlar…',
                controller: _notes,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Kaydediliyor…' : 'Kaydet'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Vazgeç'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    // "Tekrar dene" lives on the root messenger and can outlast this screen.
    if (_saving || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final onSnack = context.palette.onCharcoal;
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
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, size: 20, color: onSnack),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: Text('Kaydedilemedi.')),
            ],
          ),
          action: SnackBarAction(label: 'Tekrar dene', onPressed: _save),
        ),
      );
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// The reassurance that matters on this screen, so it is a card with a lock,
/// not a footnote.
class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return CloudCard(
      child: Padding(
        padding: EdgeInsets.all(context.density.cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, size: 22, color: palette.ink),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Bu bilgileri yalnızca kabul ettiğin diyetisyen görebilir.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: palette.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
