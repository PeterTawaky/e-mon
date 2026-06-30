import 'package:e_mon_app/features/home/data/models/reading_model.dart';
import 'package:e_mon_app/features/reports/domain/services/energy_report_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final readings = [
    _reading(id: 1, relativeValue: 10),
    _reading(id: 2, relativeValue: 40),
    _reading(id: 3, relativeValue: 90),
  ];

  test(
    'one tier report creates one total usage row without tier splitting',
    () {
      final report = EnergyReportCalculator.build(
        kind: ReportKind.specific,
        tierMode: ReportTierMode.oneTier,
        readings: readings,
        rates: const EnergyReportRateInput(
          oneTierRate: 2,
          onPeakRate: 0,
          semiPeakRate: 0,
          offPeakRate: 0,
        ),
        selectedStartDate: DateTime(2026, 6),
        selectedEndDate: DateTime(2026, 6, 30),
      );

      expect(report.rows, hasLength(1));
      expect(report.rows.single.timePeriod, 'Total Usage');
      expect(report.rows.single.summationValue, 140);
      expect(report.rows.single.charge, 280);
    },
  );

  test(
    'multi tier report splits relative values and applies each tier rate',
    () {
      final report = EnergyReportCalculator.build(
        kind: ReportKind.specific,
        tierMode: ReportTierMode.multiTier,
        readings: readings,
        rates: const EnergyReportRateInput(
          oneTierRate: 0,
          onPeakRate: 5,
          semiPeakRate: 3,
          offPeakRate: 1,
        ),
        selectedStartDate: DateTime(2026, 6),
        selectedEndDate: DateTime(2026, 6, 30),
      );

      expect(report.rows, hasLength(3));
      expect(report.rows[0].timePeriod, 'On-Peak');
      expect(report.rows[0].summationValue, 90);
      expect(report.rows[0].charge, 450);
      expect(report.rows[1].timePeriod, 'Semi-Peak');
      expect(report.rows[1].summationValue, 40);
      expect(report.rows[1].charge, 120);
      expect(report.rows[2].timePeriod, 'Off-Peak');
      expect(report.rows[2].summationValue, 10);
      expect(report.rows[2].charge, 10);
    },
  );

  test('monthly report can use first day of current month through today', () {
    final report = EnergyReportCalculator.build(
      kind: ReportKind.monthly,
      tierMode: ReportTierMode.oneTier,
      readings: readings,
      rates: const EnergyReportRateInput(
        oneTierRate: 1,
        onPeakRate: 0,
        semiPeakRate: 0,
        offPeakRate: 0,
      ),
      selectedStartDate: DateTime(2026, 6),
      selectedEndDate: DateTime(2026, 6, 22),
      extractedAt: DateTime(2026, 6, 22, 10),
    );

    expect(report.startDate, DateTime(2026, 6));
    expect(report.endDate, DateTime(2026, 6, 22));
    expect(report.rows.single.dateRange, '2026-06-01 - 2026-06-22');
  });
}

ReadingModel _reading({required int id, required double relativeValue}) {
  return ReadingModel(
    id: id,
    tenantId: 1,
    componentName: 'Main Meter',
    accumulativeValue: relativeValue,
    pastAccumulativeValue: 0,
    relativeValue: relativeValue,
    createdAt: DateTime(2026, 6, id, 12),
  );
}
