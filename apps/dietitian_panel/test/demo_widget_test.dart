import 'package:core/core.dart';
import 'package:dietitian_panel/main_demo.dart';
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
}
