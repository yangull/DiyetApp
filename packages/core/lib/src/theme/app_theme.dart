import 'package:flutter/material.dart';

// TODO: replace with brand color
const _seedColor = Color(0xFF2E7D5B);

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _themeFor(Brightness.light);

  static ThemeData get dark => _themeFor(Brightness.dark);

  static ThemeData _themeFor(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    ),
  );
}
