import 'dart:convert';
import 'dart:io';

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
    notifier.sendMessage('c2', 'Antrenman öncesi hafif bir şeyler ye.');

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
    expect(
      restored.conversationOf('c2').lastMessage!.text,
      'Antrenman öncesi hafif bir şeyler ye.',
    );
    expect(
      restored.conversationOf('c2').lastMessage!.sender,
      MessageSender.dietitian,
    );
  });

  // Catches the half of the drift the analyzer cannot see. Adding a required
  // field breaks the `DemoState(...)` call in decode, so the analyzer forces
  // that side to be updated — but nothing forces the matching encode entry, and
  // a field written by neither, or read by only one, is silent. Re-encoding
  // what was just decoded compares the codec against itself, with no field list
  // to keep in sync.
  test('encode and decode stay symmetrical', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(demoProvider.notifier);

    notifier.setKcal('c3', 1750);
    notifier.toggleReminder('payment', true);
    notifier.sendMessage('c3', 'Kan değerlerini paylaşabilir misiniz?');

    final once = encodeDemoState(container.read(demoProvider));
    final twice = encodeDemoState(decodeDemoState(once)!);

    expect(twice, once);
  });

  // The trap recorded in HANDOFF §7: a field added to a demo model but not to
  // `demo_codec.dart` compiles fine and is dropped on the next reload. The
  // model source is the only place that field list exists, so the check reads
  // it rather than restating it here.
  test('every demo model field reaches the encoded JSON', () {
    final fieldsByClass = _declaredFields(
      File('lib/demo/demo_models.dart').readAsStringSync(),
    );
    expect(fieldsByClass.keys, contains('DemoClient'));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final encoded = jsonDecode(encodeDemoState(container.read(demoProvider)));
    final objects = _keySetsIn(encoded);

    fieldsByClass.forEach((className, fields) {
      expect(fields, isNotEmpty, reason: '$className parsed with no fields');
      expect(
        objects.any((keys) => fields.every(keys.contains)),
        isTrue,
        reason:
            'No encoded object carries every field of $className '
            '(${fields.join(', ')}). Add the missing one to demo_codec.dart '
            'and bump _schemaVersion.',
      );
    });
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

final _classDeclaration = RegExp(r'^class (\w+)');

/// A field is a two-space-indented `Type name;`. Getters carry `=>` or `=`,
/// neither of which the type pattern admits, so they fall out on their own.
final _fieldDeclaration = RegExp(r'^ {2}(?! )(?:final +)?[\w<>?, ]+ (\w+);$');

Map<String, List<String>> _declaredFields(String source) {
  final fields = <String, List<String>>{};
  String? current;

  for (final line in const LineSplitter().convert(source)) {
    final declaration = _classDeclaration.firstMatch(line);
    if (declaration != null) {
      current = declaration.group(1);
      fields[current!] = [];
      continue;
    }
    if (line.startsWith('}')) {
      current = null;
      continue;
    }
    if (current == null) continue;

    final field = _fieldDeclaration.firstMatch(line);
    if (field != null) fields[current]!.add(field.group(1)!);
  }
  return fields;
}

/// Every JSON object in the tree, as its set of keys.
List<Set<String>> _keySetsIn(Object? node) => switch (node) {
  Map<String, dynamic>() => [
    node.keys.toSet(),
    for (final value in node.values) ..._keySetsIn(value),
  ],
  List() => [for (final value in node) ..._keySetsIn(value)],
  _ => const [],
};
