import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.x contrast ratio of two opaque colours.
double contrast(Color a, Color b) {
  double channel(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  // Building a TextStyle touches ServicesBinding, and plain test() cases have
  // no binding of their own.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppConfig reports missing configuration without dart-defines', () {
    expect(AppConfig.supabaseUrl, isEmpty);
    expect(AppConfig.isConfigured, isFalse);
  });

  test('theme uses the measured brand palette, not a generated seed', () {
    final theme = AppTheme.light(AppDensity.comfortable);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.surface, AppColors.surface);
    expect(theme.scaffoldBackgroundColor, AppColors.ground);
  });

  test('both density profiles share colors but differ in metrics', () {
    final comfortable = AppTheme.light(AppDensity.comfortable);
    final compact = AppTheme.light(AppDensity.compact);

    expect(comfortable.colorScheme.primary, compact.colorScheme.primary);
    expect(comfortable.extension<AppPalette>(), isNotNull);
    expect(
      comfortable.extension<AppDensity>()!.controlHeight,
      greaterThan(compact.extension<AppDensity>()!.controlHeight),
    );
    expect(compact.extension<AppDensity>()!.isCompact, isTrue);
  });

  test('typography uses the bundled font assets, never a runtime fetch', () {
    final text = AppTheme.light(AppDensity.comfortable).textTheme;

    expect(text.headlineLarge!.fontFamily, 'packages/core/Fraunces');
    expect(text.bodyMedium!.fontFamily, 'packages/core/Figtree');
  });

  group('measured palette (PLANNING #58)', () {
    void atLeast(Color fg, Color bg, double min, String what) {
      expect(contrast(fg, bg), greaterThanOrEqualTo(min), reason: what);
    }

    test('text tokens keep AA on every background they sit on', () {
      for (final bg in [
        AppColors.surface,
        AppColors.ground,
        AppColors.surfaceSubtle,
      ]) {
        atLeast(AppColors.textPrimary, bg, 4.5, 'textPrimary');
        atLeast(AppColors.textSecondary, bg, 4.5, 'textSecondary');
      }
      atLeast(AppColors.textMuted, AppColors.ground, 4.5, 'textMuted/ground');
      atLeast(AppColors.primary, AppColors.ground, 4.5, 'primary/ground');
      atLeast(
        AppColors.primaryHover,
        AppColors.surfaceSubtle,
        4.5,
        'links on surfaceSubtle use primaryHover',
      );
      atLeast(AppColors.borderStrong, AppColors.ground, 3, 'borderStrong');
      atLeast(AppColors.warning, AppColors.warningTint, 4.5, 'warning/tint');
    });

    test('the hero block keeps its text readable and its ring visible', () {
      atLeast(AppColors.onPrimary, AppColors.hero, 4.5, 'white on hero');
      atLeast(AppColors.onHeroSecondary, AppColors.hero, 4.5, 'secondary');
      atLeast(AppColors.onHighlight, AppColors.highlight, 4.5, 'on highlight');
      atLeast(AppColors.highlight, AppColors.hero, 3, 'highlight on hero');
      atLeast(AppColors.highlight, AppColors.heroTrack, 3, 'arc vs track');
    });

    test(
      'exchange-group colours read on white, on their track and as chips',
      () {
        expect(ExchangeGroupColors.all, hasLength(8));
        for (final g in ExchangeGroupColors.all) {
          atLeast(g.bar, AppColors.surface, 3, 'bar on white');
          atLeast(g.bar, AppColors.surfaceSubtle, 3, 'bar on its track');
          atLeast(g.chipText, g.chipTint, 4.5, 'chip text');
          expect(g.bar, isNot(AppColors.aiDraft));
        }
      },
    );
  });

  test('numbers use Figtree Bold with tabular figures', () {
    final style = AppTypography.figures(32, 36);
    expect(style.fontFamily, 'packages/core/Figtree');
    expect(style.fontWeight, FontWeight.w700);
    expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  testWidgets('motion drops to zero when the OS asks for reduced motion', (
    tester,
  ) async {
    late Duration normal;
    late Duration reduced;
    await tester.pumpWidget(
      Column(
        children: [
          Builder(
            builder: (context) {
              normal = AppMotion.of(context, AppMotion.change);
              return const SizedBox();
            },
          ),
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                reduced = AppMotion.of(context, AppMotion.change);
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
    expect(normal, AppMotion.change);
    expect(reduced, Duration.zero);
  });
}
