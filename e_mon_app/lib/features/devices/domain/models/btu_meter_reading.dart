import 'package:e_mon_app/features/tenants/data/models/tenant_model.dart';

class BtuMeterReading {
  const BtuMeterReading(
    this.name,
    this.flowRate,
    this.supplyTemperature,
    this.returnTemperature,
    this.energyRate,
    this.totalizer,
    this.tenantId,
    this.tenantName,
  );

  final String name;
  final double flowRate;
  final double supplyTemperature;
  final double returnTemperature;
  final double energyRate;
  final double totalizer;
  final int tenantId;
  final String tenantName;

  double get deltaTemperature => returnTemperature - supplyTemperature;

  factory BtuMeterReading.fromTenant(TenantModel tenant) {
    final seed = tenant.id;
    final flowRate = 28 + (seed % 14) * 2.4;
    final supplyTemperature = 6.4 + (seed % 6) * 0.25;
    final returnTemperature = supplyTemperature + 4.8 + (seed % 5) * 0.35;

    return BtuMeterReading(
      'BTU-${tenant.id.toString().padLeft(2, '0')}',
      flowRate,
      supplyTemperature,
      returnTemperature,
      flowRate * (returnTemperature - supplyTemperature) * 0.86,
      12000 + seed * 940,
      tenant.id,
      tenant.user,
    );
  }
}
