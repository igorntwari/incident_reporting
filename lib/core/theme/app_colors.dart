import 'package:flutter/material.dart';

/// Single source of truth for every colour used in the app.
/// Widgets must never hard-code a `Color(...)`; reference these instead.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF6C4CF1);
  static const primaryDark = Color(0xFF5235D6);
  static const primaryLight = Color(0xFF9B87F7);
  static const primarySurface = Color(0xFFEFEBFE);

  // Neutrals
  static const background = Color(0xFFF7F7FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE6E6EF);
  static const textPrimary = Color(0xFF14142B);
  static const textSecondary = Color(0xFF6E7191);
  static const textMuted = Color(0xFFA0A3BD);

  // Semantic
  static const warning = Color(0xFFE08A00);
  static const warningSurface = Color(0xFFFFF4E0);
  static const info = Color(0xFF2F6FED);
  static const infoSurface = Color(0xFFE8F0FE);
  static const success = Color(0xFF1F9D63);
  static const successSurface = Color(0xFFE5F6EE);
  static const danger = Color(0xFFE5484D);
  static const dangerSurface = Color(0xFFFDECEC);

  static const heroGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
