import 'package:flutter/material.dart';

class ThemeColors {
  final String name;
  final Color background;
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color accent;
  // Enhanced for premium UI
  final Color glassBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color gamePoint; // Added missing gamePoint
  final Gradient backgroundGradient;

  const ThemeColors({
    required this.name,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.accent,
    required this.gamePoint, // Required
    this.glassBorder = const Color(0x33FFFFFF),
    this.textPrimary = const Color(0xFFFFFFFF),
    this.textSecondary = const Color(0xB3FFFFFF),
    this.backgroundGradient = const LinearGradient(
      colors: [Color(0xFF1a1a1a), Color(0xFF121212)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  });
}
