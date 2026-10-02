@Tags(['screenshots'])
library;

// Polish-audit captures (HANDOFF A2): every screen of the real panel and the
// demo, on a phone and a computer, light and dark. Run from this app:
//
//   FLUTTER_ROOT=~/development/flutter CAPTURE_DIR=/some/dir \
//   flutter test test/audit_captures_test.dart --tags screenshots \
//   --run-skipped --update-goldens

import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dietitian_panel/main.dart';
import 'package:dietitian_panel/main_demo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'capture_fonts.dart';

final _out = Platform.environment['CAPTURE_DIR'] ?? 'goldens/audit';

class _FixedTheme extends ThemeModeNotifier {
  _FixedTheme(this.mode);
  final ThemeMode mode;

  @override
  ThemeMode build() => mode;
}

class _FailingRelationships extends FakeClientRelationshipRepository {
  @override
  Future<List<ClientRelationship>> fetchForDietitian(String id) =>
      Future.error(StateError('offline'));

  @override
  Future<List<ClientName>> fetchClientNames(String id) =>
      Future.error(StateError('offline'));
}

class _HangingRelationships extends FakeClientRelationshipRepository {
  @override
  Future<List<ClientRelationship>> fetchForDietitian(String id) =>
      Completer<List<ClientRelationship>>().future;
}

typedef _Build = Future<Widget> Function(ThemeMode mode);
typedef _Act = Future<void> Function(WidgetTester tester);

Widget _scope(
  ThemeMode mode,
  Widget app, {
  List<Override> overrides = const [],
}) => ProviderScope(
  overrides: [
    themeModeProvider.overrideWith(() => _FixedTheme(mode)),
    ...overrides,
  ],
  child: app,
);

Future<Widget> _demo(ThemeMode mode) async =>
    _scope(mode, const DietitianPanelDemoApp());

Future<Widget> _real(
  ThemeMode mode, {
  bool signedIn = true,
  VerificationStatus status = VerificationStatus.approved,
  UserRole role = UserRole.dietitian,
  FakeClientRelationshipRepository? relationships,
  bool seedProfile = true,
}) async {
  final auth = FakeAuthRepository();
  final profiles = FakeProfileRepository();
  if (signedIn) {
    await auth.signIn(email: 'deniz@example.com', password: 'sifresifre');
    final id = auth.currentSession!.userId;
    if (seedProfile) {
      if (role == UserRole.dietitian) {
        profiles.seedDietitian(
          id,
          fullName: 'Dyt. Deniz Arslan',
          status: status,
        );
      } else {
        profiles.seedClient(id, fullName: 'Elif Aydın');
      }
    }
    profiles
      ..seedClient('c0', fullName: 'Elif Aydın')
      ..seedClient('c1', fullName: 'Ahmet Demir');
    await profiles.updateClientDetail(
      userId: 'c0',
      goal: 'Kilo vermek',
      budgetRange: '1.000–2.000 ₺',
      healthNotes: 'Hafif insülin direnci. Süt ürünlerine duyarlılık.',
    );
  }
  final repo = relationships ?? _populated(auth.currentSession?.userId ?? '');
  return _scope(
    mode,
    const DietitianPanelApp(),
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      profileRepositoryProvider.overrideWithValue(profiles),
      clientRelationshipRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

FakeClientRelationshipRepository _populated(String id) {
  final r = FakeClientRelationshipRepository();
  for (final (i, (name, email)) in [
    ('Elif Aydın', 'elif.aydin@example.com'),
    ('Ahmet Demir', 'ahmet.demir@example.com'),
    ('Zeynep Kaya', 'zeynep.kaya@example.com'),
    ('Burak Şahin', 'burak.sahin@example.com'),
  ].indexed) {
    r
      ..seedRelationship(
        dietitianId: id,
        invitedEmail: email,
        clientId: 'c$i',
        status: RelationshipStatus.active,
      )
      ..seedClientName('c$i', name);
  }
  r
    ..seedRelationship(dietitianId: id, invitedEmail: 'merve@example.com')
    ..seedRelationship(
      dietitianId: id,
      invitedEmail: 'can.oz@example.com',
      status: RelationshipStatus.declined,
    );
  return r;
}

Future<void> _tap(WidgetTester t, String text, {bool first = true}) async {
  final f = find.text(text);
  final target = first ? f.first : f.last;
  if (target.hitTestable().evaluate().isEmpty) {
    await t.scrollUntilVisible(
      target,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await t.tap(target);
  await t.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    WidgetsApp.debugAllowBannerOverride = false;
    await loadAppFonts();
  });

  // ---- real panel ----
  _scenario('real-login', (m) => _real(m, signedIn: false));
  _scenario(
    'real-signup',
    (m) => _real(m, signedIn: false),
    act: (t) => _tap(t, 'Hesabınız yok mu? Kayıt olun'),
  );
  _scenario(
    'real-login-hatali',
    (m) => _real(m, signedIn: false),
    act: (t) => _tap(t, 'Giriş yap'),
  );
  _scenario(
    'real-signup-hatali',
    (m) => _real(m, signedIn: false),
    act: (t) async {
      await _tap(t, 'Hesabınız yok mu? Kayıt olun');
      await _tap(t, 'Kayıt ol');
    },
  );
  _scenario(
    'real-pending',
    (m) => _real(m, status: VerificationStatus.pending),
  );
  _scenario(
    'real-rejected',
    (m) => _real(m, status: VerificationStatus.rejected),
  );
  _scenario('real-genel-bakis', (m) => _real(m));
  _scenario(
    'real-genel-bakis-bos',
    (m) => _real(m, relationships: FakeClientRelationshipRepository()),
  );
  _scenario(
    'real-genel-bakis-yukleniyor',
    (m) => _real(m, relationships: _HangingRelationships()),
    settle: false,
  );
  _scenario(
    'real-genel-bakis-hata',
    (m) => _real(m, relationships: _FailingRelationships()),
  );
  _scenario(
    'real-davet-dialog',
    (m) => _real(m),
    act: (t) => _tap(t, 'Danışan davet et'),
  );
  _scenario(
    'real-danisan-detay',
    (m) => _real(m),
    act: (t) => _tap(t, 'Elif Aydın'),
  );
  _scenario(
    'real-danisan-detay-bos',
    (m) => _real(m),
    act: (t) => _tap(t, 'Ahmet Demir'),
  );
  _scenario(
    'real-danisan-detay-hata',
    (m) => _real(m),
    act: (t) => _tap(t, 'Burak Şahin'),
  );
  _scenario('real-profil', (m) => _real(m), act: (t) => _tap(t, 'Profil'));
  _scenario('real-yanlis-uygulama', (m) => _real(m, role: UserRole.client));
  _scenario('real-profil-yuklenemedi', (m) => _real(m, seedProfile: false));

  // ---- demo ----
  _scenario('demo-genel-bakis', _demo);
  _scenario('demo-danisanlar', _demo, act: (t) => _tap(t, 'Danışanlar'));
  _scenario(
    'demo-danisan-karti',
    _demo,
    act: (t) async {
      await _tap(t, 'Danışanlar');
      await _tap(t, 'Elif Aydın');
    },
  );
  _scenario(
    'demo-plan-editoru',
    _demo,
    act: (t) async {
      await _tap(t, 'Danışanlar');
      await _tap(t, 'Elif Aydın');
      await _tap(t, 'Taslağı düzenle');
    },
  );
  _scenario(
    'demo-degisim-listesi',
    _demo,
    act: (t) async {
      await _tap(t, 'Danışanlar');
      await _tap(t, 'Elif Aydın');
      await _tap(t, 'Değişim listesiyle dene');
    },
  );
  _scenario(
    'demo-yeni-danisan',
    _demo,
    act: (t) async {
      await _tap(t, 'Danışanlar');
      await _tap(t, 'Danışan ekle');
    },
  );
  _scenario('demo-randevular', _demo, act: (t) => _tap(t, 'Randevular'));
  _scenario(
    'demo-gorusme',
    _demo,
    act: (t) async {
      await _tap(t, 'Randevular');
      await _tap(t, 'Görüşmeye başla');
    },
  );
  _scenario('demo-mesajlar', _demo, act: (t) => _tap(t, 'Mesajlar'));
  _scenario('demo-takip', _demo, act: (t) => _tap(t, 'Takip'));
  _scenario(
    'demo-hatirlatmalar',
    _demo,
    act: (t) async {
      if (find.text('Hatırlatma ayarları').evaluate().isNotEmpty) {
        await _tap(t, 'Hatırlatma ayarları');
      } else {
        await _tap(t, 'Demo');
        await _tap(t, 'Hatırlatma ayarları');
      }
    },
  );
  _scenario(
    'demo-filtre',
    _demo,
    act: (t) async {
      await _tap(t, 'Danışanlar');
      if (find.text('Filtrele').evaluate().isNotEmpty) {
        await _tap(t, 'Filtrele');
      }
    },
    phoneOnly: true,
  );
  _scenario(
    'demo-sifirla',
    _demo,
    act: (t) async {
      if (find.text('Sıfırla').evaluate().isNotEmpty) {
        await _tap(t, 'Sıfırla');
      } else {
        await _tap(t, 'Demo');
        await _tap(t, 'Demoyu sıfırla');
      }
    },
  );
}

const _sizes = <(String, Size, TargetPlatform)>[
  ('phone', Size(412, 915), TargetPlatform.android),
  ('desktop', Size(1440, 900), TargetPlatform.windows),
];

void _scenario(
  String name,
  _Build build, {
  _Act? act,
  bool settle = true,
  bool phoneOnly = false,
}) {
  for (final (label, size, platform) in _sizes) {
    if (phoneOnly && label != 'phone') continue;
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      final file = '$name-$label-${mode.name}';
      testWidgets(file, (tester) async {
        const scale = 1.5;
        tester.view.devicePixelRatio = scale;
        tester.view.physicalSize = size * scale;
        addTearDown(tester.view.reset);
        debugDefaultTargetPlatformOverride = platform;
        try {
          final app = await tester.runAsync(() => build(mode));
          await tester.pumpWidget(app!);
          if (settle) {
            await tester.pumpAndSettle();
          } else {
            for (var i = 0; i < 10; i++) {
              await tester.pump(const Duration(milliseconds: 100));
            }
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
}

/// Jumps the longest visible vertical scrollable to its end; false when
/// nothing on screen scrolls, so short screens get one capture only.
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
