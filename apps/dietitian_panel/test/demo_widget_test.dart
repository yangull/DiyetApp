import 'package:core/core.dart';
import 'package:dietitian_panel/demo/demo_models.dart';
import 'package:dietitian_panel/demo/demo_repository.dart';
import 'package:dietitian_panel/main_demo.dart';
import 'package:dietitian_panel/screens/appointments_screen.dart';
import 'package:dietitian_panel/screens/clients_screen.dart';
import 'package:dietitian_panel/screens/exchange_plan_editor_screen.dart';
import 'package:dietitian_panel/screens/plan_editor_screen.dart';
import 'package:dietitian_panel/screens/messages_screen.dart';
import 'package:dietitian_panel/screens/overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the interview demo opens straight on the overview, no login', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Genel Bakış'), findsOneWidget);
    expect(find.text('Danışanlar'), findsOneWidget);
    expect(find.text('Mesajlar'), findsOneWidget);
    expect(find.text('Ödemeler'), findsNothing);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.primary, AppColors.primary);
    expect(app.darkTheme, isNull);
  });

  // Rule 15, "count the colours": green plus one status colour. Drafts are
  // told apart by their wording here, not by violet (C30), and the triage
  // icons are grey; amber is left for the reason and a late wait.
  testWidgets('Genel Bakış draws no violet and no amber icons', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();

    Iterable<T> inOverview<T extends Widget>() => tester.widgetList<T>(
      find.descendant(
        of: find.byType(OverviewScreen),
        matching: find.byType(T),
      ),
    );
    final textColours = <Color?>[];
    for (final t in inOverview<RichText>()) {
      t.text.visitChildren((span) {
        textColours.add(span.style?.color);
        return true;
      });
    }
    final iconColours = inOverview<Icon>().map((i) => i.color);

    expect(inOverview<Icon>(), isNotEmpty);
    expect(textColours, isNot(contains(AppColors.aiDraft)));
    expect(iconColours, isNot(contains(AppColors.aiDraft)));
    expect(iconColours, isNot(contains(AppColors.warning)));
    expect(textColours, contains(AppColors.warning));
  });

  // One green action per row (Can, C29): "Görüşmeye başla", a pale pill
  // with primaryHover text. Nothing else on Randevular is primary-green.
  testWidgets('Randevular keeps green for "Görüşmeye başla" alone', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Randevular'));
    await tester.pumpAndSettle();

    final green = <String>[];
    for (final t in tester.widgetList<RichText>(
      find.descendant(
        of: find.byType(AppointmentsScreen),
        matching: find.byType(RichText),
      ),
    )) {
      t.text.visitChildren((span) {
        final colour = span.style?.color;
        // Icons are glyph text too; the pill's video icon shares its colour.
        final icon = span.style?.fontFamily == 'MaterialIcons';
        if (!icon &&
            (colour == AppColors.primary || colour == AppColors.primaryHover)) {
          green.add(span.toPlainText());
        }
        return true;
      });
    }
    expect(green.toSet(), {'Görüşmeye başla'});
  });

  // C27 (Can): the wide thread sits on the grey ground, so the client's white
  // bubbles read; the dietitian's are the pale green tint.
  testWidgets('Mesajlar: a titled screen, thread on the ground, two bubbles', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    // A laptop in landscape: short enough that the context panel has to
    // scroll under the new heading.
    tester.view.physicalSize = const Size(1280, 600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesajlar'));
    await tester.pumpAndSettle();
    Finder inMessages(Finder f) =>
        find.descendant(of: find.byType(MessagesScreen), matching: f);

    expect(inMessages(find.text('Mesajlar')), findsOneWidget);

    // The rounded container around the text; the same words also show as
    // the preview in the conversation list.
    Color bubbleOf(String message) {
      final bubbles = tester
          .widgetList<Container>(
            find.ancestor(
              of: inMessages(find.text(message)),
              matching: find.byType(Container),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.borderRadius != null);
      return bubbles.single.color!;
    }

    const fromClient = 'Süper, teşekkürler!';
    expect(bubbleOf(fromClient), AppColors.surface);
    final bubble = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).borderRadius != null,
    );
    final inBubble = inMessages(
      find.descendant(of: bubble, matching: find.text(fromClient)),
    );
    expect(inBubble, findsOneWidget);
    expect(
      find.ancestor(of: inBubble, matching: find.byType(Card)),
      findsNothing,
    );
    await tester.enterText(inMessages(find.byType(TextField)), 'Kolay gelsin');
    await tester.tap(inMessages(find.byTooltip('Gönder')));
    await tester.pumpAndSettle();
    expect(bubbleOf('Kolay gelsin'), AppColors.primaryTint);
  });

  testWidgets('a conversation awaiting a reply says so without colour', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesajlar'));
    await tester.pumpAndSettle();
    final handle = tester.ensureSemantics();
    expect(
      find.descendant(
        of: find.byType(MessagesScreen),
        matching: find.bySemanticsLabel(RegExp('yanıt bekliyor')),
      ),
      findsWidgets,
    );
    handle.dispose();
  });

  // Fields were keyed by row index: after deleting the first food, the
  // first field kept "Yumurta" while the model held "Tam buğday ekmeği".
  testWidgets('deleting a food row shows the foods that are left', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(AppDensity.compact),
          home: const PlanEditorScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Satırı sil').first);
    await tester.pumpAndSettle();

    final first = tester.widget<EditableText>(find.byType(EditableText).at(1));
    expect(first.controller.text, 'Tam buğday ekmeği');
    expect(find.text('Yumurta (haşlanmış)'), findsNothing);
  });

  testWidgets('search reads Turkish capitals: YILMAZ finds Yılmaz', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlar').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(ClientsScreen),
        matching: find.byType(TextField),
      ),
      'YILMAZ',
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(ClientsScreen),
        matching: find.text('Merve Yılmaz'),
      ),
      findsOneWidget,
    );
  });

  // awaitsReply means "the client wrote last": reading doesn't clear it, a
  // reply does. The screen says so.
  testWidgets('Mesajlar counts conversations awaiting a reply', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesajlar'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(MessagesScreen),
        matching: find.textContaining('yanıt bekleyen'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('okunmamış'), findsNothing);
  });

  // Each row's actions differ in width, so a flexible middle column started
  // somewhere else in every row.
  testWidgets('Randevular columns line up across rows', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Randevular'));
    await tester.pumpAndSettle();

    Set<double> leftEdges(Iterable<String> labels) => {
      for (final label in labels)
        for (final e
            in find
                .descendant(
                  of: find.byType(AppointmentsScreen),
                  matching: find.text(label),
                )
                .evaluate())
          tester.getTopLeft(find.byWidget(e.widget)).dx,
    };

    expect(leftEdges(['Görüntülü görüşme', 'Yüz yüze']), hasLength(1));
    expect(leftEdges(['Görüşme yapıldı', 'Gelmedi']), hasLength(1));
  });

  testWidgets('the counts under the greeting open where their items are', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();

    Finder count(String label) => find.descendant(
      of: find.byType(OverviewScreen),
      matching: find.text(label, findRichText: true),
    );
    expect(count('5 danışan'), findsOneWidget);
    expect(count('3 onay bekliyor'), findsOneWidget);
    expect(count('4 randevu'), findsOneWidget);

    await tester.tap(count('4 randevu'));
    await tester.pumpAndSettle();
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 2);
  });

  testWidgets('a dietitian can open a conversation and send a message', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mesajlar'));
    await tester.pumpAndSettle();

    // Elif Aydın (c1) is the first client and opens by default.
    expect(find.text('Elif Aydın'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Yarın görüşürüz.');
    await tester.tap(find.byIcon(Icons.send_outlined));
    await tester.pumpAndSettle();

    // Appears twice by design: once in the message thread, once as the
    // conversation list's last-message preview (_ConversationRow).
    expect(find.text('Yarın görüşürüz.'), findsWidgets);
  });

  testWidgets('no money is shown while PLANNING P6 holds', (tester) async {
    // A desktop-sized window: the demo is shown on a laptop and Randevular's rows
    // overflow at the test default of 800 px.
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Tahsil edilmemiş'), findsNothing);

    await tester.tap(find.text('Randevular'));
    await tester.pumpAndSettle();

    expect(find.textContaining('₺'), findsNothing);
  });

  testWidgets('a draft stays with the client it was typed for', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesajlar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Elif için not');
    await tester.tap(find.text('Merve Yılmaz').first);
    await tester.pumpAndSettle();

    expect(find.text('Elif için not'), findsNothing);

    await tester.tap(find.text('Elif Aydın').first);
    await tester.pumpAndSettle();

    expect(find.text('Elif için not'), findsOneWidget);
  });

  testWidgets('leaving a filled-in intake form asks first', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışan ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ad soyad'),
      'Ayşe Demir',
    );
    // A focused field scrolls itself back into view on every frame, which
    // would carry the form away from the buttons at the bottom.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Vazgeç'),
      300,
      scrollable: find
          .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
          .first,
    );
    await tester.ensureVisible(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(find.text('Değişiklikler kaydedilmedi'), findsOneWidget);
    await tester.tap(find.text('Düzenlemeye dön'));
    await tester.pumpAndSettle();
    expect(find.text('Yeni danışan'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil ve çık'));
    await tester.pumpAndSettle();

    expect(find.text('Yeni danışan'), findsNothing);
    expect(find.text('Danışanlarınız'), findsOneWidget);
  });

  testWidgets('a triage link opens the task, not just the client record', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mesajı yanıtla').first);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MessagesScreen)),
    );
    expect(container.read(selectedConversationProvider), isNotNull);
    expect(find.byIcon(Icons.send_outlined), findsOneWidget);
  });

  group('Sıfırla starts a fresh interview', () {
    Future<void> reset(WidgetTester tester) async {
      await tester.tap(find.text('Sıfırla'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sıfırla'));
      await tester.pumpAndSettle();
    }

    testWidgets('a goal that only an added client had is cleared', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(child: DietitianPanelDemoApp()),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final seeded = container.read(demoProvider).clients.first;
      container
          .read(demoProvider.notifier)
          .addClient(
            DemoClient(
              id: 'c-test',
              name: 'Ayşe Demir',
              age: 30,
              sex: seeded.sex,
              heightCm: 165,
              weightKg: 60,
              goal: 'Özel hedef',
              targetWeightKg: null,
              activityLevel: seeded.activityLevel,
              dietType: 'standart',
              allergies: const [],
              chronicConditions: const [],
              medications: const [],
              note: '',
              startedOn: DateTime.now(),
            ),
          );
      await tester.tap(find.text('Danışanlar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tüm hedefler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Özel hedef').last);
      await tester.pumpAndSettle();

      await reset(tester);
      await tester.tap(find.text('Danışanlar'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Tüm hedefler'), findsOneWidget);
      expect(find.text('Elif Aydın'), findsOneWidget);
    });

    testWidgets('an unsent message draft is gone', (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(child: DietitianPanelDemoApp()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mesajlar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Yarım kalan not');

      await reset(tester);
      await tester.tap(find.text('Mesajlar'));
      await tester.pumpAndSettle();

      expect(find.text('Yarım kalan not'), findsNothing);
    });
  });

  group('both plan editors keep approval in reach', () {
    Future<void> pumpEditor(WidgetTester tester, Widget editor, Size size) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(AppDensity.compact),
            home: editor,
          ),
        ),
      );
    }

    final editors = {
      'freeform': const PlanEditorScreen(clientId: 'c1'),
      'exchange list': const ExchangePlanEditorScreen(clientId: 'c1'),
    };

    for (final entry in editors.entries) {
      testWidgets('${entry.key}: wide, after scrolling to the last meal', (
        tester,
      ) async {
        await pumpEditor(tester, entry.value, const Size(1600, 1000));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView).first, const Offset(0, -5000));
        await tester.pumpAndSettle();

        final approve = find.text('Onayla ve danışana gönder');
        expect(approve, findsOneWidget);
        await tester.tap(approve);
        await tester.pumpAndSettle();

        expect(approve, findsNothing);
        expect(find.text('Plan onaylandı ve danışana gönderildi.'), findsOne);
      });

      testWidgets('${entry.key}: narrow, a pinned bar carries the approval', (
        tester,
      ) async {
        await pumpEditor(tester, entry.value, const Size(420, 900));
        await tester.pumpAndSettle();

        expect(find.textContaining('hedef'), findsWidgets);
        expect(find.text('Onayla ve danışana gönder'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('the demo adapts to the window width (#38)', () {
    testWidgets('wide: a rail with the utilities at its foot', (tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(child: DietitianPanelDemoApp()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final context = tester.element(find.byType(NavigationRail));
      expect(context.density.isCompact, isTrue);
    });

    testWidgets('phone: a bottom bar; settings sit behind a Demo button', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const ProviderScope(child: DietitianPanelDemoApp()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsNothing);
      final bar = find.byType(NavigationBar);
      expect(bar, findsOneWidget);
      expect(tester.element(bar).density.isCompact, isFalse);
      for (final label in [
        'Genel Bakış',
        'Danışanlar',
        'Randevular',
        'Mesajlar',
        'Takip',
      ]) {
        expect(
          find.descendant(of: bar, matching: find.text(label)),
          findsOneWidget,
        );
      }

      await tester.tap(find.text('Demo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hatırlatma ayarları'));
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
    });
  });

  for (final width in [360.0, 412.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('Genel Bakış fits a $width dp phone at $scale×', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = Size(width * 3, 740 * 3);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.pumpWidget(
          const ProviderScope(child: DietitianPanelDemoApp()),
        );
        await tester.pumpAndSettle();

        // A RenderFlex overflow fails the test on its own. At 2× the greeting
        // and counts fill the first screen, so scroll to the card.
        final list = find
            .descendant(
              of: find.byType(OverviewScreen),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(
          find.text('Dikkat gerekenler'),
          300,
          scrollable: list,
        );
        await tester.drag(list, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(find.text('Danışanı aç'), findsWidgets);
        // The last draft row, so every row of the draft card was laid out.
        await tester.scrollUntilVisible(
          find.textContaining('1700 kcal'),
          300,
          scrollable: list,
        );
      });

      testWidgets('"onay bekliyor" reaches the drafts on a $width dp phone '
          'at $scale×', (tester) async {
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = Size(width * 3, 740 * 3);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          const ProviderScope(child: DietitianPanelDemoApp()),
        );
        await tester.pumpAndSettle();

        // At 2x on 360 dp the count itself starts under the bottom bar.
        final count = find.text('3 onay bekliyor', findRichText: true);
        await tester.ensureVisible(count);
        await tester.pumpAndSettle();
        expect(find.text('Sıradaki işler').hitTestable(), findsNothing);
        await tester.tap(count);
        await tester.pumpAndSettle();
        expect(find.text('Sıradaki işler').hitTestable(), findsOneWidget);
      });
    }
  }
}
