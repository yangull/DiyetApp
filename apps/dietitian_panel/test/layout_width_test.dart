import 'package:core/core.dart';
import 'package:dietitian_panel/main_demo.dart';
import 'package:dietitian_panel/screens/client_detail_screen.dart';
import 'package:dietitian_panel/screens/intake_form_screen.dart';
import 'package:dietitian_panel/screens/plan_editor_screen.dart';
import 'package:dietitian_panel/screens/reports_screen.dart';
import 'package:dietitian_panel/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Slice 11b (Can, 24 Sep 2026): forms and text pages stop growing at about
/// 1100 px and centre; fields and facts sit on shared column edges.
void main() {
  Future<void> pumpAt(WidgetTester tester, Size size, Widget home) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(
            size.width < 600 ? AppDensity.comfortable : AppDensity.compact,
          ),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double left(WidgetTester t, Finder f) => t.getTopLeft(f).dx;

  void expectCentredAndCapped(WidgetTester t, Finder content, Finder page) {
    final c = t.getRect(content);
    final p = t.getRect(page);
    expect(c.width, lessThanOrEqualTo(1100.5));
    expect(c.left - p.left, moreOrLessEquals(p.right - c.right, epsilon: 1));
  }

  Finder label(String s) => find.text(s);

  testWidgets('the client record centres and lines its facts up', (t) async {
    await pumpAt(
      t,
      const Size(1600, 1600),
      const ClientDetailScreen(clientId: 'c1'),
    );
    expectCentredAndCapped(
      t,
      find.byType(Card).first,
      find.byType(ClientDetailScreen),
    );
    // Column 2 and 3 of each group share an edge, the energy line too.
    for (final column in [
      ['BOY', 'ALERJİ / HASSASİYET', 'AKTİVİTE KATSAYISI'],
      ['GÜNCEL KİLO', 'KRONİK RAHATSIZLIK', 'GÜNLÜK HEDEF'],
    ]) {
      expect({for (final l in column) left(t, label(l))}, hasLength(1));
    }
  });

  testWidgets('the client record keeps two facts a row on a phone', (t) async {
    await pumpAt(
      t,
      const Size(412, 2400),
      const ClientDetailScreen(clientId: 'c1'),
    );
    expect(left(t, label('YAŞ')), left(t, label('GÜNCEL KİLO')));
    expect(left(t, label('BOY')), left(t, label('HEDEF')));
    expect(left(t, label('BMH')), left(t, label('GÜNLÜK HEDEF')));
  });

  testWidgets('the intake form sits on one grid, fields one height', (t) async {
    await pumpAt(t, const Size(1600, 1600), const IntakeFormScreen());
    expectCentredAndCapped(
      t,
      find.byType(Card).first,
      find.byType(IntakeFormScreen),
    );
    Finder box(String l) => find
        .ancestor(of: find.text(l), matching: find.byType(InputDecorator))
        .first;
    expect(
      left(t, box('Yaş')),
      moreOrLessEquals(left(t, box('Hedef kilo (kg)'))),
    );
    expect(
      left(t, box('Alerji / hassasiyet')),
      moreOrLessEquals(left(t, box('Kilo (kg)'))),
    );
    expect(
      left(t, box('İlaç / takviye')),
      moreOrLessEquals(left(t, box('Hareket düzeyi'))),
    );
    final heights = {
      for (final l in [
        'Ad soyad',
        'Yaş',
        'Cinsiyet',
        'Hedef',
        'Hareket düzeyi',
      ])
        t.getSize(box(l)).height.roundToDouble(),
    };
    expect(heights, hasLength(1));
  });

  testWidgets('Takip centres inside the tab area', (t) async {
    await pumpAt(
      t,
      const Size(1800, 1400),
      const Scaffold(body: ReportsScreen()),
    );
    expectCentredAndCapped(
      t,
      find.byType(Card).first,
      find.byType(ReportsScreen),
    );
  });

  testWidgets('a wide plan editor centres, its pill beside the title', (
    t,
  ) async {
    await pumpAt(
      t,
      const Size(1800, 1400),
      const PlanEditorScreen(clientId: 'c1'),
    );
    final meals = t.getRect(find.byType(Card).first);
    final panel = t.getRect(
      find.ancestor(of: find.text('Günlük hedef'), matching: find.byType(Card)),
    );
    final page = t.getRect(find.byType(PlanEditorScreen));
    expect(
      meals.left - page.left,
      moreOrLessEquals(page.right - panel.right, epsilon: 1),
    );
    final title = t.getRect(find.text('Elif Aydın · Pazartesi'));
    final pill = t.getRect(find.byType(StatusPill));
    expect(pill.left - title.right, inInclusiveRange(0, 24));
  });

  testWidgets('"Vazgeç" is grey next to a red confirm', (t) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(1600, 1000);
    addTearDown(t.view.reset);
    await t.pumpWidget(const ProviderScope(child: DietitianPanelDemoApp()));
    await t.pumpAndSettle();
    await t.tap(find.text('Sıfırla'));
    await t.pumpAndSettle();
    final cancel = t.widget<TextButton>(
      find.widgetWithText(TextButton, 'Vazgeç'),
    );
    expect(
      cancel.style?.foregroundColor?.resolve(const <WidgetState>{}),
      AppColors.textSecondary,
    );
  });
}
