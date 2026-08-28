import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppConfig reports missing configuration without dart-defines', () {
    expect(AppConfig.supabaseUrl, isEmpty);
    expect(AppConfig.isConfigured, isFalse);
  });

  test('AppTheme exposes a light and a dark Material 3 scheme', () {
    expect(AppTheme.light.colorScheme.brightness, Brightness.light);
    expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
    expect(AppTheme.light.useMaterial3, isTrue);
  });
}
