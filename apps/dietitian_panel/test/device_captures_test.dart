@Tags(['screenshots'])
library;

// Genel Bakış, demo and real, on a 412 dp phone and a 1440 px desktop with
// real fonts: the before/after captures of the direction-B revamp (PLANNING
// #133). Tagged and skipped like screenshots_test.dart. Run from this app:
//
//   FLUTTER_ROOT=~/development/flutter CAPTURE_DIR=/some/dir \
//   CAPTURE_PREFIX=after flutter test test/device_captures_test.dart \
//   --tags screenshots --run-skipped --update-goldens

import 'dart:io';

import 'package:core/core.dart';
import 'package:dietitian_panel/main.dart';
import 'package:dietitian_panel/main_demo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_fonts.dart';

final _out = Platform.environment['CAPTURE_DIR'] ?? 'goldens/revamp';
final _prefix = Platform.environment['CAPTURE_PREFIX'] ?? 'shot';

void main() {
  setUpAll(() async {
    WidgetsApp.debugAllowBannerOverride = false;
    await loadAppFonts();
  });

  for (final (label, size, platform) in [
    ('phone-412', const Size(412, 915), TargetPlatform.android),
    ('phone-412-full', const Size(412, 1700), TargetPlatform.android),
    ('desktop-1440', const Size(1440, 900), TargetPlatform.windows),
  ]) {
    _capture('$_prefix-demo-$label', size, platform, () async {
      return const ProviderScope(child: DietitianPanelDemoApp());
    });
    _capture('$_prefix-real-$label', size, platform, () async {
      final auth = FakeAuthRepository();
      final profiles = FakeProfileRepository();
      await auth.signIn(email: 'deniz@example.com', password: 'sifresifre');
      final id = auth.currentSession!.userId;
      profiles.seedDietitian(
        id,
        fullName: 'Dyt. Deniz Arslan',
        status: VerificationStatus.approved,
      );
      final relationships = FakeClientRelationshipRepository();
      for (final (i, (name, email)) in [
        ('Elif Aydın', 'elif.aydin@example.com'),
        ('Ahmet Demir', 'ahmet.demir@example.com'),
        ('Zeynep Kaya', 'zeynep.kaya@example.com'),
        ('Burak Şahin', 'burak.sahin@example.com'),
      ].indexed) {
        relationships
          ..seedRelationship(
            dietitianId: id,
            invitedEmail: email,
            clientId: 'c$i',
            status: RelationshipStatus.active,
          )
          ..seedClientName('c$i', name);
      }
      relationships
        ..seedRelationship(dietitianId: id, invitedEmail: 'merve@example.com')
        ..seedRelationship(
          dietitianId: id,
          invitedEmail: 'can.oz@example.com',
          status: RelationshipStatus.declined,
        );
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          clientRelationshipRepositoryProvider.overrideWithValue(relationships),
        ],
        child: const DietitianPanelApp(),
      );
    });
  }
}

void _capture(
  String name,
  Size size,
  TargetPlatform platform,
  Future<Widget> Function() app,
) {
  testWidgets(name, (tester) async {
    const scale = 2.0;
    tester.view.devicePixelRatio = scale;
    tester.view.physicalSize = size * scale;
    addTearDown(tester.view.reset);
    debugDefaultTargetPlatformOverride = platform;
    try {
      final widget = await tester.runAsync(app);
      await tester.pumpWidget(widget!);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(Uri.file('$_out/$name.png')),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
