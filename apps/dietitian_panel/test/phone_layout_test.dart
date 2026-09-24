import 'package:dietitian_panel/main_demo.dart';
import 'package:dietitian_panel/screens/appointments_screen.dart';
import 'package:dietitian_panel/screens/client_detail_screen.dart';
import 'package:dietitian_panel/screens/clients_screen.dart';
import 'package:dietitian_panel/screens/exchange_plan_editor_screen.dart';
import 'package:dietitian_panel/screens/messages_screen.dart';
import 'package:dietitian_panel/screens/plan_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'text_fits.dart';

/// Every demo destination on a phone (#38): a RenderFlex overflow anywhere
/// fails the test on its own.
void main() {
  Future<void> pumpPhone(
    WidgetTester tester,
    double width,
    double scale,
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
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the wide client table grows with 2× text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlar').first);
    await tester.pumpAndSettle();

    expectTextNotClipped(
      tester,
      find.descendant(
        of: find.byType(ClientsScreen),
        matching: find.byType(Card),
      ),
    );
  });

  for (final width in [360.0, 412.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('a client record fits a $width dp phone at $scale×', (
        tester,
      ) async {
        await pumpPhone(tester, width, scale);
        await openTab(tester, 'Danışanlar');
        // IndexedStack keeps every tab built; look inside this one only.
        final client = find.descendant(
          of: find.byType(ClientsScreen),
          matching: find.text('Ahmet Demir'),
        );
        // At large text the row is below the fold and not built yet.
        await tester.scrollUntilVisible(
          client,
          300,
          scrollable: find
              .descendant(
                of: find.byType(ClientsScreen),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(client);
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), findsOneWidget);
      });

      testWidgets('a message thread opens as its own page on a $width dp '
          'phone at $scale×', (tester) async {
        await pumpPhone(tester, width, scale);
        await openTab(tester, 'Mesajlar');
        final thread = find
            .descendant(
              of: find.byType(MessagesScreen),
              matching: find.text('Ahmet Demir'),
            )
            .first;
        await tester.ensureVisible(thread);
        await tester.pumpAndSettle();
        await tester.tap(thread);
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      for (final (button, editor, lastText) in [
        (
          'Taslağı düzenle',
          PlanEditorScreen,
          'Bu ekran görüşme için hazırlanmış',
        ),
        (
          'Değişim listesiyle dene',
          ExchangePlanEditorScreen,
          'Bu ekran bir deneme',
        ),
      ]) {
        testWidgets('the $editor fits a $width dp phone at $scale×', (
          tester,
        ) async {
          await pumpPhone(tester, width, scale);
          await openTab(tester, 'Danışanlar');
          final client = find.descendant(
            of: find.byType(ClientsScreen),
            matching: find.text('Elif Aydın'),
          );
          await tester.scrollUntilVisible(
            client,
            300,
            scrollable: find
                .descendant(
                  of: find.byType(ClientsScreen),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.pumpAndSettle();
          await tester.tap(client);
          await tester.pumpAndSettle();
          final open = find.text(button);
          await tester.scrollUntilVisible(
            open,
            300,
            scrollable: find
                .descendant(
                  of: find.byType(ClientDetailScreen),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.pumpAndSettle();
          await tester.tap(open);
          await tester.pumpAndSettle();
          // Scrolling to the footer builds every meal card on the way.
          await tester.scrollUntilVisible(
            find.textContaining(lastText),
            300,
            scrollable: find
                .descendant(
                  of: find.byType(editor),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.pumpAndSettle();
        });
      }

      testWidgets('Danışanlar filters behind one button on a $width dp '
          'phone at $scale×', (tester) async {
        await pumpPhone(tester, width, scale);
        await openTab(tester, 'Danışanlar');
        Finder inClients(Finder f) =>
            find.descendant(of: find.byType(ClientsScreen), matching: f);

        // Search stays on the screen (Can, C28); goal and plan status don't.
        expect(inClients(find.byType(TextField)), findsOneWidget);
        expect(inClients(find.byType(FilterChip)), findsNothing);
        expect(
          inClients(find.byType(DropdownButtonFormField<String?>)),
          findsNothing,
        );

        final filter = inClients(find.textContaining('Filtrele'));
        await tester.ensureVisible(filter);
        await tester.pumpAndSettle();
        await tester.tap(filter);
        await tester.pumpAndSettle();
        // At 2x the sheet scrolls; reach each control before tapping it.
        for (final target in [
          find.text('Onay bekleyen'),
          find.textContaining('danışanı göster'),
        ]) {
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          await tester.tap(target);
          await tester.pumpAndSettle();
        }

        expect(inClients(find.text('Filtrele · 1')), findsOneWidget);
        expect(inClients(find.text('Ahmet Demir')), findsNothing);
        final clear = inClients(find.text('Temizle'));
        await tester.ensureVisible(clear);
        await tester.pumpAndSettle();
        await tester.tap(clear);
        await tester.pumpAndSettle();
        // At large text "Temizle" wrapped under the button, so the button
        // may now sit just above the view.
        await tester.scrollUntilVisible(
          inClients(find.text('Filtrele')),
          -200,
          scrollable: inClients(find.byType(Scrollable)).first,
        );
        expect(inClients(find.text('Ahmet Demir')), findsWidgets);
      });

      testWidgets('past appointments read on a $width dp phone at $scale×', (
        tester,
      ) async {
        await pumpPhone(tester, width, scale);
        await openTab(tester, 'Randevular');
        final done = find.descendant(
          of: find.byType(AppointmentsScreen),
          matching: find.text('Görüşme yapıldı'),
        );
        final list = find
            .descendant(
              of: find.byType(AppointmentsScreen),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(
          find.text('Geçmiş randevular'),
          300,
          scrollable: list,
        );
        await tester.drag(list, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(done, findsWidgets);
        // Squeezed into a column beside the name, it broke mid-word
        // ("Görüşm / e / yapıldı"): narrower than its longest word.
        for (final element in done.evaluate()) {
          final paragraph = element.renderObject! as RenderParagraph;
          expect(
            paragraph.size.width,
            greaterThanOrEqualTo(
              paragraph.getMinIntrinsicWidth(double.infinity) - 0.5,
            ),
            reason: 'a word in "Görüşme yapıldı" is broken',
          );
        }
      });

      for (final tab in ['Danışanlar', 'Randevular', 'Mesajlar', 'Takip']) {
        testWidgets('$tab fits a $width dp phone at $scale×', (tester) async {
          await pumpPhone(tester, width, scale);
          await openTab(tester, tab);
        });
      }
    }
  }
}
