import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import '../util/breakpoints.dart';
import 'plan_editor_screen.dart';
import '../widgets/readable_width.dart';

/// The anamnez form, and it is a guess on purpose.
///
/// Everything above "Anamnez" maps onto a real [DemoClient] field. Everything
/// below it does not exist in the model at all — those questions are here so a
/// dietitian can strike out the ones nobody asks, add the ones we missed, and
/// tell us which answers change a plan. Their replies are folded into the
/// client's free-text note rather than modelled, because modelling them before
/// the interview is exactly the mistake this screen is meant to prevent.
class IntakeFormScreen extends ConsumerStatefulWidget {
  const IntakeFormScreen({super.key});

  @override
  ConsumerState<IntakeFormScreen> createState() => _IntakeFormScreenState();
}

class _IntakeFormScreenState extends ConsumerState<IntakeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _targetWeight = TextEditingController();
  final _goal = TextEditingController(text: 'Kilo verme');
  final _dietType = TextEditingController(text: 'standart');
  final _allergies = TextEditingController();
  final _conditions = TextEditingController();
  final _medications = TextEditingController();
  final _note = TextEditingController();

  /// The unmodelled half. Keyed by the label shown on screen so the note can
  /// be written back in the dietitian's own words.
  final _anamnesis = <String, TextEditingController>{
    'Öğün düzeni (kaç öğün, saatleri)': TextEditingController(),
    'Su tüketimi': TextEditingController(),
    'Uyku düzeni': TextEditingController(),
    'Sigara / alkol': TextEditingController(),
    'Bağırsak düzeni': TextEditingController(),
    'Ailede kronik hastalık': TextEditingController(),
    'Daha önce uygulanan diyetler': TextEditingController(),
    'Sevmediği / yemediği besinler': TextEditingController(),
    'Son tahlil sonucu var mı': TextEditingController(),
  };

  /// Which anamnez questions sit under which heading.
  static const _groups = [
    (
      'Beslenme alışkanlıkları',
      [
        'Öğün düzeni (kaç öğün, saatleri)',
        'Su tüketimi',
        'Sevmediği / yemediği besinler',
      ],
    ),
    ('Yaşam tarzı', ['Uyku düzeni', 'Sigara / alkol', 'Bağırsak düzeni']),
    (
      'Sağlık geçmişi',
      [
        'Ailede kronik hastalık',
        'Daha önce uygulanan diyetler',
        'Son tahlil sonucu var mı',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // A question missing from the groups would vanish from the form.
    assert(
      {..._groups.expand((g) => g.$2)}.length == _anamnesis.length &&
          _groups.expand((g) => g.$2).every(_anamnesis.containsKey),
      'every anamnez question belongs to exactly one group',
    );
  }

  Sex _sex = Sex.kadin;
  ActivityLevel _activity = ActivityLevel.ortaAktif;

  /// Compared with the starting values rather than tracked on every
  /// keystroke, so typing and deleting a letter does not count as a change.
  bool get _dirty =>
      _sex != Sex.kadin ||
      _activity != ActivityLevel.ortaAktif ||
      _goal.text != 'Kilo verme' ||
      _dietType.text != 'standart' ||
      [
        _name,
        _age,
        _height,
        _weight,
        _targetWeight,
        _allergies,
        _conditions,
        _medications,
        _note,
        ..._anamnesis.values,
      ].any((c) => c.text.trim().isNotEmpty);

  /// Both exits come through here, the app-bar back arrow and "Vazgeç": a
  /// half-filled anamnez is too much work to lose to one click.
  Future<void> _confirmLeave() async {
    final navigator = Navigator.of(context);
    if (!_dirty) {
      navigator.pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değişiklikler kaydedilmedi'),
        content: const Text(
          'Çıkarsanız bu formda girdiğiniz bilgiler silinir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Düzenlemeye dön'),
          ),
          FilledButton(
            style: AppTheme.destructive(context),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil ve çık'),
          ),
        ],
      ),
    );
    if (leave ?? false) navigator.pop();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _age,
      _height,
      _weight,
      _targetWeight,
      _goal,
      _dietType,
      _allergies,
      _conditions,
      _medications,
      _note,
      ..._anamnesis.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = context.palette;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Yeni danışan')),
        // The actions stay in view however long the form is, as in the plan
        // editor.
        bottomNavigationBar: _ActionBar(onSave: _save, onLeave: _confirmLeave),
        body: Form(
          key: _formKey,
          child: LayoutBuilder(
            // Not a lazy ListView: validate() only reaches fields that are
            // built, and the first error has to be found to be shown.
            builder: (context, constraints) => SingleChildScrollView(
              padding: readablePadding(
                constraints.maxWidth,
                context.density.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Temel bilgiler', style: text.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  CloudCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _row([
                            _field(_name, 'Ad soyad', required: true),
                            _number(_age, 'Yaş', min: 10, max: 100),
                            _dropdown<Sex>(
                              label: 'Cinsiyet',
                              value: _sex,
                              entries: {Sex.kadin: 'Kadın', Sex.erkek: 'Erkek'},
                              onChanged: (v) => setState(() => _sex = v),
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.lg),
                          _row([
                            _number(_height, 'Boy (cm)', min: 100, max: 230),
                            _number(_weight, 'Kilo (kg)', min: 30, max: 300),
                            _number(
                              _targetWeight,
                              'Hedef kilo (kg)',
                              min: 30,
                              max: 300,
                              optional: true,
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.lg),
                          _row([
                            _field(_goal, 'Hedef'),
                            _dropdown<ActivityLevel>(
                              label: 'Hareket düzeyi',
                              value: _activity,
                              entries: const {
                                ActivityLevel.sedanter: 'Hareketsiz',
                                ActivityLevel.hafifAktif: 'Az hareketli',
                                ActivityLevel.ortaAktif: 'Orta hareketli',
                                ActivityLevel.aktif: 'Hareketli',
                                ActivityLevel.cokAktif: 'Çok hareketli',
                              },
                              onChanged: (v) => setState(() => _activity = v),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Sağlık bilgileri', style: text.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  CloudCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _row([
                            _field(_dietType, 'Beslenme tipi'),
                            _field(
                              _allergies,
                              'Alerji / hassasiyet',
                              hint: 'virgülle ayırın',
                            ),
                            _field(
                              _conditions,
                              'Kronik rahatsızlık',
                              hint: 'virgülle ayırın',
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.lg),
                          _row([
                            _field(
                              _medications,
                              'İlaç / takviye',
                              hint: 'virgülle ayırın',
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Anamnez', style: text.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bu bölümdeki sorular bizim tahminimiz — ilk görüşmede gerçekte '
                    'neleri sorduğunuzu bilmiyoruz. Sormadıklarınızı çizin, eksik '
                    'olanları söyleyin: hangi cevap planı değiştiriyorsa onu '
                    'modellemek istiyoruz.',
                    style: text.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CloudCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Grouped so nine questions read as three topics. The
                          // groups are a guess too (DT7 is still open).
                          for (final (i, group) in _groups.indexed) ...[
                            if (i > 0) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Divider(color: palette.divider),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            Text(group.$1, style: text.titleMedium),
                            const SizedBox(height: AppSpacing.md),
                            _row([
                              for (final label in group.$2)
                                _field(_anamnesis[label]!, label),
                            ]),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          Divider(color: palette.divider),
                          const SizedBox(height: AppSpacing.lg),
                          _row([
                            _field(_note, 'Diğer notlar', maxLines: 3),
                          ], cols: 1),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Kaydettiğinizde bu bilgilerden hesaplanan enerji hedefiyle bir '
                    'yapay zekâ taslağı hazırlanır ve onayınıza düşer.',
                    style: text.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Brings the first field with an error into view, after the frame that
  /// draws the errors: a bar pinned at the bottom can say "Kaydet" from any
  /// scroll position, so the invalid field may be far above.
  void _showFirstError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      BuildContext? first;
      void visit(Element element) {
        if (first != null) return;
        if (element is StatefulElement &&
            element.state is FormFieldState &&
            (element.state as FormFieldState).hasError) {
          first = element;
          return;
        }
        element.visitChildren(visit);
      }

      (_formKey.currentContext as Element?)?.visitChildren(visit);
      final target = first;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          alignment: 0.1,
          duration: AppMotion.of(context, AppMotion.pop),
        );
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      _showFirstError();
      return;
    }

    // In the order they are shown, group by group.
    final anamnesis = [
      for (final group in _groups)
        for (final label in group.$2)
          if (_anamnesis[label]!.text.trim().isNotEmpty)
            '$label: ${_anamnesis[label]!.text.trim()}',
    ];
    final note = [
      if (_note.text.trim().isNotEmpty) _note.text.trim(),
      ...anamnesis,
    ].join('\n');

    final client = DemoClient(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      age: double.parse(_age.text.trim().replaceAll(',', '.')).round(),
      sex: _sex,
      heightCm: double.parse(_height.text.trim().replaceAll(',', '.')).round(),
      weightKg: double.parse(_weight.text.trim().replaceAll(',', '.')),
      goal: _goal.text.trim().isEmpty ? 'Belirtilmedi' : _goal.text.trim(),
      targetWeightKg: _targetWeight.text.trim().isEmpty
          ? null
          : double.parse(_targetWeight.text.trim().replaceAll(',', '.')),
      activityLevel: _activity,
      dietType: _dietType.text.trim().isEmpty
          ? 'standart'
          : _dietType.text.trim(),
      allergies: _split(_allergies.text),
      chronicConditions: _split(_conditions.text),
      medications: _split(_medications.text),
      note: note,
      startedOn: DateTime.now(),
    );

    ref.read(demoProvider.notifier).addClient(client);
    final navigator = Navigator.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${client.name} eklendi, ilk taslak hazırlandı.')),
    );
    navigator.pop();
    navigator.push(
      MaterialPageRoute(builder: (_) => PlanEditorScreen(clientId: client.id)),
    );
  }

  static List<String> _split(String raw) => [
    for (final part in raw.split(','))
      if (part.trim().isNotEmpty) part.trim(),
  ];

  /// Width lives here rather than in the field helpers, so a field can also
  /// be used on its own in a Column — an `Expanded` baked into the helper
  /// meant vertical flex with unbounded height the moment one was, which is a
  /// crash.
  ///
  /// Wide, every row is on the same grid: [cols] equal columns (three by
  /// default), so field edges line up from row to row, and a row with fewer
  /// fields leaves the rest empty. On a phone every field gets its own line:
  /// three to a row left "Yaş" as "Y…" and overflowed the dropdown.
  Widget _row(List<Widget> children, {int cols = 3}) {
    assert(children.length <= cols);
    if (isPanelPhone(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            children[i],
          ],
        ],
      );
    }
    const gap = AppSpacing.lg;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - (cols - 1) * gap) / cols;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              SizedBox(width: width, child: children[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return LabeledField(
      label: label,
      controller: controller,
      maxLines: maxLines,
      hint: hint,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Zorunlu alan' : null
          : null,
    );
  }

  Widget _number(
    TextEditingController controller,
    String label, {
    required num min,
    required num max,
    bool optional = false,
  }) {
    return LabeledField(
      label: label,
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (v) {
        final raw = (v ?? '').trim().replaceAll(',', '.');
        if (raw.isEmpty) return optional ? null : 'Zorunlu alan';
        final value = double.tryParse(raw);
        if (value == null) return 'Sayı girin';
        if (value < min || value > max) return '$min – $max arası';
        return null;
      },
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required Map<T, String> entries,
    required ValueChanged<T> onChanged,
  }) {
    return LabeledDropdown<T>(
      label: label,
      value: value,
      items: [
        for (final entry in entries.entries)
          DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// "Kaydet" and "Vazgeç" pinned to the bottom, so the form's two exits are
/// always reachable: on a wide screen at the right, on a phone full width.
class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onSave, required this.onLeave});

  final VoidCallback onSave;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final save = FilledButton(
      onPressed: onSave,
      child: const Text('Kaydet ve taslak oluştur'),
    );
    final leave = TextButton(onPressed: onLeave, child: const Text('Vazgeç'));
    return Container(
      decoration: BoxDecoration(
        color: context.palette.canvas,
        border: Border(top: BorderSide(color: context.palette.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: isPanelPhone(context)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    save,
                    const SizedBox(height: AppSpacing.xs),
                    leave,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    leave,
                    const SizedBox(width: AppSpacing.md),
                    save,
                  ],
                ),
        ),
      ),
    );
  }
}
