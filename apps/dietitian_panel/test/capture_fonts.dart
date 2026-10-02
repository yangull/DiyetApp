import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Without this every glyph renders as a filled box: the test binding ships
/// only the placeholder font. Used by the capture tests, never by the suite.
///
/// The family name must carry the `packages/core/` prefix, because
/// `AppTypography` declares the faces with `package: 'core'` and that is the
/// name the text styles actually ask for. Registering the bare family loads a
/// font nothing ever looks up. Icons need `FLUTTER_ROOT` to find their font.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const dir = '../../packages/core/fonts';
  // One variable file: Flutter maps FontWeight onto its wght axis.
  const files = ['Alpino-Variable.ttf'];
  for (final family in ['Alpino', 'packages/core/Alpino']) {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = File('$dir/$file').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  // The lira sign's fallback font (Alpino has none).
  for (final family in ['Lira', 'packages/core/Lira']) {
    final loader = FontLoader(family)
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('$dir/PlusJakartaSans-Lira.ttf').readAsBytesSync(),
          ),
        ),
      );
    await loader.load();
  }

  // Lucide, the icon set (AppIcons): a regular and a heavy stroke.
  for (final (family, file) in [
    ('AppIcons', 'Lucide.ttf'),
    ('AppIconsHeavy', 'Lucide-Heavy.ttf'),
  ]) {
    for (final name in [family, 'packages/core/$family']) {
      final loader = FontLoader(name)
        ..addFont(
          Future.value(
            ByteData.sublistView(File('$dir/$file').readAsBytesSync()),
          ),
        );
      await loader.load();
    }
  }

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
