import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

abstract final class AppBorders {
  static const BorderSide subtle = BorderSide(color: AppColors.border);
  static const BorderSide surfaceTinted = BorderSide(color: AppColors.border);
  static const BorderSide primary = BorderSide(color: AppColors.primary);

  static const Border subtleBorder = Border.fromBorderSide(subtle);
  static const Border surfaceTintedBorder = Border.fromBorderSide(
    surfaceTinted,
  );

  static const Border metricTopBorder = Border(
    top: BorderSide(color: AppColors.primaryContainer, width: 2),
    left: subtle,
    right: subtle,
    bottom: subtle,
  );
}
