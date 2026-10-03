import 'package:core/core.dart';
import 'package:dietitian_panel/main_demo.dart';
import 'package:dietitian_panel/screens/clients_screen.dart';
import 'package:dietitian_panel/screens/messages_screen.dart';
import 'package:dietitian_panel/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Audit X5: numbers that form a column sit in fixed, right-aligned slots,
/// because Alpino has no tabular figures.
void main() {
  testWidgets("the context panel's meal times line up", (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesajlar'));
    await tester.pumpAndSettle();

    Finder inScreen(String s) => find.descendant(
      of: find.byType(MessagesScreen),
      matching: find.text(s),
    );
    Rect rectOf(String s) => tester.getRect(inScreen(s));
    expect(rectOf('08:00').right, moreOrLessEquals(rectOf('11:00').right));
    expect(rectOf('Kahvaltı').left, moreOrLessEquals(rectOf('Gece').left));
    // The test font draws every digit the same width, so equal edges alone
    // would pass without a slot: check the slot itself.
    final time = tester.widget<Text>(inScreen('08:00'));
    expect(time.textAlign, TextAlign.end);
    expect(
      rectOf('08:00').width,
      moreOrLessEquals(
        numberSlotWidth(
          tester.element(inScreen('08:00')),
          '00:00',
          time.style!,
        ),
      ),
    );
  });

  // The header had one flex more than the rows, so "Kilo" sat 87 px off the
  // weights under it.
  testWidgets('the Danışanlar table header sits over its columns', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danışanlar'));
    await tester.pumpAndSettle();

    Rect rectOf(String s) => tester.getRect(
      find
          .descendant(of: find.byType(ClientsScreen), matching: find.text(s))
          .first,
    );
    expect(rectOf('Kilo').right, moreOrLessEquals(rectOf('72,4 kg').right));
    for (final s in ['Kilo', '72,4 kg']) {
      final text = tester.widget<Text>(
        find
            .descendant(of: find.byType(ClientsScreen), matching: find.text(s))
            .first,
      );
      expect(text.textAlign, TextAlign.end, reason: s);
    }
    // The filter above the table is labelled "Hedef" too; the header's is
    // the last one.
    final header = tester.getRect(
      find
          .descendant(
            of: find.byType(ClientsScreen),
            matching: find.text('Hedef'),
          )
          .last,
    );
    expect(header.left, moreOrLessEquals(rectOf('Kilo verme').left));
    expect(
      rectOf('Plan durumu').left,
      moreOrLessEquals(
        tester
            .getRect(
              find
                  .descendant(
                    of: find.byType(ClientsScreen),
                    matching: find.byType(StatusPill),
                  )
                  .first,
            )
            .left,
      ),
    );
  });
}
