import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no screen draws a Material icon: AppIcons is the one set', () {
    // The icon pack changes in app_icons.dart only; framework widgets that
    // draw their own icon are themed (back arrow, dropdown arrow).
    final offenders = <String>[];
    for (final root in [
      'lib',
      '../../apps/client/lib',
      '../../apps/dietitian_panel/lib',
    ]) {
      for (final file in Directory(root).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        if (file.path.endsWith('app_icons.dart')) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (RegExp(r'(?<![A-Za-z_.])Icons\.[a-z]').hasMatch(lines[i])) {
            offenders.add('${file.path}:${i + 1}');
          }
        }
      }
    }
    expect(offenders, isEmpty);
  });

  testWidgets('a line with the lira sign is as tall as one without', (
    tester,
  ) async {
    // The fallback font's vertical metrics match Alpino's, so a price does
    // not grow its line or drop its baseline.
    for (final (family, file) in [
      ('packages/core/Alpino', 'fonts/Alpino-Variable.ttf'),
      ('packages/core/Lira', 'fonts/PlusJakartaSans-Lira.ttf'),
    ]) {
      final bytes = File(file).readAsBytesSync();
      final loader = FontLoader(
        family,
      )..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
      await loader.load();
    }
    final style = AppTheme.light(AppDensity.comfortable).textTheme.bodyLarge!;
    double height(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      final h = painter.height;
      painter.dispose();
      return h;
    }

    expect(height('\u20ba250'), height('250'));

    // And the sign is drawn by Lira, not by whatever the platform falls back
    // to: a fixed line height alone would hold with any font.
    double width(TextStyle s) {
      final painter = TextPainter(
        text: TextSpan(text: '\u20ba', style: s),
        textDirection: TextDirection.ltr,
      )..layout();
      final w = painter.width;
      painter.dispose();
      return w;
    }

    final viaLira = width(style.copyWith(fontFamily: 'packages/core/Lira'));
    expect(width(style), viaLira);
    expect(
      width(
        TextStyle(
          fontFamily: style.fontFamily,
          fontSize: style.fontSize,
          height: style.height,
        ),
      ),
      isNot(viaLira),
    );
  });
}
