import 'package:dietitian_panel/demo/demo_models.dart';
import 'package:dietitian_panel/demo/energy.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checked against the cells of the dietitian's own spreadsheet, which is the
/// only authority we have for these numbers. If a formula is ever "cleaned up"
/// into a different published variant, these fail — deliberately: matching the
/// tool a dietitian already trusts matters more than matching a textbook.
DemoClient _client({
  required Sex sex,
  required int age,
  required double weightKg,
  required int heightCm,
  ActivityLevel activityLevel = ActivityLevel.sedanter,
}) => DemoClient(
  id: 'test',
  name: 'Test',
  age: age,
  sex: sex,
  heightCm: heightCm,
  weightKg: weightKg,
  goal: '',
  activityLevel: activityLevel,
  dietType: 'standart',
  allergies: const [],
  chronicConditions: const [],
  medications: const [],
  note: '',
  startedOn: DateTime(2026),
);

void main() {
  // Sheet row "Harris Bnd." under KIZ: 47 yaş, 70 kg, 158 cm → 1397.11.
  test('Harris-Benedict reproduces the sheet for women', () {
    final bmh = basalMetabolicRate(
      _client(sex: Sex.kadin, age: 47, weightKg: 70, heightCm: 158),
    );

    expect(bmh, closeTo(1397.11, 0.5));
  });

  // Sheet row "Harris Bnd." under ERKEK: 41 yaş, 75 kg, 176 cm → 1700.18.
  // Their cell rounds the constants slightly; a whole kcal is well inside what
  // anyone acts on, so the tolerance is deliberately loose here.
  test('Harris-Benedict reproduces the sheet for men', () {
    final bmh = basalMetabolicRate(
      _client(sex: Sex.erkek, age: 41, weightKg: 75, heightCm: 176),
    );

    expect(bmh, closeTo(1700.18, 2));
  });

  // The FA columns: BMH × factor. Sheet: 1700.18 × 1.2 = 2040.216.
  test('the activity factor multiplies straight through', () {
    final client = _client(
      sex: Sex.erkek,
      age: 41,
      weightKg: 75,
      heightCm: 176,
      activityLevel: ActivityLevel.sedanter,
    );

    expect(activityFactor(ActivityLevel.sedanter), 1.2);
    expect(targetEnergy(client), closeTo(2040, 3));
  });

  test('every activity level maps to one of the sheet columns', () {
    final factors = [
      for (final level in ActivityLevel.values) activityFactor(level),
    ];

    expect(factors, [1.2, 1.3, 1.4, 1.5, 1.6]);
  });

  test('a heavier client needs more energy, all else equal', () {
    int energyAt(double kg) => targetEnergy(
      _client(sex: Sex.kadin, age: 34, weightKg: kg, heightCm: 165),
    );

    expect(energyAt(80), greaterThan(energyAt(70)));
  });
}
