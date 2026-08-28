import 'package:core/core.dart';
import 'package:dietitian_panel/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('signed out shows the login form with the shared brand palette', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        ],
        child: const DietitianPanelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Giriş yapın'), findsOneWidget);
    expect(find.text('Hesabınız yok mu? Kayıt olun'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.primary, AppColors.primary);
  });

  testWidgets('a pending dietitian sees the status card, not the rail', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'dyt@example.com', password: 'sifresifre');
    profiles.seedDietitian(auth.currentSession!.userId);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
        ],
        child: const DietitianPanelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Başvurunuz İnceleniyor'), findsOneWidget);
    expect(find.text('Genel Bakış'), findsNothing);
  });

  testWidgets(
    'an approved dietitian sees the two-destination rail with an honest empty state',
    (tester) async {
      final auth = FakeAuthRepository();
      final profiles = FakeProfileRepository();
      await auth.signIn(email: 'dyt@example.com', password: 'sifresifre');
      profiles.seedDietitian(
        auth.currentSession!.userId,
        fullName: 'Dyt. Kutay',
        status: VerificationStatus.approved,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            profileRepositoryProvider.overrideWithValue(profiles),
          ],
          child: const DietitianPanelApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Genel Bakış'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Danışanlar'), findsNothing);
      expect(find.text('Henüz danışanınız yok'), findsOneWidget);
    },
  );

  testWidgets('a client-role account sees the mismatch screen, not the panel', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'danisan@example.com', password: 'sifresifre');
    profiles.seedClient(auth.currentSession!.userId);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
        ],
        child: const DietitianPanelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bu giriş bu uygulama için değil.'), findsOneWidget);
    expect(find.text('Genel Bakış'), findsNothing);
  });
}
