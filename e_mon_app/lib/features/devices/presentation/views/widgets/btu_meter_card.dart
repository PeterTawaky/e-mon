import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/core/utils/app_durations.dart';
import 'package:e_mon_app/features/devices/domain/models/btu_meter_reading.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/btu_meter_card_summary.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/btu_meter_image.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/meter_type_pill.dart';
import 'package:flutter/material.dart';

class BtuMeterCard extends StatefulWidget {
  const BtuMeterCard({super.key, required this.reading, required this.onTap});

  final BtuMeterReading reading;
  final VoidCallback onTap;

  @override
  State<BtuMeterCard> createState() => _BtuMeterCardState();
}

class _BtuMeterCardState extends State<BtuMeterCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppRadius.lgBorder,
        child: AnimatedContainer(
          duration: AppDurations.t250,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: _CardDecoration(isHovered: _isHovered),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(reading: widget.reading),
              const SizedBox(height: AppSpacing.sm),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: BtuMeterImage(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              BtuMeterCardSummary(reading: widget.reading),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardDecoration extends BoxDecoration {
  _CardDecoration({required bool isHovered})
    : super(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(
          color: isHovered ? AppColors.primary : AppColors.border,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerLow,
            AppColors.card,
            AppColors.surfaceContainerLowest,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isHovered ? 0.14 : 0.06),
            blurRadius: isHovered ? 28 : 18,
            offset: const Offset(0, 14),
          ),
        ],
      );
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.reading});

  final BtuMeterReading reading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reading.name, style: AppTextStyles.headlineSm),
              Text(
                reading.tenantName,
                style: AppTextStyles.labelCaps.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const MeterTypePill(label: 'BTU'),
      ],
    );
  }
}
