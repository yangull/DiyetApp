import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // google_fonts touches ServicesBinding when a TextStyle is built, and plain
  // test() cases have no binding of their own.
  TestWidgetsFlutterBinding.ensureInitialized();
  // Tests have no network; without this google_fonts logs a failed fetch for
  // every style it builds. Metrics still resolve, so theme assertions hold.
  GoogleFonts.config.allowRuntimeFetching = false;

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
}
