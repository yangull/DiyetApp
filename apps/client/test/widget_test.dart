import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/main.dart';

void main() {
  testWidgets('renders the home placeholder using the shared theme', (
    tester,
  ) async {
    await tester.pumpWidget(const ClientApp());

    expect(find.text('Diyetisyenlik App'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.primary, AppTheme.light.colorScheme.primary);
    expect(
      app.darkTheme?.colorScheme.primary,
      AppTheme.dark.colorScheme.primary,
    );
  });
}
