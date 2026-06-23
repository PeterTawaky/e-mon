import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/features/devices/domain/models/btu_meter_reading.dart';
import 'package:flutter/material.dart';

class BtuMeterCardSummary extends StatelessWidget {
  const BtuMeterCardSummary({super.key, required this.reading});

  final BtuMeterReading reading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${reading.flowRate.toStringAsFixed(1)} L/min',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Delta ${reading.deltaTemperature.toStringAsFixed(1)} C',
              style: AppTextStyles.labelCaps.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          '${reading.energyRate.toStringAsFixed(1)} kW thermal',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
