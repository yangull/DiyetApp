import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fixed-height row clips a wrapped line without any overflow error, so
/// this compares each paragraph's laid-out height with the height its text
/// needs at that width.
void expectTextNotClipped(WidgetTester tester, Finder within) {
  final paragraphs = find.descendant(
    of: within,
    matching: find.byWidgetPredicate((w) => w is RichText),
  );
  expect(paragraphs, findsWidgets);
  for (final element in paragraphs.evaluate()) {
    final box = element.renderObject! as RenderParagraph;
    final needed = box.getMinIntrinsicHeight(box.size.width);
    expect(
      box.size.height,
      greaterThanOrEqualTo(needed - 0.5),
      reason: '"${box.text.toPlainText()}" is clipped',
    );
  }
}
