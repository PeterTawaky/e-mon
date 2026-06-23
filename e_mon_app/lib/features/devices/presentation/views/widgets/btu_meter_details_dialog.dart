import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/features/devices/domain/models/btu_meter_reading.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/btu_meter_image.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/meter_type_pill.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/reading_tile.dart';
import 'package:flutter/material.dart';

class BtuMeterDetailsDialog extends StatelessWidget {
  const BtuMeterDetailsDialog({super.key, required this.reading});

  final BtuMeterReading reading;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorder,
        side: const BorderSide(color: AppColors.goldBorder),
      ),
      title: Row(
        children: [
          Expanded(child: Text('${reading.name} Reading')),
          const MeterTypePill(label: 'BTU'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BtuMeterImage(height: 150),
            const SizedBox(height: AppSpacing.lg),
            ReadingTile(
              icon: Icons.water_drop_outlined,
              label: 'Flow Rate',
              value: '${reading.flowRate.toStringAsFixed(1)} L/min',
              helper: 'Real-time volume passing through the meter',
            ),
            ReadingTile(
              icon: Icons.device_thermostat_rounded,
              label: 'Supply / Return Temperature',
              value:
                  '${reading.supplyTemperature.toStringAsFixed(1)} / ${reading.returnTemperature.toStringAsFixed(1)} C',
              helper:
                  'Delta T ${reading.deltaTemperature.toStringAsFixed(1)} C between inlet and outlet',
            ),
            ReadingTile(
              icon: Icons.local_fire_department_rounded,
              label: 'BTU / Energy Consumption',
              value: '${reading.energyRate.toStringAsFixed(1)} kW',
              helper: 'Real-time thermal energy transfer rate',
            ),
            ReadingTile(
              icon: Icons.av_timer_rounded,
              label: 'Totalizer / Accumulated Energy',
              value: '${reading.totalizer.toStringAsFixed(0)} kWh',
              helper: 'Cumulative energy consumed since last reset',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
