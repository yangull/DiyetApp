import 'package:client/main.dart';
import 'package:core/core.dart';
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
        child: const ClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Giriş yap'), findsOneWidget);
    expect(find.text('Hesabın yok mu? Kayıt ol'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.primary, AppColors.primary);
    expect(app.darkTheme, isNull);
  });

  testWidgets('signed in as a client shows Ana Sayfa with a real greeting', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
    profiles.seedClient(auth.currentSession!.userId, fullName: 'Elif Aydın');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
        ],
        child: const ClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Merhaba, Elif'), findsOneWidget);
    expect(find.text('Yakında'), findsNWidgets(2));
  });

  testWidgets(
    'a dietitian-role account sees the mismatch screen, not the home',
    (tester) async {
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
          child: const ClientApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bu giriş bu uygulama için değil.'), findsOneWidget);
      expect(find.text('Merhaba, Elif'), findsNothing);
    },
  );
}
