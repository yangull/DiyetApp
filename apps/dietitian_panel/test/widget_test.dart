import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dietitian_panel/main.dart';

void main() {
  testWidgets('panel opens on the overview with the shared brand palette', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DietitianPanelApp()));
    await tester.pumpAndSettle();

    expect(find.text('Genel Bakış'), findsOneWidget);
    expect(find.text('Danışanlar'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.primary, AppColors.primary);
    expect(app.darkTheme, isNull);
  });
}
