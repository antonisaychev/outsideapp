import 'package:flutter/material.dart';

/// Цвета и радиусы — по мастер-ТЗ (docs/TZ_Outside_v5_master.md, раздел 0).
class AppColors {
  AppColors._();

  static const coral = Color(0xFFFF385C);
  static const gradientStart = Color(0xFFFD297B);
  static const gradientEnd = Color(0xFFFF655B);

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F7F8);
  static const border = Color(0xFFE5E5E8);

  static const textPrimary = Color(0xFF1A1A1E);
  static const textSecondary = Color(0xFF6B6B72);

  static const error = Color(0xFFE0245E);
  static const success = Color(0xFF2ECC71);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
}

class AppRadius {
  AppRadius._();

  static const small = 14.0;
  static const medium = 20.0;
  static const large = 28.0;
}
