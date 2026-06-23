import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/features/devices/data/dummy_btu_meter_readings.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/btu_meter_details_dialog.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/btu_meter_grid.dart';
import 'package:flutter/material.dart';

class DevicesModule extends StatelessWidget {
  const DevicesModule({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.containerPaddingDesktop),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Devices',
            style: AppTextStyles.displayLg.copyWith(fontSize: 40),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Winters BTU meter live snapshot with thermal energy readings.',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BtuMeterGrid(
            readings: dummyBtuMeterReadings,
            onReadingSelected: (reading) {
              showDialog<void>(
                context: context,
                builder: (_) => BtuMeterDetailsDialog(reading: reading),
              );
            },
          ),
        ],
      ),
    );
  }
}
