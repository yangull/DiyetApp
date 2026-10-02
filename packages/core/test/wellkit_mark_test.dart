import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double scale = 1}) => MaterialApp(
  theme: AppTheme.light(AppDensity.comfortable),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(400, 800),
      textScaler: TextScaler.linear(scale),
    ),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('WellkitMark', () {
    testWidgets('draws a W on a tile of the given size', (tester) async {
      await tester.pumpWidget(_host(const WellkitMark(size: 56)));
      expect(find.text('W'), findsOneWidget);
      expect(tester.getSize(find.byType(WellkitMark)), const Size(56, 56));
    });

    testWidgets('ignores the text scale, so 200 % cannot fill the tile', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const WellkitMark(), scale: 1));
      final normal = tester.getSize(find.text('W'));
      await tester.pumpWidget(_host(const WellkitMark(), scale: 2));
      expect(tester.getSize(find.text('W')), normal);
      expect(tester.getSize(find.byType(WellkitMark)), const Size(48, 48));
    });

    testWidgets('is hidden from the screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const WellkitMark()));
      expect(find.bySemanticsLabel('W'), findsNothing);
      handle.dispose();
    });
  });
}
