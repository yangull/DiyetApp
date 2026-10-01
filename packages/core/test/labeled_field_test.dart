import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double scale = 1}) => MaterialApp(
  theme: AppTheme.light(AppDensity.comfortable),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(800, 800),
      textScaler: TextScaler.linear(scale),
    ),
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 300, child: child),
      ),
    ),
  ),
);

void main() {
  group('LabeledField', () {
    testWidgets('draws the label above the field and helper on its edge', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const LabeledField(label: 'Parola', helper: 'En az 8 karakter.')),
      );
      final label = tester.getRect(find.text('Parola'));
      final field = tester.getRect(find.byType(TextField));
      final helper = tester.getRect(find.text('En az 8 karakter.'));
      expect(label.bottom, lessThanOrEqualTo(field.top));
      expect(label.left, field.left);
      expect(helper.left, field.left);
      expect(helper.top, greaterThanOrEqualTo(field.bottom));
    });

    testWidgets('keeps the label when the field is filled', (tester) async {
      await tester.pumpWidget(_host(const LabeledField(label: 'E-posta')));
      final before = tester.getRect(find.text('E-posta'));
      await tester.enterText(find.byType(TextField), 'a@b.c');
      await tester.pump();
      expect(tester.getRect(find.text('E-posta')), before);
    });

    testWidgets('the validator shows the error, replacing the helper', (
      tester,
    ) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(
        _host(
          Form(
            key: key,
            child: LabeledField(
              label: 'Parola',
              helper: 'En az 8 karakter.',
              validator: (v) => (v ?? '').length < 8 ? 'Çok kısa.' : null,
            ),
          ),
        ),
      );
      final height = tester.getSize(find.byType(TextField)).height;
      expect(find.text('En az 8 karakter.'), findsOneWidget);

      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Çok kısa.'), findsOneWidget);
      expect(find.text('En az 8 karakter.'), findsNothing);
      // The error sits under the field; the field itself doesn't grow.
      expect(tester.getSize(find.byType(TextField)).height, height);
      expect(
        tester.getRect(find.text('Çok kısa.')).top,
        greaterThanOrEqualTo(tester.getRect(find.byType(TextField)).bottom),
      );

      await tester.enterText(find.byType(TextField), '12345678');
      expect(key.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Çok kısa.'), findsNothing);
      expect(find.text('En az 8 karakter.'), findsOneWidget);
    });

    testWidgets('an errorText from the caller shows without a Form', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const LabeledField(label: 'E-posta', errorText: 'Geçersiz.')),
      );
      expect(find.text('Geçersiz.'), findsOneWidget);
    });

    testWidgets('a password hides its text until shown', (tester) async {
      await tester.pumpWidget(
        _host(const LabeledField(label: 'Parola', password: true)),
      );
      bool obscured() =>
          tester.widget<TextField>(find.byType(TextField)).obscureText;
      expect(obscured(), isTrue);
      await tester.tap(find.byTooltip('Parolayı göster'));
      await tester.pump();
      expect(obscured(), isFalse);
      expect(find.byTooltip('Parolayı gizle'), findsOneWidget);
    });

    testWidgets('a password field is as tall as the others when compact', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(AppDensity.compact),
          home: const Scaffold(
            body: Column(
              children: [
                LabeledField(label: 'E-posta'),
                LabeledField(label: 'Parola', password: true),
              ],
            ),
          ),
        ),
      );
      final heights = {
        for (final f in find.byType(TextField).evaluate())
          tester.getSize(find.byWidget(f.widget)).height,
      };
      expect(heights, hasLength(1));
    });

    testWidgets('the field is named for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const LabeledField(label: 'E-posta')));
      expect(find.bySemanticsLabel('E-posta'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a long label wraps at 200 % without overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const LabeledField(label: 'Danışanın e-posta adresi'), scale: 2),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('LabeledDropdown', () {
    testWidgets('shows the label above and reports a change', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _host(
          LabeledDropdown<String?>(
            label: 'Hedef',
            value: null,
            items: const [
              DropdownMenuItem(value: null, child: Text('Tüm hedefler')),
              DropdownMenuItem(value: 'Kilo', child: Text('Kilo')),
            ],
            onChanged: (v) => picked = v,
          ),
        ),
      );
      expect(
        tester.getRect(find.text('Hedef')).bottom,
        lessThanOrEqualTo(
          tester.getRect(find.byType(DropdownButtonFormField<String?>)).top,
        ),
      );
      await tester.tap(find.text('Tüm hedefler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kilo').last);
      await tester.pumpAndSettle();
      expect(picked, 'Kilo');
    });
  });
}
