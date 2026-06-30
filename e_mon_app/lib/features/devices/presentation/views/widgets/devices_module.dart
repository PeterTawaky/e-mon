import 'package:e_mon_app/core/design_system/design_system.dart';
import 'package:e_mon_app/core/services/networking/dio_consumer.dart';
import 'package:e_mon_app/features/devices/domain/models/btu_meter_reading.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/btu_meter_details_dialog.dart';
import 'package:e_mon_app/features/devices/presentation/views/widgets/btu_meter_grid.dart';
import 'package:e_mon_app/features/tenants/data/models/tenant_model.dart';
import 'package:e_mon_app/features/tenants/data/repositories/tenants_repo_impl.dart';
import 'package:flutter/material.dart';

class DevicesModule extends StatefulWidget {
  const DevicesModule({super.key});

  @override
  State<DevicesModule> createState() => _DevicesModuleState();
}

class _DevicesModuleState extends State<DevicesModule> {
  late final Future<List<TenantModel>> _tenantsFuture;

  @override
  void initState() {
    super.initState();
    _tenantsFuture = TenantsRepoImpl(DioConsumer()).getTenants();
  }

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
            'One Winters BTU meter is created for each tenant.',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FutureBuilder<List<TenantModel>>(
            future: _tenantsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _DevicesMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to load tenants',
                  message: 'Devices are created from the tenants list.',
                );
              }

              final tenants = snapshot.data ?? const <TenantModel>[];
              if (tenants.isEmpty) {
                return _DevicesMessage(
                  icon: Icons.group_rounded,
                  title: 'No tenant devices yet',
                  message: 'Create tenants to generate one BTU meter each.',
                );
              }

              final readings = tenants.map(BtuMeterReading.fromTenant).toList();

              return BtuMeterGrid(
                readings: readings,
                onReadingSelected: (reading) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => BtuMeterDetailsDialog(reading: reading),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DevicesMessage extends StatelessWidget {
  const _DevicesMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 36),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
