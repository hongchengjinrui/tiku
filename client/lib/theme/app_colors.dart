import 'package:flutter/material.dart';

/// App color constants extracted from design system.
class AppColors {
  // Primary
  static const primary = Color(0xFF3B82F6);
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF2563EB);
  static const primaryBg = Color(0xFFEFF6FF);

  // Semantic
  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEE2E2);

  // Text
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const textWhite = Color(0xFFFFFFFF);
  static const textBlueHint = Color(0xFFDBEAFE);

  // Background / Surface
  static const surface = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);
  static const navBarBg = Color(0xFFF8FAFC);

  // Misc
  static const overlay = Color(0x66000000);
  static const white40 = Color(0x66FFFFFF);
  static const chapterRowBg = Color(0xFFF8FAFC);
}

/// Gradient definitions used across the app.
class AppGradients {
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primary],
    stops: [0.0, 1.0],
  );

  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
    stops: [0.0, 0.55, 1.0],
  );
}

/// Spacing and sizing constants.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Radius constants.
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double pill = 9999;
}
