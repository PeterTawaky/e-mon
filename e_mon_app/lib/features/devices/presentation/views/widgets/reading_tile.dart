import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class ReadingTile extends StatelessWidget {
  const ReadingTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.helper,
  });

  final IconData icon;
  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ReadingIcon(icon: icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ReadingText(label: label, helper: helper),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingIcon extends StatelessWidget {
  const _ReadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _ReadingText extends StatelessWidget {
  const _ReadingText({required this.label, required this.helper});

  final String label;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMd),
        const SizedBox(height: AppSpacing.xs),
        Text(
          helper,
          style: AppTextStyles.labelCaps.copyWith(color: AppColors.mutedText),
        ),
      ],
    );
  }
}
