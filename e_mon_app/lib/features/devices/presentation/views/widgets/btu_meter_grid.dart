import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/features/devices/domain/models/btu_meter_reading.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/btu_meter_card.dart';
import 'package:flutter/material.dart';

class BtuMeterGrid extends StatelessWidget {
  const BtuMeterGrid({
    super.key,
    required this.readings,
    required this.onReadingSelected,
  });

  final List<BtuMeterReading> readings;
  final ValueChanged<BtuMeterReading> onReadingSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: readings.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isCompact ? 2 : 4,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: isCompact ? 0.88 : 1.04,
          ),
          itemBuilder: (context, index) {
            final reading = readings[index];

            return BtuMeterCard(
              reading: reading,
              onTap: () => onReadingSelected(reading),
            );
          },
        );
      },
    );
  }
}
