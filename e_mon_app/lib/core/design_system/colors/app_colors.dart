import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF14B8A6);
  static const Color primaryLight = Color(0xFF5EEAD4);
  static const Color primaryDark = Color(0xFF0D9488);

  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceDim = Color(0xFF0F172A);
  static const Color surfaceBright = Color(0xFF334155);
  static const Color surfaceContainerLowest = Color(0xFF0F172A);
  static const Color surfaceContainerLow = Color(0xFF1E293B);
  static const Color surfaceContainer = Color(0xFF26354A);
  static const Color surfaceContainerHigh = Color(0xFF334155);
  static const Color surfaceContainerHighest = Color(0xFF475569);
  static const Color onSurface = Color(0xFFF8FAFC);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);
  static const Color inverseSurface = Color(0xFFF8FAFC);
  static const Color inverseOnSurface = Color(0xFF0F172A);
  static const Color outline = Color(0xFF64748B);
  static const Color outlineVariant = Color(0xFF334155);
  static const Color surfaceTint = primary;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0D9488);
  static const Color onPrimaryContainer = Color(0xFFF0FDFA);
  static const Color inversePrimary = Color(0xFF0F766E);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF1D4ED8);
  static const Color onSecondaryContainer = Color(0xFFEFF6FF);
  static const Color tertiary = Color(0xFF8B5CF6);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF6D28D9);
  static const Color onTertiaryContainer = Color(0xFFF5F3FF);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFB91C1C);
  static const Color onErrorContainer = Color(0xFFFFF1F2);
  static const Color background = Color(0xFF0F172A);
  static const Color onBackground = Color(0xFFF8FAFC);
  static const Color surfaceVariant = Color(0xFF334155);

  static const Color floor = Color(0xFF0F172A);
  static const Color card = Color(0xFF1E293B);
  static const Color cardHover = Color(0xFF334155);
  static const Color overlay = Color(0xFF334155);
  static const Color border = Color(0xFF334155);
  static const Color divider = Color(0xFF1E293B);
  static const Color mutedText = Color(0xFF64748B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFF16A34A);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color iconPrimary = Color(0xFFF8FAFC);
  static const Color iconSecondary = Color(0xFF94A3B8);
  static const Color shadow = Color(0x40000000);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  static const List<Color> chartColors = [
    Color(0xFF14B8A6),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFF22C55E),
    Color(0xFFEC4899),
    Color(0xFFFBBF24),
    Color(0xFF06B6D4),
  ];

  static Color getChartColor(int index) {
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
