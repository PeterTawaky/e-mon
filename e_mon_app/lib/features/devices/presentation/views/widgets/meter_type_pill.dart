import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class MeterTypePill extends StatelessWidget {
  const MeterTypePill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullBorder,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.42)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
