import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
