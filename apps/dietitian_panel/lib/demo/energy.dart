import 'demo_models.dart';

/// Where a plan's calorie target comes from, reproduced from a dietitian's own
/// spreadsheet: basal metabolic rate from the client's own measurements, times
/// a physical-activity factor.
///
/// Nothing here is stored. The numbers are derived from `DemoClient` on every
/// read, so correcting a client's weight moves the target immediately — which
/// is the behaviour the spreadsheet has and the typed-in kcal field does not.

/// Harris-Benedict (the original 1919 constants, which is what the sheet uses).
///
/// The sheet also offers Cunningham (`500 + 22 × lean body mass`). It is not
/// implemented: lean mass needs a body-fat or bioimpedance reading, and the
/// demo records weight only. Whether a dietitian owns a Tanita is one of the
/// things to ask.
double basalMetabolicRate(DemoClient client) => switch (client.sex) {
  Sex.erkek =>
    66.473 +
        13.7516 * client.weightKg +
        5.0033 * client.heightCm -
        6.755 * client.age,
  Sex.kadin =>
    655.0955 +
        9.5634 * client.weightKg +
        1.8496 * client.heightCm -
        4.6756 * client.age,
};

/// The sheet's FA columns, 1.2 through 1.6.
double activityFactor(ActivityLevel level) => switch (level) {
  ActivityLevel.sedanter => 1.2,
  ActivityLevel.hafifAktif => 1.3,
  ActivityLevel.ortaAktif => 1.4,
  ActivityLevel.aktif => 1.5,
  ActivityLevel.cokAktif => 1.6,
};

/// What the client should eat in a day, before the dietitian adjusts for a
/// goal. Rounded to whole kcal: the spreadsheet's decimals are arithmetic
/// artefacts, not precision anyone acts on.
int targetEnergy(DemoClient client) =>
    (basalMetabolicRate(client) * activityFactor(client.activityLevel)).round();
