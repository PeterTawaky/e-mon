import 'package:flutter/material.dart';

import '../borders/app_borders.dart';
import '../colors/app_colors.dart';
import '../radius/app_radius.dart';
import '../sizes/app_sizes.dart';
import '../spacing/app_spacing.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.sidebarWidth,
    required this.pagePadding,
    required this.gutter,
    required this.cardRadius,
    required this.controlRadius,
    required this.cardBorder,
    required this.goldBorder,
    required this.tableCellPadding,
  });

  factory AppThemeExtension.institutionalGold() {
    return const AppThemeExtension(
      sidebarWidth: AppSizes.sidebarWidth,
      pagePadding: AppSpacing.containerPaddingDesktop,
      gutter: AppSpacing.gutter,
      cardRadius: AppRadius.lgBorder,
      controlRadius: AppRadius.regularBorder,
      cardBorder: AppBorders.subtle,
      goldBorder: AppBorders.goldTinted,
      tableCellPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.tableCellHorizontal,
        vertical: AppSpacing.tableCellVertical,
      ),
    );
  }

  final double sidebarWidth;
  final double pagePadding;
  final double gutter;
  final BorderRadius cardRadius;
  final BorderRadius controlRadius;
  final BorderSide cardBorder;
  final BorderSide goldBorder;
  final EdgeInsets tableCellPadding;

  @override
  AppThemeExtension copyWith({
    double? sidebarWidth,
    double? pagePadding,
    double? gutter,
    BorderRadius? cardRadius,
    BorderRadius? controlRadius,
    BorderSide? cardBorder,
    BorderSide? goldBorder,
    EdgeInsets? tableCellPadding,
  }) {
    return AppThemeExtension(
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      pagePadding: pagePadding ?? this.pagePadding,
      gutter: gutter ?? this.gutter,
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      cardBorder: cardBorder ?? this.cardBorder,
      goldBorder: goldBorder ?? this.goldBorder,
      tableCellPadding: tableCellPadding ?? this.tableCellPadding,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      sidebarWidth: lerpDouble(sidebarWidth, other.sidebarWidth, t),
      pagePadding: lerpDouble(pagePadding, other.pagePadding, t),
      gutter: lerpDouble(gutter, other.gutter, t),
      cardRadius: BorderRadius.lerp(cardRadius, other.cardRadius, t)!,
      controlRadius: BorderRadius.lerp(controlRadius, other.controlRadius, t)!,
      cardBorder: BorderSide.lerp(cardBorder, other.cardBorder, t),
      goldBorder: BorderSide.lerp(goldBorder, other.goldBorder, t),
      tableCellPadding: EdgeInsets.lerp(
        tableCellPadding,
        other.tableCellPadding,
        t,
      )!,
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;

extension AppThemeExtensionGetter on BuildContext {
  AppThemeExtension get designTokens {
    return Theme.of(this).extension<AppThemeExtension>() ??
        AppThemeExtension.institutionalGold();
  }
}

extension AppColorGetter on BuildContext {
  Color get primaryGold => AppColors.primary;
}
