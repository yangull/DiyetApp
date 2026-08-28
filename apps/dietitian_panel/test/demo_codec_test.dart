import 'package:dietitian_panel/demo/demo_codec.dart';
import 'package:dietitian_panel/demo/demo_models.dart';
import 'package:dietitian_panel/demo/demo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a mid-interview edit survives the round trip', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(demoProvider.notifier);

    notifier.setKcal('c1', 1450);
    notifier.approve('c1');
    notifier.editItem('c1', 0, 0, 'Omlet', '3 yumurta');
    notifier.markPaid('a6');
    notifier.setChannel('sms');

    final restored = decodeDemoState(
      encodeDemoState(container.read(demoProvider)),
    )!;
    final plan = restored.planFor('c1');

    expect(plan.kcal, 1450);
    expect(plan.state, PlanState.approved);
    expect(plan.meals.first.items.first.food, 'Omlet');
    expect(plan.meals.first.items.first.amount, '3 yumurta');
    expect(restored.appointments.firstWhere((a) => a.id == 'a6').paid, isTrue);
    expect(restored.reminders.channel, 'sms');
    expect(restored.weights['c1']!.length, 9);
  });

  test('unreadable storage decodes to null instead of throwing', () {
    expect(decodeDemoState('not json'), isNull);
    expect(decodeDemoState('{"version": 0}'), isNull);
  });

  test('reset hands back the seed, not the edited objects', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(demoProvider.notifier);

    notifier.setKcal('c1', 1450);
    notifier.resetDemo();

    expect(container.read(demoProvider).planFor('c1').kcal, 1600);
  });
}
