import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double width = 400, double scale = 1}) =>
    MaterialApp(
      theme: AppTheme.light(AppDensity.comfortable),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(800, 800),
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );

void main() {
  test('initials skip titles and use Turkish capitals', () {
    expect(initialsOf('Dyt. Deniz Arslan'), 'DA');
    expect(initialsOf('ismail kaya'), 'İK');
    expect(initialsOf('Burak Şahin'), 'BŞ');
    expect(initialsOf(''), '');
  });

  group('ActionRow', () {
    const row = ActionRow(
      body: Text('21 gündür tartım girmedi'),
      actionLabel: 'Ölçümler',
    );

    testWidgets('keeps the action beside the words when both fit', (
      tester,
    ) async {
      await tester.pumpWidget(_host(row));
      final words = tester.getCenter(find.text('21 gündür tartım girmedi'));
      final action = tester.getCenter(find.text('Ölçümler'));
      expect(action.dy, moreOrLessEquals(words.dy, epsilon: 1));
      expect(action.dx, greaterThan(words.dx));
    });

    testWidgets('drops the action under the words at large text', (
      tester,
    ) async {
      await tester.pumpWidget(_host(row, width: 300, scale: 2));
      final words = tester.getBottomLeft(find.text('21 gündür tartım girmedi'));
      final action = tester.getTopLeft(find.text('Ölçümler'));
      expect(action.dy, greaterThanOrEqualTo(words.dy));
      // The label sits on the words' left edge, its pill hanging outward.
      expect(action.dx, moreOrLessEquals(words.dx, epsilon: 1));
    });

    testWidgets('names the whole task for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const ActionRow(
            body: Text('31 saattir mesajı yanıtsız'),
            actionLabel: 'Yanıtla',
            actionSemantics: 'Burak Şahin: mesajı yanıtla',
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Burak Şahin: mesajı yanıtla'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  testWidgets('a section label is a sentence-case header (#135)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        SectionLabel(
          'Dikkat gerekenler',
          count: '3 danışan',
          actionLabel: 'Tüm danışanlar',
          onAction: () {},
        ),
      ),
    );
    expect(find.text('Dikkat gerekenler'), findsOneWidget);
    expect(find.text('3 danışan'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Dikkat gerekenler')),
      matchesSemantics(label: 'Dikkat gerekenler', isHeader: true),
    );
    handle.dispose();
  });
}
