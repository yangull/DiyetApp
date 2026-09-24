import 'package:core/core.dart';
import 'package:dietitian_panel/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'text_fits.dart';

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

    expect(find.text('Giriş yap'), findsOneWidget);
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
        fullName: 'Dyt. Deniz',
        status: VerificationStatus.approved,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            profileRepositoryProvider.overrideWithValue(profiles),
            clientRelationshipRepositoryProvider.overrideWithValue(
              FakeClientRelationshipRepository(),
            ),
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

  testWidgets(
    'the client list shows an active client by name and a pending invite',
    (tester) async {
      final auth = FakeAuthRepository();
      final profiles = FakeProfileRepository();
      await auth.signIn(email: 'dyt@example.com', password: 'sifresifre');
      final dietitianId = auth.currentSession!.userId;
      profiles.seedDietitian(
        dietitianId,
        fullName: 'Dyt. Deniz',
        status: VerificationStatus.approved,
      );

      final relationships = FakeClientRelationshipRepository()
        ..seedRelationship(
          dietitianId: dietitianId,
          invitedEmail: 'elif@example.com',
          clientId: 'client-1',
          status: RelationshipStatus.active,
        )
        ..seedClientName('client-1', 'Elif Aydın')
        ..seedRelationship(
          dietitianId: dietitianId,
          invitedEmail: 'bekleyen@example.com',
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
          child: const DietitianPanelApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Henüz danışanınız yok'), findsNothing);
      expect(find.text('Elif Aydın'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('bekleyen@example.com'), findsOneWidget);
      // The pending row names no client and cannot be opened.
      expect(find.text('Davet bekliyor'), findsNWidgets(2));
    },
  );

  group('the real client list', () {
    Future<FakeClientRelationshipRepository> pumpList(
      WidgetTester tester,
      FakeClientRelationshipRepository Function() makeRepo,
      void Function(FakeClientRelationshipRepository, String dietitianId) seed,
    ) async {
      final auth = FakeAuthRepository();
      final profiles = FakeProfileRepository();
      await auth.signIn(email: 'dyt@example.com', password: 'sifresifre');
      final dietitianId = auth.currentSession!.userId;
      profiles.seedDietitian(
        dietitianId,
        fullName: 'Dyt. Deniz',
        status: VerificationStatus.approved,
      );
      final relationships = makeRepo();
      seed(relationships, dietitianId);

      await tester.pumpWidget(
        ProviderScope(
          // Riverpod retries a failed provider on its own; off here so the
          // error state is reached and the button is what retries.
          retry: (_, _) => null,
          overrides: [
            authRepositoryProvider.overrideWithValue(auth),
            profileRepositoryProvider.overrideWithValue(profiles),
            clientRelationshipRepositoryProvider.overrideWithValue(
              relationships,
            ),
          ],
          child: const DietitianPanelApp(),
        ),
      );
      await tester.pumpAndSettle();
      return relationships;
    }

    testWidgets('a declined invite does not say it is waiting', (tester) async {
      await pumpList(
        tester,
        FakeClientRelationshipRepository.new,
        (repo, dietitianId) => repo.seedRelationship(
          dietitianId: dietitianId,
          invitedEmail: 'hayir@example.com',
          status: RelationshipStatus.declined,
        ),
      );

      expect(find.text('Davet reddedildi'), findsOneWidget);
      expect(find.text('Davet bekliyor'), findsNothing);
    });

    testWidgets('a failed load explains itself in Turkish and retries', (
      tester,
    ) async {
      final repo = await pumpList(
        tester,
        () => _FlakyRelationships(failures: 1),
        (repo, dietitianId) => repo.seedRelationship(
          dietitianId: dietitianId,
          invitedEmail: 'bekleyen@example.com',
        ),
      );

      expect(find.text('Danışan listesi yüklenemedi'), findsOneWidget);
      expect(find.textContaining('Exception'), findsNothing);

      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();

      expect((repo as _FlakyRelationships).failures, 0);
      expect(find.text('bekleyen@example.com'), findsOneWidget);
    });
  });

  testWidgets('another dietitian sees none of the first one\'s clients', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'ikinci@example.com', password: 'sifresifre');
    final secondDietitianId = auth.currentSession!.userId;
    profiles.seedDietitian(
      secondDietitianId,
      fullName: 'Dyt. İkinci',
      status: VerificationStatus.approved,
    );

    // Seeded against a different dietitian entirely.
    final relationships = FakeClientRelationshipRepository()
      ..seedRelationship(
        dietitianId: 'baska-diyetisyen',
        invitedEmail: 'elif@example.com',
        clientId: 'client-1',
        status: RelationshipStatus.active,
      )
      ..seedClientName('client-1', 'Elif Aydın');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(relationships),
        ],
        child: const DietitianPanelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Elif Aydın'), findsNothing);
    expect(find.text('Henüz danışanınız yok'), findsOneWidget);
  });

  testWidgets('inviting a client adds a pending row to the list', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'dyt@example.com', password: 'sifresifre');
    profiles.seedDietitian(
      auth.currentSession!.userId,
      fullName: 'Dyt. Deniz',
      status: VerificationStatus.approved,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(
            FakeClientRelationshipRepository(),
          ),
        ],
        child: const DietitianPanelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Danışan davet et'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Yeni@Example.com');
    await tester.tap(find.text('Davet gönder'));
    await tester.pumpAndSettle();

    // Normalized on the way in, so it matches the JWT email comparison the
    // accept policy makes later.
    expect(find.text('yeni@example.com'), findsOneWidget);
    expect(find.text('Henüz danışanınız yok'), findsNothing);
  });

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

  testWidgets('on a phone the approved panel has a bottom bar, not a rail', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    addTearDown(tester.view.reset);

    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'dyt@example.com', password: 'sifresifre');
    profiles.seedDietitian(
      auth.currentSession!.userId,
      fullName: 'Dyt. Deniz',
      status: VerificationStatus.approved,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(
            FakeClientRelationshipRepository(),
          ),
        ],
        child: const DietitianPanelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    // Touch-sized controls on phones (#38, #64).
    final context = tester.element(find.byType(NavigationBar));
    expect(context.density.isCompact, isFalse);
  });

  testWidgets('the wide client table grows with 2× text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final auth = FakeAuthRepository();
    final profiles = FakeProfileRepository();
    await auth.signIn(email: 'dyt@example.com', password: 'sifresifre');
    final dietitianId = auth.currentSession!.userId;
    profiles.seedDietitian(
      dietitianId,
      fullName: 'Dyt. Deniz',
      status: VerificationStatus.approved,
    );
    final relationships = FakeClientRelationshipRepository()
      ..seedRelationship(
        dietitianId: dietitianId,
        invitedEmail: 'elif.aydin.uzun.adres@example.com',
        clientId: 'client-1',
        status: RelationshipStatus.active,
      )
      ..seedClientName('client-1', 'Elif Aydın Karaoğlanoğlu')
      ..seedRelationship(
        dietitianId: dietitianId,
        invitedEmail: 'bekleyen.danisan.uzun@example.com',
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(relationships),
        ],
        child: const DietitianPanelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expectTextNotClipped(
      tester,
      find.ancestor(
        of: find.text('elif.aydin.uzun.adres@example.com'),
        matching: find.byType(Card),
      ),
    );
  });

  for (final width in [360.0, 412.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets('the client list stacks on a $width dp phone at $scale×', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 3;
        tester.view.physicalSize = Size(width * 3, 740 * 3);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final auth = FakeAuthRepository();
        final profiles = FakeProfileRepository();
        await auth.signIn(email: 'dyt@example.com', password: 'sifresifre');
        final dietitianId = auth.currentSession!.userId;
        profiles.seedDietitian(
          dietitianId,
          fullName: 'Dyt. Deniz Karaoğlanoğlu',
          status: VerificationStatus.approved,
        );
        final relationships = FakeClientRelationshipRepository()
          ..seedRelationship(
            dietitianId: dietitianId,
            invitedEmail: 'elif.aydin.uzun.adres@example.com',
            clientId: 'client-1',
            status: RelationshipStatus.active,
          )
          ..seedClientName('client-1', 'Elif Aydın')
          ..seedRelationship(
            dietitianId: dietitianId,
            invitedEmail: 'bekleyen@example.com',
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
            child: const DietitianPanelApp(),
          ),
        );
        await tester.pumpAndSettle();

        // No column headings on a phone; every fact is on its own row. At
        // large text the list starts below the fold, so scroll to it.
        expect(find.text('E-POSTA'), findsNothing);
        await tester.scrollUntilVisible(
          find.text('elif.aydin.uzun.adres@example.com'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Elif Aydın'), findsOneWidget);
        expect(find.text('elif.aydin.uzun.adres@example.com'), findsOneWidget);
      });
    }
  }
}

class _FlakyRelationships extends FakeClientRelationshipRepository {
  _FlakyRelationships({required this.failures});

  int failures;

  @override
  Future<List<ClientRelationship>> fetchForDietitian(String dietitianId) {
    if (failures > 0) {
      failures--;
      return Future.error(Exception('bağlantı koptu'));
    }
    return super.fetchForDietitian(dietitianId);
  }
}
