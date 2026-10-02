import 'package:flutter/material.dart';

/// A color palette for the app.
///
/// Add more static palettes here (e.g. `courtGreen`, `energy`) and switch
/// [AppTheme.current] to support multiple themes.
@immutable
class AppPalette {
  final String name;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color divider;

  const AppPalette({
    required this.name,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.divider,
  });
}

class AppTheme {
  static const AppPalette midnight = AppPalette(
    name: 'Midnight',
    background: Color(0xFF09090B),
    surface: Color(0xFF17171C),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFA1A1AA),
    accent: Color(0xFFA3E635),
    divider: Color(0xFF27272A),
  );

  /// The active palette. Point this to another palette to change theme.
  static const AppPalette current = midnight;

  static ThemeData themeData(AppPalette palette) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.dark(
        surface: palette.surface,
        primary: palette.accent,
        onSurface: palette.textPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
      ),
    );
  }
}
