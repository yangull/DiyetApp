import 'package:core/core.dart';
import 'package:dietitian_panel/demo/demo_models.dart';
import 'package:dietitian_panel/demo/demo_repository.dart';
import 'package:dietitian_panel/main_demo.dart';
import 'package:dietitian_panel/screens/messages_screen.dart';
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
    // A desktop-sized window: the panel is web-only and Randevular's rows
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
}
