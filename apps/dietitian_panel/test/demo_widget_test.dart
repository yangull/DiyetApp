import 'dart:ui' show Tristate;

import 'package:core/core.dart';
import 'package:dietitian_panel/demo/demo_models.dart';
import 'package:dietitian_panel/demo/demo_repository.dart';
import 'package:dietitian_panel/main_demo.dart';
import 'package:dietitian_panel/screens/appointments_screen.dart';
import 'package:dietitian_panel/screens/client_detail_screen.dart';
import 'package:dietitian_panel/screens/clients_screen.dart';
import 'package:dietitian_panel/screens/exchange_plan_editor_screen.dart';
import 'package:dietitian_panel/screens/plan_editor_screen.dart';
import 'package:dietitian_panel/screens/messages_screen.dart';
import 'package:dietitian_panel/screens/overview_screen.dart';
import 'package:dietitian_panel/screens/video_call_placeholder_screen.dart';
import 'package:dietitian_panel/util/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'flutter_test_config.dart';
import 'text_fits.dart';

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
    expect(app.theme?.colorScheme.primary, AppColors.charcoal);
    expect(app.darkTheme?.brightness, Brightness.dark);
  });

  // Rule 15, "count the colours": violet appears once, on the drafts card's
  // label (Can, 25 Sep 2026, over C30), because that card holds unapproved AI
  // drafts; the triage icons are grey and amber is left for the reasons and a
  // late wait.
  testWidgets('Genel Bakış shows violet once, on the drafts label', (
    tester,
  ) async {
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
    final violetTexts = <String>[];
    final textColours = <Color?>[];
    for (final t in inOverview<RichText>()) {
      t.text.visitChildren((span) {
        textColours.add(span.style?.color);
        if (span.style?.color == AppColors.aiDraft && span is TextSpan) {
          violetTexts.add(span.text ?? '');
        }
        return true;
      });
    }
    final iconColours = inOverview<Icon>().map((i) => i.color);

    expect(violetTexts, ['Yapay zekâ taslağı']);
    expect(inOverview<Icon>(), isNotEmpty);
    expect(iconColours, isNot(contains(AppColors.aiDraft)));
    expect(iconColours, isNot(contains(AppColors.warning)));
    expect(textColours, contains(AppColors.warning));
  });

  // Black does the acting (PLANNING #135): green marks progress and
  // "approved", never an action, so no text on Randevular is green.
  testWidgets('Randevular has no green text: actions are black', (
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
        // Icons are glyph text too (the AppIcons fonts); the pill's video icon shares its colour.
        final icon = span.style?.fontFamily?.contains('AppIcons') ?? false;
        if (!icon &&
            (colour == AppColors.accent || colour == AppColors.accentStrong)) {
          green.add(span.toPlainText());
        }
        return true;
      });
    }
    expect(green, isEmpty);
    // The action is still there, in Ink.
    final start = tester.widget<RichText>(
      find
          .descendant(
            of: find
                .ancestor(
                  of: find.text('Görüşmeye başla'),
                  matching: find.byWidgetPredicate(
                    (w) => w is ButtonStyleButton,
                  ),
                )
                .first,
            matching: find.byType(RichText),
          )
          .last,
    );
    expect(start.text.style?.color, AppColors.ink);
  });

  // C27 (Can): the client's bubbles are Cloud Card on the white canvas; the
  // dietitian's own are Charcoal (#135).
  testWidgets('Mesajlar: a titled screen, thread on the canvas, two bubbles', (
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
    expect(bubbleOf(fromClient), AppColors.cloudCard);
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
    await tester.tap(inMessages(find.widgetWithText(FilledButton, 'Gönder')));
    await tester.pumpAndSettle();
    expect(bubbleOf('Kolay gelsin'), AppColors.charcoal);
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
    Finder pillsIn(String name) => find.descendant(
      of: find.ancestor(
        of: find
            .descendant(
              of: find.byType(MessagesScreen),
              matching: find.text(name),
            )
            .first,
        matching: find.byType(InkWell),
      ),
      matching: find.text('Yanıt bekliyor'),
    );
    expect(pillsIn('Merve Yılmaz'), findsOneWidget);
    // No messages yet, so nothing waits.
    expect(pillsIn('Ahmet Demir'), findsNothing);

    // The open conversation's band is the inset colour; its pill must not
    // share it.
    final selectedPill = pillsIn('Elif Aydın');
    final pillFill =
        (tester
                    .widget<Container>(
                      find
                          .ancestor(
                            of: selectedPill,
                            matching: find.byType(Container),
                          )
                          .first,
                    )
                    .decoration!
                as BoxDecoration)
            .color;
    final band = tester
        .widget<Container>(
          find
              .ancestor(of: selectedPill, matching: find.byType(Container))
              .last,
        )
        .color;
    expect(band, isNotNull);
    expect(pillFill, isNot(band));
  });

  testWidgets('the thread opens at the top and links to the record', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesajlar'));
    await tester.pumpAndSettle();

    final screen = find.byType(MessagesScreen);
    final firstBubble = find.descendant(
      of: screen,
      matching: find.textContaining('mercimek çorbası'),
    );
    final field = find.descendant(of: screen, matching: find.byType(TextField));
    // Top-anchored: the first message sits near the header, not above the
    // composer with an empty half over it.
    expect(
      tester.getTopLeft(firstBubble).dy,
      lessThan(tester.getTopLeft(field).dy / 2),
    );
    expect(
      find.descendant(
        of: screen,
        matching: find.widgetWithText(FilledButton, 'Gönder'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: screen, matching: find.text('Danışanı aç')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ClientDetailScreen), findsOneWidget);
  });

  testWidgets('Görüşme: back arrow, Turkish tooltips, no document names', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(AppDensity.comfortable),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const VideoCallPlaceholderScreen(clientName: 'Elif Aydın'),
              ),
            ),
            child: const Text('aç'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
    expect(find.textContaining('PLANNING'), findsNothing);
    for (final tip in ['Mikrofon', 'Kamera', 'Görüşmeyi bitir', 'Geri']) {
      expect(
        find.byWidgetPredicate(
          (w) => w is Tooltip && (w.message ?? '').startsWith(tip),
        ),
        findsOneWidget,
        reason: tip,
      );
    }
    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.byType(VideoCallPlaceholderScreen), findsNothing);
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
  // Left edges of every widget showing one of [labels] inside [screen].
  Set<double> leftEdges(Type screen, Iterable<String> labels) => {
    for (final label in labels)
      for (final e
          in find
              .descendant(of: find.byType(screen), matching: find.text(label))
              .evaluate())
        (e.renderObject! as RenderBox).localToGlobal(Offset.zero).dx,
  };

  Future<void> pumpWide(WidgetTester tester, [String? tab]) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    if (tab != null) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }
  }

  // Can, 24 Sep: the two cards lined up within themselves but not with each
  // other, and "Görüşmeye başla" moved with the reminder text beside it.
  testWidgets('Randevular: one grid for both cards', (tester) async {
    await pumpWide(tester, 'Randevular');
    const names = [
      'Ahmet Demir',
      'Merve Yılmaz',
      'Zeynep Kaya',
      'Elif Aydın',
      'Burak Şahin',
    ];
    expect(leftEdges(AppointmentsScreen, names), hasLength(1));
    // The kind column starts in one place whatever fills it: an icon and words
    // in upcoming rows, a pill in past ones.
    expect({
      for (final e
          in find.byKey(const ValueKey('appointments-what-column')).evaluate())
        (e.renderObject! as RenderBox).localToGlobal(Offset.zero).dx,
    }, hasLength(1));
    expect(leftEdges(AppointmentsScreen, ['Görüşmeye başla']), hasLength(1));
    expect(leftEdges(AppointmentsScreen, ['İptal et']), hasLength(1));
    // The icons in the first action column: camera and "gelmedi" calendar.
    final icons = {
      for (final icon in [AppIcons.video, AppIcons.appointmentMissed])
        for (final e
            in find
                .descendant(
                  of: find.byWidgetPredicate((w) => w is ButtonStyleButton),
                  matching: find.byIcon(icon),
                )
                .evaluate())
          (e.renderObject! as RenderBox).localToGlobal(Offset.zero).dx,
    };
    expect(icons, hasLength(1));
  });

  Set<double> rightEdges(Type screen, Iterable<String> labels) => {
    for (final label in labels)
      for (final e
          in find
              .descendant(of: find.byType(screen), matching: find.text(label))
              .evaluate())
        (e.renderObject! as RenderBox)
            .localToGlobal(Offset((e.renderObject! as RenderBox).size.width, 0))
            .dx,
  };

  // Direction B (PLANNING #133): the drafts card and the triage card share
  // one text edge and one action edge, and nobody appears twice in triage.
  testWidgets('Genel Bakış: both cards share their edges', (tester) async {
    await pumpWide(tester);
    const names = ['Burak Şahin', 'Ahmet Demir', 'Elif Aydın', 'Merve Yılmaz'];
    // The agenda column repeats some names; this is about the work column.
    final agendaLeft = tester
        .getTopRight(
          find.ancestor(
            of: find.text('plan onayınızı bekliyor'),
            matching: find.byType(Card),
          ),
        )
        .dx;
    final textEdge = leftEdges(OverviewScreen, [
      ...names,
      '21 gündür tartım girmedi',
      '31 saattir mesajı yanıtsız',
    ]).where((x) => x < agendaLeft);
    expect(textEdge.toSet(), hasLength(1));
    expect(
      rightEdges(OverviewScreen, [
        'Ölçümleri incele',
        'Randevuları aç',
        'Mesajı yanıtla',
        'İncele',
      ]),
      hasLength(1),
    );
    expect(
      find.descendant(
        of: find.byType(OverviewScreen),
        matching: find.text('Burak Şahin'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the client record opens on the plan, with its notes folded', (
    tester,
  ) async {
    await pumpWide(tester, 'Danışanlar');
    await tester.tap(find.text('Elif Aydın'));
    await tester.pumpAndSettle();

    final plan = tester.getTopLeft(find.text('Diyet planı'));
    final info = tester.getTopLeft(find.text('Danışan bilgileri'));
    expect(plan.dy, lessThan(info.dy));
    expect(find.text('Görüşme notu'), findsWidgets);
    expect(find.textContaining('bizim tahminimiz'), findsNothing);
  });

  testWidgets('the exchange plan shows the gap beside its two numbers', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(AppDensity.compact),
          home: const ExchangePlanEditorScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Planda'), findsOneWidget);
    expect(find.text('Hedef'), findsOneWidget);
    expect(find.text('Fark'), findsOneWidget);
    // The signed gap, not the old sentence.
    expect(find.textContaining(RegExp(r'^[+−]\d+ kcal$')), findsOneWidget);
    expect(find.textContaining('Hedefin'), findsNothing);
  });

  testWidgets('the minus button fades at zero', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(AppDensity.compact),
          home: const ExchangePlanEditorScreen(clientId: 'c1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The first group's minus: tap it down to zero; it then does nothing.
    final minus = find.widgetWithIcon(IconButton, AppIcons.remove);
    expect(minus, findsWidgets);
    for (var i = 0; i < 12; i++) {
      if (tester.widget<IconButton>(minus.first).onPressed == null) break;
      await tester.tap(minus.first);
      await tester.pumpAndSettle();
    }
    expect(tester.widget<IconButton>(minus.first).onPressed, isNull);
  });

  testWidgets('Kaydet from far down the form shows the first error', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 700);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışan ekle'));
    await tester.pumpAndSettle();

    // Scroll to the end, where the required fields are far above.
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -3000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet ve taslak oluştur'));
    await tester.pumpAndSettle();

    // Still on the form, and the first required field is back in view.
    expect(tester.takeException(), isNull);
    expect(find.text('Yeni danışan'), findsOneWidget);
    expect(find.text('Zorunlu alan').hitTestable(), findsWidgets);
  });

  for (final (width, expected) in [(1700.0, 2), (1200.0, 0)]) {
    testWidgets('Randevular at $width px: $expected column-name rows', (
      tester,
    ) async {
      // Column names appear only where the rows themselves are a grid.
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1400);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(child: DietitianPanelDemoApp()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Randevular'));
      await tester.pumpAndSettle();
      expect(find.text('Saat'), findsNWidgets(expected));
    });
  }

  testWidgets('the interview question hides behind a toggle', (tester) async {
    await pumpWide(tester);
    expect(find.textContaining('Bu liste bizim tahminimiz'), findsNothing);

    await tester.tap(find.text('Görüşme notu'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bu liste bizim tahminimiz'), findsOneWidget);

    await tester.tap(find.text('Görüşme notunu gizle'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bu liste bizim tahminimiz'), findsNothing);
  });

  testWidgets('Genel Bakış puts the agenda beside the work on wide screens', (
    tester,
  ) async {
    await pumpWide(tester);
    final drafts = tester.getTopLeft(find.text('plan onayınızı bekliyor'));
    final agenda = tester.getTopLeft(
      find.descendant(
        of: find.byType(OverviewScreen),
        matching: find.text('Tüm randevular'),
      ),
    );
    expect(agenda.dx, greaterThan(drafts.dx + 600));
    // The seed's first appointment is two hours ahead, which is tomorrow
    // after 22:00: only expect "Görüşmeye başla" while it is still today.
    final demo = ProviderScope.containerOf(
      tester.element(find.byType(OverviewScreen)),
    ).read(demoProvider);
    final startable = demo.upcoming.any(
      (a) =>
          a.kind == AppointmentKind.online &&
          a.status == AppointmentStatus.planned &&
          DateUtils.isSameDay(a.at, DateTime.now()),
    );
    expect(
      find.descendant(
        of: find.byType(OverviewScreen),
        matching: find.text('Görüşmeye başla'),
      ),
      startable ? findsOneWidget : findsNothing,
    );
  });

  testWidgets('a draft row keeps its wait when it stacks at large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 2400);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 gündür bekliyor'), findsOneWidget);
  });

  testWidgets('with every draft approved the drafts card says so', (
    tester,
  ) async {
    await pumpWide(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(OverviewScreen)),
    );
    final notifier = container.read(demoProvider.notifier);
    for (final plan in container.read(demoProvider).plans) {
      if (plan.isDraft) notifier.approve(plan.clientId);
    }
    await tester.pumpAndSettle();
    expect(find.text('Onay bekleyen plan yok'), findsOneWidget);
    expect(find.text('Yapay zekâ taslağı'), findsNothing);
  });

  testWidgets('a client name in triage can be opened by a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpWide(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Burak Şahin, danışanı aç')),
      matchesSemantics(
        label: 'Burak Şahin, danışanı aç',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('Mesajlar: the three columns start on one line', (tester) async {
    await pumpWide(tester, 'Mesajlar');
    final tops = {
      for (final e
          in find
              .descendant(
                of: find.byType(MessagesScreen),
                matching: find.text('Elif Aydın'),
              )
              .evaluate())
        (e.renderObject! as RenderBox).localToGlobal(Offset.zero).dy,
    };
    // Within half a pixel of one line (the list row and the thread header lay
    // their name out in different rows).
    expect(
      tops.reduce((a, b) => a > b ? a : b) -
          tops.reduce((a, b) => a < b ? a : b),
      lessThan(1),
    );
    expect(find.text('Bugünün öğünleri'), findsOneWidget);
  });

  testWidgets('"Besin ekle" lines up with the food fields', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1400);
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
    final field = tester.getTopLeft(
      find.ancestor(
        of: find.text('Yumurta (haşlanmış)'),
        matching: find.byType(TextFormField),
      ),
    );
    final add = tester.getTopLeft(find.byIcon(AppIcons.add).first);
    expect(add.dx, moreOrLessEquals(field.dx, epsilon: 0.5));
  });

  testWidgets('Genel Bakış links open Danışanlar and Randevular', (
    tester,
  ) async {
    await pumpWide(tester);
    Finder link(String label) => find.descendant(
      of: find.byType(OverviewScreen),
      matching: find.text(label),
    );

    await tester.tap(link('Tüm randevular'));
    await tester.pumpAndSettle();
    var rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 2);

    await tester.tap(find.text('Genel Bakış'));
    await tester.pumpAndSettle();
    await tester.tap(link('Tüm danışanlar'));
    await tester.pumpAndSettle();
    rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.selectedIndex, 1);
  });

  testWidgets('a client name in triage opens the client record', (
    tester,
  ) async {
    await pumpWide(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(OverviewScreen),
        matching: find.text('Burak Şahin'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Burak Şahin'), findsWidgets);
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
    await tester.tap(find.byIcon(AppIcons.send));
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
      find.descendant(
        of: find.widgetWithText(LabeledField, 'Ad soyad'),
        matching: find.byType(TextField),
      ),
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
    expect(find.byIcon(AppIcons.send), findsOneWidget);
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

  // Density follows the input (#135), layout the width (#38): a tablet is wide
  // and touch, a narrowed computer browser is narrow and compact.
  group('density by input, layout by width', () {
    tearDown(() => debugPanelDensity = densityByTestWidth);

    testWidgets('a wide tablet gets the rail with touch sizes', (tester) async {
      debugPanelDensity = (_) => AppDensity.comfortable;
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(child: DietitianPanelDemoApp()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      final context = tester.element(find.byType(NavigationRail));
      expect(context.density.isCompact, isFalse);
      expect(
        Theme.of(context).materialTapTargetSize,
        MaterialTapTargetSize.padded,
      );
    });

    testWidgets('a narrow computer browser gets the bottom bar, compact', (
      tester,
    ) async {
      debugPanelDensity = (_) => AppDensity.compact;
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const ProviderScope(child: DietitianPanelDemoApp()),
      );
      await tester.pumpAndSettle();

      final bar = find.byType(NavigationBar);
      expect(bar, findsOneWidget);
      expect(tester.element(bar).density.isCompact, isTrue);
    });
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
      // One header: the app bar names the page, the page has no heading.
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Hatırlatma ayarları'),
        ),
        findsOneWidget,
      );
      expect(find.text('Hatırlatma ayarları'), findsOneWidget);
    });
  });

  testWidgets('a reminder switch says Açık or Kapalı, and its row toggles', (
    tester,
  ) async {
    await pumpWide(tester, 'Hatırlatma ayarları');
    Finder tile(String title) =>
        find.ancestor(of: find.text(title), matching: find.byType(ListTile));
    Finder stateOf(String title) => find.descendant(
      of: tile(title),
      matching: find.byWidgetPredicate(
        (w) => w is Text && (w.data == 'Açık' || w.data == 'Kapalı'),
      ),
    );
    const row = 'Randevudan 2 saat önce';
    expect(tester.widget<Text>(stateOf(row)).data, 'Açık');
    await tester.tap(find.text(row));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(stateOf(row)).data, 'Kapalı');
    final toggle = find.descendant(
      of: tile(row),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(toggle).value, isFalse);
    // The switch itself toggles once, not twice through the row.
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(toggle).value, isTrue);

    // One role and one state for a screen reader: a toggle, not a button,
    // and the word is not read on top of the switch's own state.
    final handle = tester.ensureSemantics();
    final data = tester.getSemantics(find.text(row)).getSemanticsData();
    expect(data.flagsCollection.isToggled, Tristate.isTrue);
    expect(data.flagsCollection.isButton, isFalse);
    expect(data.label, isNot(contains('Açık')));
    handle.dispose();
  });

  testWidgets('the reset dialog reads as a paragraph on a computer', (
    tester,
  ) async {
    await pumpWide(tester);
    await tester.tap(find.text('Sıfırla'));
    await tester.pumpAndSettle();
    final body = find.textContaining('başlangıç verileri');
    expect(tester.getSize(body).width, greaterThanOrEqualTo(400));
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Sıfırla'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the reset dialog fits a 360 dp phone at 2×', (tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demoyu sıfırla'));
    await tester.pumpAndSettle();
    final body = tester.getRect(find.textContaining('başlangıç verileri'));
    expect(body.left, greaterThan(0));
    expect(body.right, lessThan(360));
    // No clip check: the test font's square glyphs make one Turkish word
    // wider than a 360 dp dialog at 2x; an overflow still fails the test.
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

        // A RenderFlex overflow fails the test on its own. Scroll through
        // every section so each row is laid out at this size.
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
        await tester.scrollUntilVisible(
          find.text('47 saattir mesajı yanıtsız'),
          300,
          scrollable: list,
        );
        expect(find.text('Mesajı yanıtla'), findsNWidgets(2));
        expectTextNotClipped(
          tester,
          find.descendant(
            of: find.byType(OverviewScreen),
            matching: find.byType(Card),
          ),
        );
      });

      testWidgets('"İncele" opens the oldest draft on a $width dp phone '
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

        final review = find
            .descendant(
              of: find.byType(OverviewScreen),
              matching: find.text('İncele'),
            )
            .first;
        await tester.ensureVisible(review);
        await tester.pumpAndSettle();
        await tester.tap(review);
        await tester.pumpAndSettle();
        // Elif's draft is the oldest seed (three days).
        expect(
          tester
              .widget<PlanEditorScreen>(find.byType(PlanEditorScreen))
              .clientId,
          'c1',
        );
      });
    }
  }
}
