import 'package:flutter/material.dart';

const deepGreen = Color(0xFF0F3D2E);
const gold = Color(0xFFD4AF37);
const cream = Color(0xFFFBF8F2);
const charcoal = Color(0xFF1F2937);
const muted = Color(0xFF6B7280);

/// Shared spacing so screens do not hard-code one-off gaps.
abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double icon = 24;
  static const double tap = 48;
  static const double cardRadius = 16;
  static const double heroRadius = 20;
  static const double navClearance = 120;
}

ThemeData linksBridgeTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: deepGreen,
      primary: deepGreen,
      surface: cream,
    ),
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: cream,
      foregroundColor: charcoal,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: deepGreen,
        foregroundColor: cream,
      ),
    ),
  );
}
