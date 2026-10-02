import 'package:core/core.dart';
import 'package:dietitian_panel/demo/demo_models.dart';
import 'package:dietitian_panel/demo/demo_repository.dart';
import 'package:dietitian_panel/demo/progress.dart';
import 'package:dietitian_panel/main_demo.dart';
import 'package:dietitian_panel/screens/client_detail_screen.dart';
import 'package:dietitian_panel/screens/clients_screen.dart';
import 'package:dietitian_panel/screens/intake_form_screen.dart';
import 'package:dietitian_panel/screens/plan_editor_screen.dart';
import 'package:dietitian_panel/screens/reports_screen.dart';
import 'package:dietitian_panel/widgets/status_pill.dart';
import 'package:dietitian_panel/widgets/weight_chart.dart';
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
      ['Boy', 'Alerji / hassasiyet', 'Aktivite katsayısı'],
      ['Güncel kilo', 'Kronik rahatsızlık', 'Günlük hedef'],
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
    expect(left(t, label('Yaş')), left(t, label('Güncel kilo')));
    expect(left(t, label('Boy')), left(t, label('Hedef')));
    expect(left(t, label('BMH')), left(t, label('Günlük hedef')));
  });

  testWidgets('the intake form sits on one grid, fields one height', (t) async {
    await pumpAt(t, const Size(1600, 1600), const IntakeFormScreen());
    expectCentredAndCapped(
      t,
      find.byType(Card).first,
      find.byType(IntakeFormScreen),
    );
    Finder box(String l) => find
        .descendant(
          of: find.widgetWithText(FieldFrame, l),
          matching: find.byType(InputDecorator),
        )
        .first;
    expect(
      left(t, box('Cinsiyet')),
      moreOrLessEquals(left(t, box('Hedef kilo (kg)'))),
    );
    expect(left(t, box('Yaş')), moreOrLessEquals(left(t, box('Kilo (kg)'))));
    expect(
      left(t, box('Alerji / hassasiyet')),
      moreOrLessEquals(left(t, box('Kilo (kg)'))),
    );
    // Three equal columns, in every group: the second column starts in one
    // place, and a lone field sits in the first.
    expect(
      left(t, box('Hareket düzeyi')),
      moreOrLessEquals(left(t, box('Yaş'))),
    );
    expect(
      left(t, box('İlaç / takviye')),
      moreOrLessEquals(left(t, box('Ad soyad'))),
    );
    expect(left(t, box('Su tüketimi')), moreOrLessEquals(left(t, box('Yaş'))));
    // The actions are pinned: in view without scrolling to the bottom.
    expect(find.text('Kaydet ve taslak oluştur').hitTestable(), findsOneWidget);
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

  testWidgets('the Danışanlar filter row shares one bottom edge', (t) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(1400, 900);
    addTearDown(t.view.reset);
    await t.pumpWidget(const ProviderScope(child: DietitianPanelDemoApp()));
    await t.pumpAndSettle();
    await t.tap(find.text('Danışanlar'));
    await t.pumpAndSettle();
    final inClients = find.byType(ClientsScreen);
    Finder within(Finder f) => find.descendant(of: inClients, matching: f);
    final bottoms = {
      for (final f in [
        within(find.byType(TextField)),
        within(find.byType(DropdownButtonFormField<String?>)),
        within(find.byType(FilterChip)).first,
      ])
        t.getRect(f).bottom.roundToDouble(),
    };
    expect(bottoms, hasLength(1));
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

  testWidgets('Takip: summary numbers line up, charts two to a row', (t) async {
    await pumpAt(
      t,
      const Size(1600, 1400),
      const Scaffold(body: ReportsScreen()),
    );
    final summary = find.ancestor(
      of: find.text('Özet'),
      matching: find.byType(Card),
    );
    double rightOf(String s) =>
        t.getRect(find.descendant(of: summary, matching: find.text(s))).right;
    expect(rightOf('72,4 kg'), moreOrLessEquals(rightOf('63,0 kg')));
    expect(rightOf('7,4 kg'), moreOrLessEquals(rightOf('—')));
    expect(rightOf('Hedefe kalan'), moreOrLessEquals(rightOf('7,4 kg')));
    // A header never wraps over its column.
    final row = t.getSize(find.text('Danışan'));
    for (final header in ['Son tartım', 'Değişim', 'Hedefe kalan']) {
      expect(
        t.getSize(find.text(header)).height,
        moreOrLessEquals(row.height),
        reason: header,
      );
    }

    final charts = find.ancestor(
      of: find.byType(WeightChart),
      matching: find.byType(Card),
    );
    expect(
      t.getRect(charts.at(0)).top,
      moreOrLessEquals(t.getRect(charts.at(1)).top),
    );
  });

  testWidgets('Takip keeps one column just under 900 px of content', (t) async {
    // 940 px less the compact page padding leaves 892 px.
    await pumpAt(
      t,
      const Size(940, 2400),
      const Scaffold(body: ReportsScreen()),
    );
    final charts = find.ancestor(
      of: find.byType(WeightChart),
      matching: find.byType(Card),
    );
    expect(
      t.getRect(charts.at(1)).top,
      greaterThan(t.getRect(charts.at(0)).bottom),
    );
  });

  testWidgets('Takip: a client with one weigh-in is not judged yet', (t) async {
    await pumpAt(
      t,
      const Size(1600, 2400),
      const Scaffold(body: ReportsScreen()),
    );
    final container = ProviderScope.containerOf(
      t.element(find.byType(ReportsScreen)),
    );
    final seeded = container.read(demoProvider).clients.first;
    container
        .read(demoProvider.notifier)
        .addClient(
          DemoClient(
            id: 'c-new',
            name: 'Ayşe Demir',
            age: 30,
            sex: seeded.sex,
            heightCm: 165,
            weightKg: 70,
            goal: 'Kilo verme',
            targetWeightKg: 62,
            activityLevel: seeded.activityLevel,
            dietType: 'standart',
            allergies: const [],
            chronicConditions: const [],
            medications: const [],
            note: '',
            startedOn: DateTime.now(),
          ),
        );
    await t.pumpAndSettle();
    expect(find.text('tek tartım'), findsOneWidget);
    expect(find.text('hedeften uzaklaşıyor'), findsNothing);
    expect(find.text('Grafik ikinci tartımdan sonra görünür.'), findsOneWidget);
  });

  test('"Hedefe kalan" says hedefte once the target is reached or passed', () {
    expect(
      remainingToTarget(
        target: 65,
        last: 72.4,
        direction: GoalDirection.losing,
      ),
      '7,4 kg',
    );
    expect(
      remainingToTarget(target: 65, last: 63, direction: GoalDirection.losing),
      'hedefte',
    );
    expect(
      remainingToTarget(target: 70, last: 72, direction: GoalDirection.gaining),
      'hedefte',
    );
    expect(
      remainingToTarget(
        target: 58,
        last: 58.2,
        direction: GoalDirection.maintaining,
      ),
      '0,2 kg',
    );
    expect(remainingToTarget(target: null, last: 60, direction: null), isNull);
  });

  // The review of D10 found the four-column table and the phone row
  // overflowing at large text; a tall window builds every row and chart.
  for (final width in [360.0, 412.0, 600.0, 800.0, 1024.0]) {
    for (final scale in [1.3, 2.0]) {
      testWidgets('Takip fits $width px at $scale× text', (t) async {
        t.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpAt(
          t,
          Size(width, 5000),
          const Scaffold(body: ReportsScreen()),
        );
        expect(find.byType(WeightChart), findsNWidgets(5));
      });
    }
  }

  testWidgets('Takip on a phone: one chart per row, note folded', (t) async {
    await pumpAt(
      t,
      const Size(412, 900),
      const Scaffold(body: ReportsScreen()),
    );
    expect(find.textContaining('hangi ölçümleri'), findsNothing);
    await t.tap(find.text('Görüşme notu'));
    await t.pumpAndSettle();
    expect(find.textContaining('hangi ölçümleri'), findsOneWidget);

    final charts = find.ancestor(
      of: find.byType(WeightChart, skipOffstage: false),
      matching: find.byType(Card, skipOffstage: false),
    );
    expect(
      t.getRect(charts.at(1)).top,
      greaterThan(t.getRect(charts.at(0)).bottom),
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

  // Black does the acting (#135): cancel is an Ink text action beside the
  // red confirm, never green.
  testWidgets('"Vazgeç" is an Ink text action next to a red confirm', (
    t,
  ) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(1600, 1000);
    addTearDown(t.view.reset);
    await t.pumpWidget(const ProviderScope(child: DietitianPanelDemoApp()));
    await t.pumpAndSettle();
    await t.tap(find.text('Sıfırla'));
    await t.pumpAndSettle();
    final label = t.widget<RichText>(
      find.descendant(
        of: find.widgetWithText(TextButton, 'Vazgeç'),
        matching: find.byType(RichText),
      ),
    );
    expect(label.text.style?.color, AppColors.ink);
  });
}
