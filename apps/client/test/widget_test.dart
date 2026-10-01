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

/// The text field under a [LabeledField] with this label.
Finder _fieldLabelled(String label) => find.descendant(
  of: find.widgetWithText(LabeledField, label),
  matching: find.byType(TextField),
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
    expect(app.theme?.colorScheme.primary, AppColors.charcoal);
    expect(app.darkTheme?.brightness, Brightness.dark);
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
    expect(find.text('Diyetisyenin buradan başlar.'), findsOneWidget);
    // Unbuilt paths are named once, as text, never as buttons (rule 4): one
    // "Yakında" section, and the first plan's step says it inline.
    expect(find.text('Yakında'), findsNWidgets(2));
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
      _fieldLabelled('Hedefim'),
      '5 kilo vermek',
    );
    await tester.enterText(
      _fieldLabelled('Sağlık notlarım'),
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

  testWidgets('the goal step button opens the goals editor', (tester) async {
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

    final button = find.widgetWithText(OutlinedButton, 'Yaz');
    // The pill looks 40 tall; its tap target is padded to 48.
    expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Hedeflerim'), findsOneWidget);
    expect(_fieldLabelled('Hedefim'), findsOneWidget);
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
        expect(find.text('Hedeflerin'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  // Slice 12: every block starts on the page's one left edge (rule 6), so a
  // button's padding must not push its icon or label inward.
  group('one left edge', () {
    Future<void> pumpSignedIn(WidgetTester tester) async {
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
    }

    testWidgets('Bugün: "Yakında" starts where the cards start', (
      tester,
    ) async {
      await pumpSignedIn(tester);
      final cardLeft = tester.getTopLeft(find.byType(Card).first).dx;
      expect(tester.getTopLeft(find.text('Yakında').last).dx, cardLeft);
      expect(tester.getTopLeft(find.text('Merhaba, Elif')).dx, cardLeft);
    });

    testWidgets('Profil: "Çıkış yap" starts on the page edge', (tester) async {
      await pumpSignedIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Çıkış yap'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      final edge = tester.getTopLeft(find.text('Yakında')).dx;
      final signOut = find.ancestor(
        of: find.text('Çıkış yap'),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      final icon = find.descendant(
        of: signOut,
        matching: find.byIcon(Icons.logout),
      );
      expect(tester.getTopLeft(icon).dx, edge);
      expect(tester.getSize(signOut).height, greaterThanOrEqualTo(48));
    });

    testWidgets('Profil: "Düzenle" ends on the card\'s right edge', (
      tester,
    ) async {
      await pumpSignedIn(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopRight(find.text('Düzenle')).dx,
        tester.getTopRight(find.byType(Card).first).dx,
      );
    });

    testWidgets('login and signup links start on the fields\' edge', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            profileRepositoryProvider.overrideWithValue(
              FakeProfileRepository(),
            ),
          ],
          child: const ClientApp(),
        ),
      );
      await tester.pumpAndSettle();
      double fieldLeft() =>
          tester.getTopLeft(find.byType(TextField).first).dx;

      expect(
        tester.getTopLeft(find.text('Hesabın yok mu? Kayıt ol')).dx,
        fieldLeft(),
      );
      expect(
        tester
            .getSize(
              find.widgetWithText(TextButton, 'Hesabın yok mu? Kayıt ol'),
            )
            .height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('Hesabın yok mu? Kayıt ol'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Zaten hesabın var mı? Giriş yap')).dx,
        fieldLeft(),
      );
    });
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
