import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

abstract final class AppBorders {
  static const BorderSide subtle = BorderSide(color: AppColors.border);
  static const BorderSide goldTinted = BorderSide(color: AppColors.goldBorder);
  static const BorderSide primary = BorderSide(color: AppColors.primary);

  static const Border subtleBorder = Border.fromBorderSide(subtle);
  static const Border goldTintedBorder = Border.fromBorderSide(goldTinted);

  static const Border metricTopBorder = Border(
    top: BorderSide(color: AppColors.primaryContainer, width: 2),
    left: subtle,
    right: subtle,
    bottom: subtle,
  );
}
