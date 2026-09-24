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

  test('one bundled family, Figtree, with bold headings (#133)', () {
    final text = AppTheme.light(AppDensity.comfortable).textTheme;

    expect(text.headlineLarge!.fontFamily, 'packages/core/Figtree');
    expect(text.headlineLarge!.fontWeight, FontWeight.w700);
    expect(text.bodyMedium!.fontFamily, 'packages/core/Figtree');
  });

  test('the secondary button is the pale-green pill, not an outline', () {
    final style = AppTheme.light(AppDensity.comfortable)
        .outlinedButtonTheme
        .style!;
    const none = <WidgetState>{};
    const disabled = {WidgetState.disabled};

    expect(style.side!.resolve(none), BorderSide.none);
    expect(style.backgroundColor!.resolve(none), AppColors.primaryTint);
    expect(style.foregroundColor!.resolve(none), AppColors.primaryHover);
    expect(style.backgroundColor!.resolve(disabled), AppColors.surfaceSubtle);
    expect(style.foregroundColor!.resolve(disabled), AppColors.textMuted);
    expect(style.shape!.resolve(none), isA<StadiumBorder>());
  });

  test('every button is a pill; destructive confirms are red', () {
    final theme = AppTheme.light(AppDensity.compact);
    const none = <WidgetState>{};
    for (final style in [
      theme.filledButtonTheme.style!,
      theme.outlinedButtonTheme.style!,
      theme.textButtonTheme.style!,
    ]) {
      expect(style.shape!.resolve(none), isA<StadiumBorder>());
    }
    expect(
      AppTheme.destructiveButton.backgroundColor!.resolve(none),
      AppColors.error,
    );
  });

  test('dialog titles use Figtree, not the platform font', () {
    final text = AppTheme.light(AppDensity.comfortable).textTheme;
    expect(text.headlineSmall!.fontFamily, 'packages/core/Figtree');
  });

  test('the quiet sign-out keeps AA when hovered or focused', () {
    // TextButton lays its foreground at 10 % over the ground when focused.
    final focused = Color.alphaBlend(
      AppTheme.quietButton.foregroundColor!
          .resolve(const <WidgetState>{})!
          .withValues(alpha: 0.10),
      AppColors.ground,
    );
    final ink = AppTheme.quietButton.foregroundColor!.resolve(
      const <WidgetState>{},
    )!;
    expect(contrast(ink, focused), greaterThanOrEqualTo(4.5));
  });

  test('the rail matches the bottom bar: white, no pill', () {
    final rail = AppTheme.light(AppDensity.compact).navigationRailTheme;
    expect(rail.backgroundColor, AppColors.surface);
    expect(rail.indicatorColor, Colors.transparent);
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
      atLeast(AppColors.aiDraft, AppColors.aiDraftTint, 4.5, 'aiDraft/tint');
    });

    test('tinted fills keep their text readable', () {
      atLeast(AppColors.primaryHover, AppColors.primaryTint, 4.5, 'on tint');
      // Disabled controls are exempt from WCAG; kept readable anyway.
      atLeast(AppColors.textMuted, AppColors.surfaceSubtle, 4.5, 'disabled');
      atLeast(AppColors.onPrimary, AppColors.error, 4.5, 'destructive');
      atLeast(AppColors.primary, AppColors.surfaceSubtle, 3, 'bar on track');
    });
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
