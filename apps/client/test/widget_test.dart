import 'package:client/main.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The hero's step summary, read from its Semantics label.
Finder _steps(int done) => find.byWidgetPredicate(
  (w) =>
      w is Semantics &&
      w.properties.label == 'Başlangıç: 3 adımdan $done tamamlandı',
);

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

  testWidgets('signed in as a client shows Bugün with only real steps', (
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
    expect(_steps(0), findsOneWidget);
    expect(
      find.text('Henüz yazmadın. Diyetisyenin buradan başlar.'),
      findsOneWidget,
    );
    // Unbuilt paths are named once, as text, never as buttons (rule 4).
    expect(find.text('YAKINDA'), findsOneWidget);
    expect(find.widgetWithText(InkWell, 'Diyetisyen bul'), findsNothing);
  });

  testWidgets('a pending invite names the inviting dietitian, not the client', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
    final clientId = auth.currentSession!.userId;
    profiles.seedClient(clientId, fullName: 'Elif Aydın');
    profiles.seedDietitian('dyt-1', fullName: 'Dyt. Deniz');

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

    expect(find.text('Dyt. Deniz seni davet etti'), findsOneWidget);
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
    profiles.seedDietitian('dyt-1', fullName: 'Dyt. Deniz');

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

    expect(find.text('Dyt. Deniz seni davet etti'), findsNothing);
    expect(relationships.byId('rel-a').status, RelationshipStatus.active);
    expect(relationships.byId('rel-a').clientId, clientId);
    // The accepted dietitian now shows as the client's, and step 2 is done.
    expect(find.text('Diyetisyenin'), findsOneWidget);
    expect(find.text('Dyt. Deniz'), findsOneWidget);
    expect(_steps(1), findsOneWidget);
  });

  testWidgets('declining an invite clears the card without claiming the row', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
    final clientId = auth.currentSession!.userId;
    profiles.seedClient(clientId, fullName: 'Elif Aydın');
    profiles.seedDietitian('dyt-1', fullName: 'Dyt. Deniz');

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

    expect(find.text('Dyt. Deniz seni davet etti'), findsNothing);
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
    // Profil is a summary; editing opens its own screen.
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Yazılmadı'), findsNWidgets(3));
    await tester.tap(find.text('Düzenle'));
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

    // Back on Profil, the summary shows what was saved.
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Laktoz intoleransı'), findsOneWidget);
    expect(find.text('Yazılmadı'), findsOneWidget);

    // Bugün follows the save without a new sign-in.
    await tester.tap(find.text('Bugün'));
    await tester.pumpAndSettle();
    expect(find.text('5 kilo vermek'), findsOneWidget);
    expect(_steps(1), findsOneWidget);
  });

  testWidgets('the goal row is one tap target that opens the goals editor', (
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
          clientRelationshipRepositoryProvider.overrideWithValue(
            FakeClientRelationshipRepository(),
          ),
        ],
        child: const ClientApp(),
      ),
    );
    await tester.pumpAndSettle();

    final row = find.widgetWithText(InkWell, 'Hedeflerin');
    expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Hedeflerim'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Hedefim'), findsOneWidget);
  });

  for (final width in [360.0, 412.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('Bugün and Profil lay out at $width dp, text scale $scale', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = Size(width * 3, 740 * 3);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final auth = FakeAuthRepository();
        final profiles = FakeProfileRepository();
        await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
        final clientId = auth.currentSession!.userId;
        profiles.seedClient(clientId, fullName: 'Elif Aydın');
        profiles.seedDietitian('dyt-1', fullName: 'Dyt. Deniz Karaoğlanoğlu');
        final relationships =
            FakeClientRelationshipRepository(
              currentUserId: clientId,
              currentEmail: 'elif@example.com',
            )..seedRelationship(
              dietitianId: 'dyt-1',
              invitedEmail: 'elif@example.com',
            );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(auth),
              profileRepositoryProvider.overrideWithValue(profiles),
              clientRelationshipRepositoryProvider.overrideWithValue(
                relationships,
              ),
            ],
            child: const ClientApp(),
          ),
        );
        await tester.pumpAndSettle();

        // A RenderFlex overflow fails the test on its own.
        expect(find.text('Merhaba, Elif'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();
        expect(find.text('HEDEFLERİN'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

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
