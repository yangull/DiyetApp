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

  test('theme uses the measured palette, not a generated seed', () {
    final theme = AppTheme.light(AppDensity.comfortable);
    expect(theme.colorScheme.primary, AppColors.charcoal);
    expect(theme.colorScheme.secondary, AppColors.accent);
    expect(theme.colorScheme.surface, AppColors.canvas);
    expect(theme.scaffoldBackgroundColor, AppColors.canvas);
    expect(theme.cardTheme.color, AppColors.cloudCard);
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

  test('density follows the input: compact only in a computer browser', () {
    for (final p in [
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    ]) {
      expect(AppDensity.forPlatform(isWeb: true, platform: p).isCompact, true);
      expect(
        AppDensity.forPlatform(isWeb: false, platform: p).isCompact,
        false,
      );
    }
    for (final p in [TargetPlatform.iOS, TargetPlatform.android]) {
      expect(AppDensity.forPlatform(isWeb: true, platform: p).isCompact, false);
    }
  });

  test('one bundled family, Alpino, with 600 headings (#135)', () {
    for (final density in [AppDensity.comfortable, AppDensity.compact]) {
      final text = AppTheme.light(density).textTheme;
      for (final style in [
        text.displayLarge,
        text.displayMedium,
        text.displaySmall,
        text.headlineLarge,
        text.headlineMedium,
        text.headlineSmall,
        text.titleLarge,
        text.titleMedium,
        text.titleSmall,
        text.bodyLarge,
        text.bodyMedium,
        text.bodySmall,
        text.labelLarge,
        text.labelMedium,
        text.labelSmall,
      ]) {
        expect(style!.fontFamily, 'packages/core/Alpino');
        // Alpino has no ₺: every style falls back to the one-glyph font.
        expect(style.fontFamilyFallback, ['packages/core/Lira']);
        expect(style.fontWeight!.value, lessThanOrEqualTo(600));
        expect(style.fontSize, greaterThanOrEqualTo(11));
        // Alpino's ink spans 1.14 em; HIG's line heights stay above it.
        expect(style.height, greaterThanOrEqualTo(1.18));
      }
      expect(text.headlineLarge!.fontWeight, FontWeight.w600);
    }
  });

  test('the touch scale is HIG iOS at the default size', () {
    final text = AppTheme.light(AppDensity.comfortable).textTheme;
    expect(text.displaySmall!.fontSize, 34);
    expect(text.headlineLarge!.fontSize, 28);
    expect(text.headlineMedium!.fontSize, 22);
    expect(text.headlineSmall!.fontSize, 20);
    expect(text.titleLarge!.fontSize, 17);
    expect(text.bodyLarge!.fontSize, 17);
    expect(text.bodySmall!.fontSize, 13);
  });

  test('the filled button is a Charcoal pill with a Cloud Card label', () {
    final style = AppTheme.light(AppDensity.comfortable)
        .filledButtonTheme
        .style!;
    const none = <WidgetState>{};
    expect(style.backgroundColor!.resolve(none), AppColors.charcoal);
    expect(style.foregroundColor!.resolve(none), AppColors.cloudCard);
    expect(
      style.backgroundColor!.resolve({WidgetState.pressed}),
      AppColors.charcoalHover,
    );
    expect(style.shape!.resolve(none), isA<StadiumBorder>());
  });

  test('the secondary button is a pale pill, not an outline', () {
    final style = AppTheme.light(AppDensity.comfortable)
        .outlinedButtonTheme
        .style!;
    const none = <WidgetState>{};
    const disabled = {WidgetState.disabled};

    expect(style.side!.resolve(none), BorderSide.none);
    expect(style.backgroundColor!.resolve(none), AppColors.cloudCard);
    expect(style.foregroundColor!.resolve(none), AppColors.ink);
    expect(style.foregroundColor!.resolve(disabled), AppColors.textSecondary);
    expect(style.shape!.resolve(none), isA<StadiumBorder>());
  });

  test('every button is a pill; actions are Ink; destructive is red', () {
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
      theme.textButtonTheme.style!.foregroundColor!.resolve(none),
      AppColors.ink,
    );
    expect(theme.extension<AppPalette>()!.error, AppColors.error);
  });

  test('overlays stay at or under 8 % Ink', () {
    final theme = AppTheme.light(AppDensity.comfortable);
    final overlay = theme.textButtonTheme.style!.overlayColor!;
    expect(overlay.resolve({WidgetState.pressed}), AppTheme.pressOverlay);
    expect(overlay.resolve({WidgetState.focused}), AppTheme.pressOverlay);
    expect(overlay.resolve({WidgetState.hovered}), AppTheme.hoverOverlay);
    expect(AppTheme.pressOverlay.a, closeTo(0.08, 0.005));
    expect(AppTheme.hoverOverlay.a, closeTo(0.04, 0.005));
    expect(theme.highlightColor, Colors.transparent);
  });

  testWidgets('a selected filter chip is Charcoal with readable text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(AppDensity.compact),
        home: Scaffold(
          body: FilterChip(
            label: const Text('Onay bekleyen'),
            selected: true,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    final chip = AppTheme.light(AppDensity.compact).chipTheme;
    final label = tester.widget<RichText>(
      find.descendant(
        of: find.byType(FilterChip),
        matching: find.byType(RichText),
      ),
    );
    final ink = label.text.style!.color!;

    expect(chip.selectedColor, AppColors.charcoal);
    expect(chip.side, BorderSide.none);
    expect(contrast(ink, AppColors.charcoal), greaterThanOrEqualTo(4.5));
  });

  test('the rail matches the bottom bar: white, no pill', () {
    final rail = AppTheme.light(AppDensity.compact).navigationRailTheme;
    expect(rail.backgroundColor, AppColors.canvas);
    expect(rail.indicatorColor, Colors.transparent);
  });

  group('measured palette (docs/design-system.md)', () {
    // The darkest state any text sits on: a Cloud Card under the press.
    final pressedCard = Color.alphaBlend(
      AppTheme.pressOverlay,
      AppColors.cloudCard,
    );
    final pressedCanvas = Color.alphaBlend(
      AppTheme.pressOverlay,
      AppColors.canvas,
    );

    void atLeast(Color fg, Color bg, double min, String what) {
      expect(contrast(fg, bg), greaterThanOrEqualTo(min), reason: what);
    }

    test('text tokens keep 4.5:1 on every surface, pressed too', () {
      for (final bg in [
        AppColors.canvas,
        AppColors.cloudCard,
        pressedCanvas,
        pressedCard,
      ]) {
        atLeast(AppColors.ink, bg, 4.5, 'ink');
        atLeast(AppColors.textSecondary, bg, 4.5, 'textSecondary');
        atLeast(AppColors.error, bg, 4.5, 'error');
        atLeast(AppColors.aiDraft, bg, 4.5, 'aiDraft');
      }
      for (final bg in [AppColors.canvas, AppColors.cloudCard]) {
        atLeast(AppColors.accent, bg, 4.5, 'accent');
        atLeast(AppColors.warning, bg, 4.5, 'warning');
        atLeast(AppColors.borderStrong, bg, 3, 'borderStrong');
      }
      atLeast(AppColors.accent, AppColors.track, 3, 'progress fill on track');
      // Accent as a graphic (a bar, a ring) on a pressed card.
      atLeast(AppColors.accent, pressedCard, 3, 'accent graphic');
    });

    test('status text keeps 4.5:1 on its tint', () {
      atLeast(AppColors.accentStrong, AppColors.accentTint, 4.5, 'Onaylı');
      atLeast(AppColors.warning, AppColors.warningTint, 4.5, 'warning');
      atLeast(AppColors.error, AppColors.errorTint, 4.5, 'error');
      atLeast(AppColors.aiDraft, AppColors.aiDraftTint, 4.5, 'aiDraft');
      for (final tint in [
        AppColors.accentTint,
        AppColors.warningTint,
        AppColors.errorTint,
        AppColors.aiDraftTint,
      ]) {
        atLeast(AppColors.ink, tint, 4.5, 'ink on tint');
      }
    });

    test('labels on filled controls keep 4.5:1', () {
      atLeast(AppColors.cloudCard, AppColors.charcoal, 4.5, 'filled');
      atLeast(AppColors.cloudCard, AppColors.charcoalHover, 4.5, 'pressed');
      atLeast(AppColors.onFilled, AppColors.error, 4.5, 'destructive');
      atLeast(AppColors.onFilled, AppColors.accent, 4.5, 'on accent');
      // Disabled controls are exempt from WCAG; kept readable anyway.
      atLeast(AppColors.textSecondary, AppColors.cloudCard, 4.5, 'disabled');
    });
  });

  testWidgets('inside a CloudCard, pale fills turn white so they show', (
    tester,
  ) async {
    late BuildContext outside;
    late BuildContext inside;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(AppDensity.comfortable),
        home: Scaffold(
          body: Column(
            children: [
              Builder(
                builder: (c) {
                  outside = c;
                  return const SizedBox();
                },
              ),
              CloudCard(
                child: Builder(
                  builder: (c) {
                    inside = c;
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    const none = <WidgetState>{};
    Color? secondary(BuildContext c) =>
        Theme.of(c).outlinedButtonTheme.style!.backgroundColor!.resolve(none);

    expect(outside.palette.inset, AppColors.cloudCard);
    expect(inside.palette.inset, AppColors.canvas);
    expect(secondary(outside), AppColors.cloudCard);
    expect(secondary(inside), AppColors.canvas);
    expect(outside.palette.track, AppColors.track);
    expect(inside.palette.track, AppColors.track);
    expect(
      Theme.of(inside).progressIndicatorTheme.linearTrackColor,
      AppColors.track,
    );
    expect(
      Theme.of(inside).filledButtonTheme.style!.backgroundColor!.resolve(none),
      AppColors.charcoal,
    );
  });

  group('measured dark palette (C43)', () {
    const p = AppPalette.dark;
    final pressedCard = Color.alphaBlend(
      p.ink.withValues(alpha: 0x14 / 255),
      p.cloudCard,
    );

    void atLeast(Color fg, Color bg, double min, String what) {
      expect(contrast(fg, bg), greaterThanOrEqualTo(min), reason: what);
    }

    test('text keeps 4.5:1 on the canvas, a card and a pressed card', () {
      for (final bg in [p.canvas, p.cloudCard, pressedCard]) {
        for (final (fg, what) in [
          (p.ink, 'ink'),
          (p.textSecondary, 'textSecondary'),
          (p.accent, 'accent'),
          (p.warning, 'warning'),
          (p.error, 'error'),
          (p.aiDraft, 'aiDraft'),
        ]) {
          atLeast(fg, bg, 4.5, what);
        }
      }
      atLeast(p.borderStrong, p.canvas, 3, 'border on canvas');
      atLeast(p.borderStrong, p.cloudCard, 3, 'border on card');
      atLeast(p.accent, p.track, 3, 'progress fill on track');
    });

    test('labels on fills and status text on tints keep 4.5:1', () {
      atLeast(p.onCharcoal, p.charcoal, 4.5, 'filled pill');
      atLeast(p.onCharcoal, p.charcoalHover, 4.5, 'pressed pill');
      atLeast(p.onFilled, p.accent, 4.5, 'on accent');
      atLeast(p.onFilled, p.error, 4.5, 'destructive');
      atLeast(p.accentStrong, p.accentTint, 4.5, 'Onaylı');
      atLeast(p.warning, p.warningTint, 4.5, 'warning');
      atLeast(p.error, p.errorTint, 4.5, 'error');
      atLeast(p.aiDraft, p.aiDraftTint, 4.5, 'aiDraft');
    });

    test('the dark theme is dark and carries the dark palette', () {
      final theme = AppTheme.dark(AppDensity.comfortable);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, p.canvas);
      expect(theme.extension<AppPalette>()!.ink, p.ink);
      expect(theme.cardTheme.color, p.cloudCard);
    });
  });

  test('numbers are Alpino 600', () {
    final style = AppTypography.figures(34, 41);
    expect(style.fontFamily, 'packages/core/Alpino');
    expect(style.fontWeight, FontWeight.w600);
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
