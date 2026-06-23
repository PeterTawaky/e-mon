class BtuMeterReading {
  const BtuMeterReading(
    this.name,
    this.flowRate,
    this.supplyTemperature,
    this.returnTemperature,
    this.energyRate,
    this.totalizer,
  );

  final String name;
  final double flowRate;
  final double supplyTemperature;
  final double returnTemperature;
  final double energyRate;
  final double totalizer;

  double get deltaTemperature => returnTemperature - supplyTemperature;
}
