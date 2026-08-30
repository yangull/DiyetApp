import 'demo_models.dart';

/// Which way this client is supposed to be moving. Derived from the hedef kilo
/// against where they started rather than from the goal *string*, because the
/// goal is free text a dietitian types and 'Kilo koruma' is only one of the
/// ways they might write maintenance.
enum GoalDirection { losing, gaining, maintaining, unknown }

enum ProgressVerdict { onTrack, offTrack, neutral }

/// A target within this many kg of the starting weight is maintenance, and a
/// maintaining client stays on track while they are within it. Both are
/// guesses — ask what counts as drifting.
const kMaintenanceBandKg = 2.0;

/// The bug this exists to fix: the panel used to render every loss the same
/// way. A client whose goal is kilo koruma dropping 1.6 kg is not a success,
/// and showing it identically to a weight-loss client's 1.6 kg is the panel
/// telling a dietitian something untrue about their own client.
class WeightProgress {
  const WeightProgress({
    required this.deltaKg,
    required this.direction,
    required this.verdict,
    required this.label,
    required this.remainingKg,
  });

  /// Latest minus first. Negative is a loss.
  final double deltaKg;
  final GoalDirection direction;
  final ProgressVerdict verdict;

  /// Turkish, rendered as-is.
  final String label;

  /// Distance still to cover, null when there is no hedef kilo.
  final double? remainingKg;

  bool get isLoss => deltaKg < 0;
}

WeightProgress weightProgress(DemoClient client, List<WeightEntry> entries) {
  final first = entries.first.kg;
  final last = entries.last.kg;
  final delta = last - first;
  final target = client.targetWeightKg;

  if (target == null) {
    return WeightProgress(
      deltaKg: delta,
      direction: GoalDirection.unknown,
      verdict: ProgressVerdict.neutral,
      label: 'hedef kilo tanımlı değil',
      remainingKg: null,
    );
  }

  final remaining = target - last;
  final direction = switch (target - first) {
    final d when d < -kMaintenanceBandKg => GoalDirection.losing,
    final d when d > kMaintenanceBandKg => GoalDirection.gaining,
    _ => GoalDirection.maintaining,
  };

  final (verdict, label) = switch (direction) {
    GoalDirection.losing =>
      delta < 0
          ? (ProgressVerdict.onTrack, 'hedefe doğru')
          : (ProgressVerdict.offTrack, 'hedeften uzaklaşıyor'),
    GoalDirection.gaining =>
      delta > 0
          ? (ProgressVerdict.onTrack, 'hedefe doğru')
          : (ProgressVerdict.offTrack, 'hedeften uzaklaşıyor'),
    GoalDirection.maintaining =>
      remaining.abs() <= kMaintenanceBandKg
          ? (ProgressVerdict.onTrack, 'hedef aralığında')
          : (ProgressVerdict.offTrack, 'hedef aralığının dışında'),
    GoalDirection.unknown => (ProgressVerdict.neutral, ''),
  };

  return WeightProgress(
    deltaKg: delta,
    direction: direction,
    verdict: verdict,
    label: label,
    remainingKg: remaining,
  );
}
