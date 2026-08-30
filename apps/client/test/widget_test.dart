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

  testWidgets('a pending invite names the inviting dietitian, not the client', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
    final clientId = auth.currentSession!.userId;
    profiles.seedClient(clientId, fullName: 'Elif Aydın');
    profiles.seedDietitian('dyt-1', fullName: 'Dyt. Kutay');

    final relationships = FakeClientRelationshipRepository(
      currentUserId: clientId,
      currentEmail: 'elif@example.com',
    )..seedRelationship(dietitianId: 'dyt-1', invitedEmail: 'elif@example.com');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(relationships),
        ],
        child: const ClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dyt. Kutay sizi davet etti'), findsOneWidget);
    // The client's own address is not identifying information here.
    expect(find.text('elif@example.com'), findsNothing);
  });

  testWidgets('accepting an invite activates it and clears the card', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
    final clientId = auth.currentSession!.userId;
    profiles.seedClient(clientId, fullName: 'Elif Aydın');
    profiles.seedDietitian('dyt-1', fullName: 'Dyt. Kutay');

    final relationships =
        FakeClientRelationshipRepository(
          currentUserId: clientId,
          currentEmail: 'elif@example.com',
        )..seedRelationship(
          id: 'rel-a',
          dietitianId: 'dyt-1',
          invitedEmail: 'elif@example.com',
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(relationships),
        ],
        child: const ClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kabul et'));
    await tester.pumpAndSettle();

    expect(find.text('Dyt. Kutay sizi davet etti'), findsNothing);
    expect(relationships.byId('rel-a').status, RelationshipStatus.active);
    expect(relationships.byId('rel-a').clientId, clientId);
  });

  testWidgets('declining an invite clears the card without claiming the row', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
    final clientId = auth.currentSession!.userId;
    profiles.seedClient(clientId, fullName: 'Elif Aydın');
    profiles.seedDietitian('dyt-1', fullName: 'Dyt. Kutay');

    final relationships =
        FakeClientRelationshipRepository(
          currentUserId: clientId,
          currentEmail: 'elif@example.com',
        )..seedRelationship(
          id: 'rel-a',
          dietitianId: 'dyt-1',
          invitedEmail: 'elif@example.com',
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(relationships),
        ],
        child: const ClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reddet'));
    await tester.pumpAndSettle();

    expect(find.text('Dyt. Kutay sizi davet etti'), findsNothing);
    expect(relationships.byId('rel-a').status, RelationshipStatus.declined);
    expect(relationships.byId('rel-a').clientId, isNull);
  });

  testWidgets('the Hedeflerim form writes the three client-owned columns', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
    final clientId = auth.currentSession!.userId;
    profiles.seedClient(clientId, fullName: 'Elif Aydın');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(
            FakeClientRelationshipRepository(),
          ),
        ],
        child: const ClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Hedefim'),
      '5 kilo vermek',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Sağlık notlarım'),
      'Laktoz intoleransı',
    );
    await tester.ensureVisible(find.text('Kaydet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final saved = await profiles.fetchClientDetail(clientId);
    expect(saved.goal, '5 kilo vermek');
    expect(saved.healthNotes, 'Laktoz intoleransı');
    // Left blank, so it stays null rather than becoming an empty string.
    expect(saved.budgetRange, isNull);
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
