import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double width = 360}) => ProviderScope(
  child: MaterialApp(
    theme: AppTheme.light(AppDensity.comfortable),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('AuthSwitchLink starts on the fields\' edge and taps', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        AuthSwitchLink(
          label: 'Hesabın yok mu? Kayıt ol',
          onPressed: () => tapped = true,
        ),
      ),
    );
    expect(tester.getTopLeft(find.text('Hesabın yok mu? Kayıt ol')).dx, 16);
    await tester.tap(find.text('Hesabın yok mu? Kayıt ol'));
    expect(tapped, isTrue);
  });

  testWidgets('SignOutRow is a full-width, tall-enough row that signs out', (
    tester,
  ) async {
    var out = 0;
    await tester.pumpWidget(
      _host(
        SignOutRow(
          onPressed: () async {
            out++;
          },
        ),
      ),
    );
    final size = tester.getSize(find.byType(Card));
    expect(size.width, 360);
    expect(size.height, greaterThanOrEqualTo(48));
    expect(
      tester.getSemantics(find.text('Çıkış yap')),
      matchesSemantics(
        label: 'Çıkış yap',
        isButton: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.text('Çıkış yap'));
    expect(out, 1);
  });

  testWidgets('the theme choice fills its width up to a cap', (tester) async {
    await tester.pumpWidget(_host(const ThemeChoiceSelector()));
    expect(tester.getSize(find.byType(SegmentedButton<ThemeMode>)).width, 360);
    await tester.pumpWidget(_host(const ThemeChoiceSelector(), width: 900));
    expect(tester.getSize(find.byType(SegmentedButton<ThemeMode>)).width, 480);
  });
}
