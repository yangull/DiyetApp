@Tags(['screenshots'])
library;

// Polish-audit captures of the client app (HANDOFF A2): every screen on a
// phone, light and dark. Run from this app:
//
//   FLUTTER_ROOT=~/development/flutter CAPTURE_DIR=/some/dir \
//   flutter test test/audit_captures_test.dart --tags screenshots \
//   --run-skipped --update-goldens

import 'dart:async';
import 'dart:io';

import 'package:client/main.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_fonts.dart';

final _out = Platform.environment['CAPTURE_DIR'] ?? 'goldens/audit';

class _FixedTheme extends ThemeModeNotifier {
  _FixedTheme(this.mode);
  final ThemeMode mode;

  @override
  ThemeMode build() => mode;
}

class _HangingProfiles extends FakeProfileRepository {
  @override
  Future<AppProfile> fetchProfile(String userId) =>
      Completer<AppProfile>().future;
}

class _FailingSaves extends FakeProfileRepository {
  var armed = false;

  @override
  Future<void> updateClientDetail({
    required String userId,
    String? goal,
    String? budgetRange,
    String? healthNotes,
  }) => armed
      ? Future.error(StateError('offline'))
      : super.updateClientDetail(
          userId: userId,
          goal: goal,
          budgetRange: budgetRange,
          healthNotes: healthNotes,
        );
}

late _FailingSaves _saves;

typedef _Build = Future<Widget> Function(ThemeMode mode);
typedef _Act = Future<void> Function(WidgetTester tester);

enum _Who { newClient, invited, connected }

Future<Widget> _app(
  ThemeMode mode, {
  bool signedIn = true,
  _Who who = _Who.newClient,
  UserRole role = UserRole.client,
  FakeProfileRepository? profiles,
}) async {
  final auth = FakeAuthRepository();
  final repo = profiles ?? FakeProfileRepository();
  final relationships = FakeClientRelationshipRepository();
  if (signedIn) {
    await auth.signIn(email: 'elif@example.com', password: 'sifresifre');
    final id = auth.currentSession!.userId;
    relationships
      ..currentUserId = id
      ..currentEmail = 'elif@example.com';
    if (profiles is! _HangingProfiles) {
      if (role == UserRole.dietitian) {
        repo.seedDietitian(id, fullName: 'Dyt. Deniz Arslan');
      } else {
        repo.seedClient(id, fullName: 'Elif Aydın');
      }
    }
    repo.seedDietitian('dyt-1', fullName: 'Dyt. Deniz Arslan');
    if (who == _Who.invited) {
      relationships.seedRelationship(
        dietitianId: 'dyt-1',
        invitedEmail: 'elif@example.com',
      );
    }
    if (who == _Who.connected) {
      relationships.seedRelationship(
        dietitianId: 'dyt-1',
        invitedEmail: 'elif@example.com',
        clientId: id,
        status: RelationshipStatus.active,
      );
      await repo.updateClientDetail(
        userId: id,
        goal: 'Kilo vermek ve daha dengeli beslenmek',
        budgetRange: '1.000–2.000 ₺',
        healthNotes: 'Hafif insülin direnci. Süt ürünlerine duyarlılık.',
      );
    }
  }
  return ProviderScope(
    overrides: [
      themeModeProvider.overrideWith(() => _FixedTheme(mode)),
      authRepositoryProvider.overrideWithValue(auth),
      profileRepositoryProvider.overrideWithValue(repo),
      clientRelationshipRepositoryProvider.overrideWithValue(relationships),
    ],
    child: const ClientApp(),
  );
}

Future<void> _tap(WidgetTester t, String text) async {
  await t.tap(find.text(text).first);
  await t.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    WidgetsApp.debugAllowBannerOverride = false;
    await loadAppFonts();
  });

  _scenario('login', (m) => _app(m, signedIn: false));
  _scenario(
    'signup',
    (m) => _app(m, signedIn: false),
    act: (t) => _tap(t, 'Hesabın yok mu? Kayıt ol'),
  );
  _scenario(
    'login-hatali',
    (m) => _app(m, signedIn: false),
    act: (t) => _tap(t, 'Giriş yap'),
  );
  _scenario(
    'signup-hatali',
    (m) => _app(m, signedIn: false),
    act: (t) async {
      await _tap(t, 'Hesabın yok mu? Kayıt ol');
      await _tap(t, 'Kayıt ol');
    },
  );
  _scenario('bugun-yeni', (m) => _app(m));
  _scenario('bugun-davet', (m) => _app(m, who: _Who.invited));
  _scenario('bugun-bagli', (m) => _app(m, who: _Who.connected));
  _scenario(
    'bugun-bagli-yazi-200',
    (m) => _app(m, who: _Who.connected),
    textScale: 2.0,
  );
  _scenario('profil-yeni', (m) => _app(m), act: (t) => _tap(t, 'Profil'));
  _scenario(
    'profil-bagli',
    (m) => _app(m, who: _Who.connected),
    act: (t) => _tap(t, 'Profil'),
  );
  _scenario(
    'profil-bagli-yazi-200',
    (m) => _app(m, who: _Who.connected),
    act: (t) => _tap(t, 'Profil'),
    textScale: 2.0,
  );
  _scenario('hedeflerim-bos', (m) => _app(m), act: (t) => _tap(t, 'Yaz'));
  _scenario(
    'hedeflerim-dolu',
    (m) => _app(m, who: _Who.connected),
    act: (t) => _tap(t, 'Düzenle'),
  );
  _scenario(
    'hedeflerim-kaydedilemedi',
    (m) => _app(m, who: _Who.connected, profiles: _saves = _FailingSaves()),
    act: (t) async {
      _saves.armed = true;
      await _tap(t, 'Düzenle');
      await _tap(t, 'Kaydet');
    },
  );
  _scenario(
    'yukleniyor',
    (m) => _app(m, profiles: _HangingProfiles()),
    settle: false,
  );
  _scenario('profil-yuklenemedi', (m) async {
    final auth = FakeAuthRepository();
    await auth.signIn(email: 'x@example.com', password: 'sifresifre');
    return ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(() => _FixedTheme(m)),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
      ],
      child: const ClientApp(),
    );
  });
  _scenario('yanlis-uygulama', (m) => _app(m, role: UserRole.dietitian));
}

void _scenario(
  String name,
  _Build build, {
  _Act? act,
  bool settle = true,
  double textScale = 1.0,
}) {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    if (textScale != 1.0 && mode == ThemeMode.dark) continue;
    final file = '$name-phone-${mode.name}';
    testWidgets(file, (tester) async {
      const scale = 1.5;
      tester.view.devicePixelRatio = scale;
      tester.view.physicalSize = const Size(412, 915) * scale;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final app = await tester.runAsync(() => build(mode));
        await tester.pumpWidget(app!);
        if (settle) {
          await tester.pumpAndSettle();
        } else {
          await tester.pump(const Duration(milliseconds: 300));
        }
        if (act != null) await act(tester);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(Uri.file('$_out/$file.png')),
        );
        if (await _scrollToEnd(tester)) {
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(Uri.file('$_out/$file-scrolled.png')),
          );
        }
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}

Future<bool> _scrollToEnd(WidgetTester tester) async {
  ScrollPosition? best;
  for (final element in find.byType(Scrollable).hitTestable().evaluate()) {
    final state = (element as StatefulElement).state;
    if (state is! ScrollableState) continue;
    final position = state.position;
    if (position.axis != Axis.vertical) continue;
    if (position.maxScrollExtent <= 1) continue;
    if (best == null || position.maxScrollExtent > best.maxScrollExtent) {
      best = position;
    }
  }
  if (best == null) return false;
  best.jumpTo(best.maxScrollExtent);
  await tester.pumpAndSettle();
  return true;
}
