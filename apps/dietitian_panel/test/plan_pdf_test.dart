import 'package:dietitian_panel/demo/demo_repository.dart';
import 'package:dietitian_panel/export/plan_pdf.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A PDF that throws is caught by the button's error handling and looks like a
/// browser problem. These tests fail in the build instead, where the cause is
/// visible — the likeliest breakage being a font that cannot draw Turkish, or
/// an empty row a dietitian left behind mid-interview.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DemoState demo;

  setUp(() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    demo = container.read(demoProvider);
  });

  test('a freeform plan renders to a non-empty PDF', () async {
    final client = demo.clientOf('c1');

    final bytes = await buildPlanPdf(
      client: client,
      plan: demo.planFor('c1'),
      targetKcal: 2043,
    );

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('an exchange plan renders, substitution sheet and all', () async {
    final client = demo.clientOf('c1');
    final plan = demo.exchangePlanFor('c1')!;

    final bytes = await buildExchangePlanPdf(
      client: client,
      plan: plan,
      targetKcal: 2043,
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    // The reference sheet is the bulk of this document; without it the two
    // exports would be nearly the same size.
    final freeform = await buildPlanPdf(
      client: client,
      plan: demo.planFor('c1'),
      targetKcal: 2043,
    );
    expect(bytes.length, greaterThan(freeform.length));
  });

  test('an empty row left mid-interview does not break the export', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(demoProvider.notifier);
    notifier.addItem('c1', 0);

    final state = container.read(demoProvider);
    final bytes = await buildPlanPdf(
      client: state.clientOf('c1'),
      plan: state.planFor('c1'),
      targetKcal: 2043,
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('a zeroed exchange line is left out of the document', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(demoProvider.notifier).setExchangeCount('c1', 0, 0, 0);

    final state = container.read(demoProvider);
    final zeroed = await buildExchangePlanPdf(
      client: state.clientOf('c1'),
      plan: state.exchangePlanFor('c1')!,
      targetKcal: 2043,
    );

    expect(String.fromCharCodes(zeroed.take(5)), '%PDF-');
  });
}
