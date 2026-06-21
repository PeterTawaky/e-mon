import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../spacing/app_spacing.dart';
import '../typography/app_fonts.dart';
import '../typography/app_text_styles.dart';
import 'app_theme_extension.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          inverseSurface: AppColors.inverseSurface,
          onInverseSurface: AppColors.inverseOnSurface,
          inversePrimary: AppColors.inversePrimary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.body,
      fontFamilyFallback: AppFonts.fallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.floor,
      canvasColor: AppColors.floor,
      cardColor: AppColors.card,
      dividerColor: AppColors.border,
      extensions: [AppThemeExtension.institutionalGold()],
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLg,
        headlineMedium: AppTextStyles.headlineMd,
        headlineSmall: AppTextStyles.headlineSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        labelSmall: AppTextStyles.labelCaps,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.floor,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: AppColors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          textStyle: AppTextStyles.labelCaps,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.regularBorder,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.goldBorder),
          textStyle: AppTextStyles.labelCaps,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.regularBorder,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return AppColors.primary;
            }
            return AppColors.onSurfaceVariant;
          }),
          textStyle: WidgetStateProperty.all(AppTextStyles.labelCaps),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(borderRadius: AppRadius.regularBorder),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.floor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.52),
        ),
        labelStyle: AppTextStyles.labelCaps,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.regularBorder,
          borderSide: BorderSide(color: AppColors.goldBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.regularBorder,
          borderSide: BorderSide(color: AppColors.goldBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.regularBorder,
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceContainer),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.overlay;
          }
          return AppColors.card;
        }),
        dividerThickness: 1,
        headingTextStyle: AppTextStyles.labelCaps,
        dataTextStyle: AppTextStyles.dataTabular,
        horizontalMargin: AppSpacing.tableCellHorizontal,
        columnSpacing: AppSpacing.xl,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.overlay,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
          side: const BorderSide(color: AppColors.goldBorder),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: AppColors.overlay,
          borderRadius: AppRadius.regularBorder,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.goldBorder),
          ),
        ),
        textStyle: AppTextStyles.bodyMd,
      ),
    );
  }
}
