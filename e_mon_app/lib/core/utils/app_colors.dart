import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── الألوان الأساسية ───
  static const Color dodgerBlue = Color(0xFF1E90FF);
  static const Color blueberry = Color(0xFF4B0082);
  static const Color ripePlum = Color(0xFF6A0D6A);

  // Primary palette (deep navy — from design)
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF2D52B8);
  static const Color primaryDark = Color(0xFF152A6E);
  static const Color primaryMuted = Color(0xFFEFF3FB);

  // ─── الأبيض والأسود والرمادي ───
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // رمادي فاتح (للـ Light Mode)
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  // رمادي غامق (للـ Dark Mode)
  static const Color dark50 = Color(0xFF2A2A3D);
  static const Color dark100 = Color(0xFF232338);
  static const Color dark200 = Color(0xFF1E1E32);
  static const Color dark300 = Color(0xFF18182B);
  static const Color dark400 = Color(0xFF131324);
  static const Color dark500 = Color(0xFF0F0F1E);
  static const Color dark600 = Color(0xFF0B0B18);
  static const Color dark700 = Color(0xFF070712);

  // ─── ألوان الحالة (Status Colors) ───
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF166534);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);

  // ─── Light Mode ───
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextHint = Color(0xFF94A3B8);
  static const Color lightIcon = Color(0xFF64748B);
  static const Color lightInputFill = Color(0xFFF1F5F9);
  static const Color lightInputBorder = Color(0xFFCBD5E1);
  static const Color lightSidebar = Color(0xFFFFFFFF);
  static const Color lightAppBar = Color(0xFFFFFFFF);
  static const Color lightShadow = Color(0x0F000000);

  // ─── Dark Mode ───
  static const Color darkBackground = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF16162A);
  static const Color darkSurfaceVariant = Color(0xFF1C1C30);
  static const Color darkCard = Color(0xFF1C1C30);
  static const Color darkDivider = Color(0xFF2E2E4A);
  static const Color darkTextPrimary = Color(0xFFF0F0FF);
  static const Color darkTextSecondary = Color(0xFFB8B8D4);
  static const Color darkTextHint = Color(0xFF8888A8);
  static const Color darkIcon = Color(0xFFCCCCE8);
  static const Color darkInputFill = Color(0xFF1A1A2E);
  static const Color darkInputBorder = Color(0xFF3A3A58);
  static const Color darkSidebar = Color(0xFF111120);
  static const Color darkAppBar = Color(0xFF16162A);
  static const Color darkShadow = Color(0x60000000);

  // ─── التدرجات اللونية ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF152A6E)],
  );

  static const LinearGradient fullGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2D52B8), Color(0xFF152A6E)],
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E3A8A), Color(0xFF0F2060)],
  );

  // ─── ألوان الرسوم البيانية (Charts) ───
  static const List<Color> chartColors = [
    Color(0xFF1E3A8A), // Primary Navy
    Color(0xFF2D52B8), // Primary Light
    Color(0xFF6A0D6A), // Ripe Plum
    Color(0xFF22C55E), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFFA855F7), // Purple
  ];

  static const List<Color> randomColors = [
    Color(0xFF1E90FF),
    Color(0xFF4B0082),
    Color(0xFF6A0D6A),
  ];

  // ─── الدوال المساعدة ───
  static Color getRandomColor(int index) {
    return chartColors[index % chartColors.length];
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static LinearGradient createGradient({
    required Color startColor,
    required Color endColor,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [startColor, endColor],
    );
  }
}
