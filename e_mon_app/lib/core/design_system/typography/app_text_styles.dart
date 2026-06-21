import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import 'app_fonts.dart';

abstract final class AppTextStyles {
  static const TextStyle displayLg = TextStyle(
    fontFamily: AppFonts.heading,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 56 / 48,
    letterSpacing: -0.96,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: AppFonts.heading,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 32 / 24,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: AppFonts.heading,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 28 / 20,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurface,
  );

  static const TextStyle dataTabular = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 18 / 13,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 16 / 11,
    letterSpacing: 0.55,
    color: AppColors.onSurfaceVariant,
  );
}
