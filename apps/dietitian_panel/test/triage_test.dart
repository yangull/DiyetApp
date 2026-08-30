import 'package:dietitian_panel/demo/demo_models.dart';
import 'package:dietitian_panel/demo/demo_repository.dart';
import 'package:dietitian_panel/demo/progress.dart';
import 'package:dietitian_panel/demo/triage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

DemoClient _client({required String goal, double? targetWeightKg}) =>
    DemoClient(
      id: 'test',
      name: 'Test',
      age: 30,
      sex: Sex.kadin,
      heightCm: 165,
      weightKg: 70,
      goal: goal,
      targetWeightKg: targetWeightKg,
      activityLevel: ActivityLevel.ortaAktif,
      dietType: 'standart',
      allergies: const [],
      chronicConditions: const [],
      medications: const [],
      note: '',
      startedOn: DateTime(2026),
    );

List<WeightEntry> _weights(List<double> kg) => [
  for (var i = 0; i < kg.length; i++)
    WeightEntry(DateTime(2026, 1, 1 + i * 7), kg[i]),
];

void main() {
  group('weightProgress', () {
    // The bug this whole module exists for: the panel used to show these two
    // identically, and telling a kilo koruma client's dietitian that a 1.6 kg
    // drop is progress is the panel being wrong about their own client.
    test('a loss is progress toward a weight-loss target', () {
      final progress = weightProgress(
        _client(goal: 'Kilo verme', targetWeightKg: 65),
        _weights([78.4, 75.0, 72.4]),
      );

      expect(progress.direction, GoalDirection.losing);
      expect(progress.verdict, ProgressVerdict.onTrack);
      expect(progress.remainingKg, closeTo(-7.4, 0.01));
    });

    test('the same loss on a maintenance goal is not progress', () {
      final drifted = weightProgress(
        _client(goal: 'Kilo koruma', targetWeightKg: 58),
        _weights([59.8, 58.5, 55.0]),
      );

      expect(drifted.direction, GoalDirection.maintaining);
      expect(drifted.verdict, ProgressVerdict.offTrack);
      expect(drifted.isLoss, isTrue);
    });

    test('a maintenance client inside the band stays on track', () {
      final held = weightProgress(
        _client(goal: 'Kilo koruma', targetWeightKg: 58),
        _weights([59.8, 58.5, 58.2]),
      );

      expect(held.verdict, ProgressVerdict.onTrack);
      expect(held.label, 'hedef aralığında');
    });

    test('no target means no verdict at all', () {
      final progress = weightProgress(
        _client(goal: 'Sporcu beslenmesi'),
        _weights([64.2, 63.0]),
      );

      expect(progress.direction, GoalDirection.unknown);
      expect(progress.verdict, ProgressVerdict.neutral);
      expect(progress.remainingKg, isNull);
    });

    test('gaining toward a higher target is progress, losing is not', () {
      final client = _client(goal: 'Kilo alma', targetWeightKg: 62);
      expect(
        weightProgress(client, _weights([55.0, 57.0])).verdict,
        ProgressVerdict.onTrack,
      );
      expect(
        weightProgress(client, _weights([55.0, 53.0])).verdict,
        ProgressVerdict.offTrack,
      );
    });
  });

  group('triageSignals', () {
    test('the seed fires every signal the Genel Bakış list claims to show', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final signals = triageSignals(container.read(demoProvider));
      final kinds = signals.map((s) => s.kind).toSet();

      expect(kinds, contains(TriageKind.staleWeighIn));
      expect(kinds, contains(TriageKind.unansweredMessage));
      expect(kinds, contains(TriageKind.noShow));
    });

    test('the worst overdue signal is listed first', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final signals = triageSignals(container.read(demoProvider));

      expect(signals.length, greaterThan(1));
      for (var i = 1; i < signals.length; i++) {
        expect(
          signals[i - 1].overdueBy >= signals[i].overdueBy,
          isTrue,
          reason: 'signal $i is more overdue than the one before it',
        );
      }
    });

    // Drafts have their own row and their own waiting badge under "Sıradaki
    // işler"; a client listed twice on one screen reads as a bug.
    test('a pending draft alone does not raise a triage signal', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final demo = container.read(demoProvider);

      // c2's draft is six hours old and everything else about her is current.
      expect(demo.planFor('c2').isDraft, isTrue);
      expect(triageSignals(demo).where((s) => s.client.id == 'c2'), isEmpty);
    });

    test('a client who weighed in yesterday raises nothing', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final demo = container.read(demoProvider);

      expect(
        triageSignals(demo).where(
          (s) => s.client.id == 'c1' && s.kind == TriageKind.staleWeighIn,
        ),
        isEmpty,
      );
    });
  });

  group('addClient', () {
    test('an intake creates a client with a draft plan waiting', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(demoProvider.notifier);

      notifier.addClient(_client(goal: 'Kilo verme', targetWeightKg: 60));
      final demo = container.read(demoProvider);

      expect(demo.clients.map((c) => c.id), contains('test'));
      expect(demo.planFor('test').isDraft, isTrue);
      expect(demo.planFor('test').kcal, greaterThan(1000));
      expect(demo.weights['test'], hasLength(1));
      expect(demo.macros['test'], isNotNull);
      expect(demo.conversationOf('test').messages, isEmpty);
    });
  });
}
