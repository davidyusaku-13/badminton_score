import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  static const Map<String, ThemeColors> themes = {
    'light': ThemeColors(
        name: 'Light',
        background: Color(0xFFFAFAFA),
        primary: Color(0xFFFF8A50),
        secondary: Color(0xFFFFB74D),
        surface: Color(0xFFE0E0E0),
        onSurface: Color(0xFF212121),
        accent: Color(0xFFFF6D00),
        gamePoint: Color(0xFFFFD700),
        textPrimary: Color(0xFF212121),
        textSecondary: Color(0xFF757575),
        glassBorder: Color(0x1F000000),
        backgroundGradient: LinearGradient(
          colors: [Color(0xFFFAFAFA), Color(0xFFEEEEEE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )),
    'minimal': ThemeColors(
      name: 'Minimal',
      background: Color(0xFFFFFFFF),
      primary: Color(0xFF757575),
      secondary: Color(0xFF9E9E9E),
      surface: Color(0xFFF5F5F5),
      onSurface: Color(0xFF212121),
      accent: Color(0xFF616161),
      gamePoint: Color(0xFFFFC107),
      textPrimary: Color(0xFF212121),
      textSecondary: Color(0xFF757575),
      glassBorder: Color(0x1F000000),
      backgroundGradient: LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
    ),
    'energy': ThemeColors(
      name: 'Energy',
      background: Color(0xFFFFF8E1),
      primary: Color(0xFFFF5722),
      secondary: Color(0xFFFF9800),
      surface: Color(0xFFFFECB3),
      onSurface: Color(0xFF212121),
      accent: Color(0xFFE64A19),
      gamePoint: Color(0xFFFFD600),
       textPrimary: Color(0xFF212121),
      textSecondary: Color(0xFF5D4037),
       glassBorder: Color(0x1F000000),
       backgroundGradient: LinearGradient(
          colors: [Color(0xFFFFECB3), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
    ),
    'court': ThemeColors(
      name: 'Court',
      background: Color(0xFFE8F5E9),
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFF8BC34A),
      surface: Color(0xFFC8E6C9),
      onSurface: Color(0xFF1B5E20),
      accent: Color(0xFF388E3C),
      gamePoint: Color(0xFFFFEB3B),
      textPrimary: Color(0xFF1B5E20),
      textSecondary: Color(0xFF33691E),
      glassBorder: Color(0x1F000000),
      backgroundGradient: LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
    ),
    'champion': ThemeColors(
      name: 'Champion',
      background: Color(0xFFFCE4EC),
      primary: Color(0xFFE91E63),
      secondary: Color(0xFFFF5722),
      surface: Color(0xFFF8BBD9),
      onSurface: Color(0xFF880E4F),
      accent: Color(0xFFC2185B),
      gamePoint: Color(0xFFFFD700),
      textPrimary: Color(0xFF880E4F),
      textSecondary: Color(0xFFAD1457),
      glassBorder: Color(0x1F000000),
      backgroundGradient: LinearGradient(
          colors: [Color(0xFFF8BBD9), Color(0xFFF48FB1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
    ),
    'midnight': ThemeColors(
      name: 'Midnight',
      background: Color(0xFF121212),
      primary: Color(0xFFBB86FC),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFFFFFFF),
      accent: Color(0xFFCF6679),
      gamePoint: Color(0xFFFFD700),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xB3FFFFFF),
      glassBorder: Color(0x33FFFFFF),
      backgroundGradient: LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF2C2C2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
    ),
  };

  static final List<String> themeKeys = themes.keys.toList();
}
