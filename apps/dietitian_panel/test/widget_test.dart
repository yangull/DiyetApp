import 'dart:async';

import 'package:core/core.dart';
import 'package:dietitian_panel/main.dart';
import 'package:dietitian_panel/panel/real_client_detail_screen.dart';
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
      expect(find.text('bekleyen@example.com'), findsOneWidget);
      // Active clients and invites are separate sections (direction B); the
      // invite says what became of it.
      expect(find.text('DANIŞANLAR'), findsOneWidget);
      expect(find.text('DAVETLER'), findsOneWidget);
      expect(find.text('Davet bekliyor'), findsOneWidget);
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

    testWidgets('a failed load still lets the dietitian invite', (
      tester,
    ) async {
      await pumpList(tester, () => _FlakyRelationships(failures: 1), (_, _) {});
      expect(find.text('Danışan listesi yüklenemedi'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Danışan davet et'),
        findsOneWidget,
      );
    });

    testWidgets('only invites: no active client yet, one waiting', (
      tester,
    ) async {
      await pumpList(
        tester,
        FakeClientRelationshipRepository.new,
        (repo, dietitianId) => repo
          ..seedRelationship(
            dietitianId: dietitianId,
            invitedEmail: 'bekleyen@example.com',
          )
          ..seedRelationship(
            dietitianId: dietitianId,
            invitedEmail: 'hayir@example.com',
            status: RelationshipStatus.declined,
          ),
      );
      expect(find.text('Henüz aktif danışanınız yok'), findsOneWidget);
      expect(find.text('1 davet yanıt bekliyor.'), findsOneWidget);
      expect(find.text('DANIŞANLAR'), findsNothing);
    });

    testWidgets('names that fail to load fall back to the address', (
      tester,
    ) async {
      await pumpList(
        tester,
        _NamelessRelationships.new,
        (repo, dietitianId) => repo.seedRelationship(
          dietitianId: dietitianId,
          invitedEmail: 'elif@example.com',
          clientId: 'client-1',
          status: RelationshipStatus.active,
        ),
      );
      expect(
        find.text('Danışan adları yüklenemedi; adreslerle gösteriliyor.'),
        findsOneWidget,
      );
      expect(find.text('elif@example.com'), findsOneWidget);
    });

    testWidgets('a blank name shows the address, not an empty line', (
      tester,
    ) async {
      await pumpList(
        tester,
        FakeClientRelationshipRepository.new,
        (repo, dietitianId) => repo
          ..seedRelationship(
            dietitianId: dietitianId,
            invitedEmail: 'adsiz@example.com',
            clientId: 'client-1',
            status: RelationshipStatus.active,
          )
          ..seedClientName('client-1', ' '),
      );
      expect(find.text('adsiz@example.com'), findsOneWidget);
      expect(
        find.bySemanticsLabel('adsiz@example.com, danışanı aç'),
        findsOneWidget,
      );
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

  // Slice 5 wrapped the greeting and the button so they could reflow at 2×;
  // Direction B: the invite is the screen's one filled action, at the right
  // end of the focal card, on the card's inner edge.
  testWidgets('"Danışan davet et" sits at the focal card\'s right edge', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1000);
    addTearDown(tester.view.reset);
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
        invitedEmail: 'a@example.com',
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
    final button = tester.getTopRight(
      find.widgetWithText(FilledButton, 'Danışan davet et'),
    );
    final card = tester.getTopRight(
      find.ancestor(
        of: find.widgetWithText(FilledButton, 'Danışan davet et'),
        matching: find.byType(Card),
      ),
    );
    expect(button.dx, moreOrLessEquals(card.dx - 20, epsilon: 0.5));
    // A pending invite only: the invites have the second column.
    final invites = tester.getTopLeft(find.text('DAVETLER'));
    expect(invites.dx, greaterThan(button.dx - 400));
  });

  testWidgets('the real list says it is loading while it loads', (
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
    final repo = _SlowRelationships();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(repo),
        ],
        child: const DietitianPanelApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.bySemanticsLabel('Danışanlar yükleniyor'), findsOneWidget);
    expect(find.textContaining('Hoş geldiniz'), findsOneWidget);
    repo.release.complete();
    await tester.pumpAndSettle();
    expect(find.text('Henüz danışanınız yok'), findsOneWidget);
  });

  testWidgets('an active client row opens the client record', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1600, 1000);
    addTearDown(tester.view.reset);
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
    expect(find.textContaining('Bekleyen davet yok'), findsOneWidget);
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Elif Aydın, danışanı aç')),
      matchesSemantics(
        label: 'Elif Aydın, danışanı aç',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
    await tester.tap(find.text('Elif Aydın'));
    await tester.pumpAndSettle();
    expect(find.byType(RealClientDetailScreen), findsOneWidget);
  });

  testWidgets('the client and invite cards grow with 2× text', (tester) async {
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

    expectTextNotClipped(tester, find.byType(Card));
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

        // Every fact is on its own row. At
        // large text the list starts below the fold, so scroll to it.
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

/// Holds the first load open until the test releases it.
class _SlowRelationships extends FakeClientRelationshipRepository {
  final release = Completer<void>();

  @override
  Future<List<ClientRelationship>> fetchForDietitian(String dietitianId) async {
    await release.future;
    return super.fetchForDietitian(dietitianId);
  }
}

class _NamelessRelationships extends FakeClientRelationshipRepository {
  @override
  Future<List<ClientName>> fetchClientNames(String dietitianId) =>
      Future.error(Exception('ad sorgusu başarısız'));
}
