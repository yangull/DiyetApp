import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../demo/demo_models.dart';
import '../demo/demo_repository.dart';
import 'plan_editor_screen.dart';

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

  Sex _sex = Sex.kadin;
  ActivityLevel _activity = ActivityLevel.ortaAktif;

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

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni danışan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(context.density.pagePadding),
          children: [
            Text('Temel bilgiler', style: text.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _row(
                      [
                        _field(_name, 'Ad soyad', required: true),
                        _number(_age, 'Yaş', min: 10, max: 100),
                        _dropdown<Sex>(
                          label: 'Cinsiyet',
                          value: _sex,
                          entries: {Sex.kadin: 'Kadın', Sex.erkek: 'Erkek'},
                          onChanged: (v) => setState(() => _sex = v),
                        ),
                      ],
                      flex: [3, 1, 1],
                    ),
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
                    _row(
                      [
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
                      ],
                      flex: [2, 2],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Sağlık bilgileri', style: text.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _row(
                      [
                        _field(_dietType, 'Beslenme tipi'),
                        _field(
                          _allergies,
                          'Alerji / hassasiyet',
                          hint: 'virgülle ayırın',
                        ),
                      ],
                      flex: [1, 2],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _row([
                      _field(
                        _conditions,
                        'Kronik rahatsızlık',
                        hint: 'virgülle ayırın',
                      ),
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
              style: text.bodyMedium?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    for (final entry in _anamnesis.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _field(entry.value, entry.key),
                      ),
                    _field(_note, 'Diğer notlar', maxLines: 3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                FilledButton(
                  onPressed: _save,
                  child: const Text('Kaydet ve taslak oluştur'),
                ),
                const SizedBox(width: AppSpacing.md),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Vazgeç'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kaydettiğinizde bu bilgilerden hesaplanan enerji hedefiyle bir '
              'AI taslağı hazırlanır ve onayınıza düşer.',
              style: text.bodySmall?.copyWith(color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final anamnesis = [
      for (final entry in _anamnesis.entries)
        if (entry.value.text.trim().isNotEmpty)
          '${entry.key}: ${entry.value.text.trim()}',
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

  /// Flex lives here rather than in the field helpers, so a field can also be
  /// used on its own in a Column — an `Expanded` baked into the helper meant
  /// vertical flex with unbounded height the moment one was, which is a crash.
  Widget _row(List<Widget> children, {List<int>? flex}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(width: AppSpacing.lg),
        Expanded(flex: flex?[i] ?? 1, child: children[i]),
      ],
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
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
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
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
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final entry in entries.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
