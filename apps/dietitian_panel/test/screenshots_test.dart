@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:dietitian_panel/main_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders every screen of the interview demo to `test/goldens/*.png`, so the
/// panel can be put in front of someone who is not sitting at Can's machine.
///
/// Not a regression suite: these are captured on demand and would otherwise
/// fail on every intentional pixel change, so the whole file is tagged and
/// excluded from `melos run test` via dart_test.yaml. Regenerate with:
///
/// ```sh
/// flutter test test/screenshots_test.dart --tags screenshots --update-goldens
/// ```
void main() {
  setUpAll(_loadFonts);

  _shot('01-genel-bakis', (tester) async {});

  _shot('02-danisanlar', (tester) async {
    await _open(tester, 'Danışanlar');
  });

  _shot('03-danisan-karti', (tester) async {
    await _open(tester, 'Danışanlar');
    await tester.tap(find.text('Elif Aydın').first);
    await tester.pumpAndSettle();
  }, height: 1900);

  _shot('04-danisan-karti-olcumler', (tester) async {
    await _open(tester, 'Danışanlar');
    await tester.tap(find.text('Elif Aydın').first);
    await tester.pumpAndSettle();
    await _scrollToBottom(tester);
  }, height: 1300);

  _shot('05-plan-editoru', (tester) async {
    await _open(tester, 'Danışanlar');
    await tester.tap(find.text('Elif Aydın').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Taslağı düzenle'));
    await tester.pumpAndSettle();
  }, height: 1900);

  _shot('06-degisim-listesi', (tester) async {
    await _open(tester, 'Danışanlar');
    await tester.tap(find.text('Elif Aydın').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Değişim listesiyle dene'));
    await tester.pumpAndSettle();
  }, height: 1900);

  _shot('07-yeni-danisan-anamnez', (tester) async {
    await _open(tester, 'Danışanlar');
    await tester.tap(find.text('Danışan ekle'));
    await tester.pumpAndSettle();
  }, height: 1520);

  _shot('08-randevular', (tester) async {
    await _open(tester, 'Randevular');
  }, height: 1400);

  // Shorter than the rest: the thread is bottom-anchored like every chat app,
  // so a very tall window just adds empty space above the first message.
  _shot('09-mesajlar', (tester) async {
    await _open(tester, 'Mesajlar');
  }, height: 820);

  _shot('10-odemeler', (tester) async {
    await _open(tester, 'Ödemeler');
  }, height: 1200);

  _shot('11-takip', (tester) async {
    await _open(tester, 'Takip');
  }, height: 1600);

  _shot('12-hatirlatmalar', (tester) async {
    await _open(tester, 'Hatırlatmalar');
  });
}

/// Wide enough that the Mesajlar context panel is shown (it drops below 980)
/// and the client table does not wrap — this is a desktop web panel.
const _width = 1600.0;

void _shot(
  String name,
  Future<void> Function(WidgetTester) navigate, {
  double height = 1000,
}) {
  testWidgets(name, (tester) async {
    // 1.5 keeps text crisp at any size a slide will show it, at roughly
    // half the bytes of a full 2x capture.
    const scale = 1.5;
    tester.view.devicePixelRatio = scale;
    tester.view.physicalSize = Size(_width * scale, height * scale);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: DietitianPanelDemoApp()),
    );
    await tester.pumpAndSettle();
    await navigate(tester);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  });
}

Future<void> _open(WidgetTester tester, String destination) async {
  await tester.tap(find.text(destination));
  await tester.pumpAndSettle();
}

Future<void> _scrollToBottom(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.drag(scrollable, const Offset(0, -4000));
  await tester.pumpAndSettle();
}

/// Without this every glyph renders as a filled box: the test binding ships
/// only the placeholder font, and the panel's whole look is Fraunces + Figtree.
///
/// The family name must carry the `packages/core/` prefix, because
/// `AppTypography` declares the faces with `package: 'core'` and that is the
/// name the text styles actually ask for. Registering the bare family loads a
/// font nothing ever looks up.
Future<void> _loadFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const dir = '../../packages/core/fonts';
  const faces = {
    'Fraunces': ['Fraunces-SemiBold.ttf'],
    'Figtree': ['Figtree-Regular.ttf', 'Figtree-SemiBold.ttf'],
  };

  for (final entry in faces.entries) {
    for (final family in [entry.key, 'packages/core/${entry.key}']) {
      final loader = FontLoader(family);
      for (final file in entry.value) {
        final bytes = File('$dir/$file').readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    }
  }

  // Icons are a font too, and the test binding does not ship it either — every
  // Icon renders as the same box as unstyled text without this.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return;
  final icons = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!icons.existsSync()) return;
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
  await iconLoader.load();
}
