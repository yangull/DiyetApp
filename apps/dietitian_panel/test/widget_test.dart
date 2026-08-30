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
        fullName: 'Dyt. Kutay',
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
      fullName: 'Dyt. Kutay',
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
    await tester.tap(find.text('Davet gönderin'));
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
}
