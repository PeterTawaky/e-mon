import 'package:e_mon_app/core/services/calculations/peak_tier_calculator.dart';
import 'package:e_mon_app/features/home/data/models/reading_model.dart';

enum ReportKind {
  specific('Specific Report'),
  monthly('Monthly Report');

  const ReportKind(this.label);

  final String label;
}

enum ReportTierMode {
  oneTier('One tier'),
  multiTier('Multi-tier');

  const ReportTierMode(this.label);

  final String label;
}

class EnergyReportRateInput {
  const EnergyReportRateInput({
    required this.oneTierRate,
    required this.onPeakRate,
    required this.semiPeakRate,
    required this.offPeakRate,
  });

  final double oneTierRate;
  final double onPeakRate;
  final double semiPeakRate;
  final double offPeakRate;
}

class EnergyReport {
  const EnergyReport({
    required this.kind,
    required this.tierMode,
    required this.startDate,
    required this.endDate,
    required this.extractedAt,
    required this.readingsCount,
    required this.rows,
  });

  final ReportKind kind;
  final ReportTierMode tierMode;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime extractedAt;
  final int readingsCount;
  final List<EnergyReportRow> rows;

  double get totalUsage {
    return rows.fold(0, (sum, row) => sum + row.summationValue);
  }

  double get totalCharge {
    return rows.fold(0, (sum, row) => sum + row.charge);
  }
}

class EnergyReportRow {
  const EnergyReportRow({
    required this.timePeriod,
    required this.dateRange,
    required this.summationValue,
    required this.rate,
  });

  final String timePeriod;
  final String dateRange;
  final double summationValue;
  final double rate;

  double get charge => summationValue * rate;
}

abstract final class EnergyReportCalculator {
  static EnergyReport build({
    required ReportKind kind,
    required ReportTierMode tierMode,
    required List<ReadingModel> readings,
    required EnergyReportRateInput rates,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    DateTime? extractedAt,
  }) {
    final reportExtractedAt = extractedAt ?? DateTime.now();
    final startDate = selectedStartDate ?? _firstReadingDate(readings);
    final endDate = selectedEndDate ?? _lastReadingDate(readings);
    final dateRange = _formatDateRange(startDate, endDate);

    return EnergyReport(
      kind: kind,
      tierMode: tierMode,
      startDate: startDate,
      endDate: endDate,
      extractedAt: reportExtractedAt,
      readingsCount: readings.length,
      rows: tierMode == ReportTierMode.oneTier
          ? _buildOneTierRows(readings, rates.oneTierRate, dateRange)
          : _buildMultiTierRows(readings, rates, dateRange),
    );
  }

  static List<EnergyReportRow> _buildOneTierRows(
    List<ReadingModel> readings,
    double rate,
    String dateRange,
  ) {
    final total = readings.fold<double>(
      0,
      (sum, reading) => sum + reading.relativeValue,
    );

    return [
      EnergyReportRow(
        timePeriod: 'Total Usage',
        dateRange: dateRange,
        summationValue: total,
        rate: rate,
      ),
    ];
  }

  static List<EnergyReportRow> _buildMultiTierRows(
    List<ReadingModel> readings,
    EnergyReportRateInput rates,
    String dateRange,
  ) {
    final result = PeakTierCalculator.splitIntoAutoTiers(
      readings.map((reading) => reading.relativeValue).toList(),
    );

    return [
      EnergyReportRow(
        timePeriod: PeakTier.onPeak.label,
        dateRange: dateRange,
        summationValue: result.onPeakSum.toDouble(),
        rate: rates.onPeakRate,
      ),
      EnergyReportRow(
        timePeriod: PeakTier.semiPeak.label,
        dateRange: dateRange,
        summationValue: result.semiPeakSum.toDouble(),
        rate: rates.semiPeakRate,
      ),
      EnergyReportRow(
        timePeriod: PeakTier.offPeak.label,
        dateRange: dateRange,
        summationValue: result.offPeakSum.toDouble(),
        rate: rates.offPeakRate,
      ),
    ];
  }

  static DateTime? _firstReadingDate(List<ReadingModel> readings) {
    if (readings.isEmpty) {
      return null;
    }
    return readings.first.createdAt;
  }

  static DateTime? _lastReadingDate(List<ReadingModel> readings) {
    if (readings.isEmpty) {
      return null;
    }
    return readings.last.createdAt;
  }

  static String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      return 'No readings found';
    }
    if (start == null) {
      return 'Until ${_formatDate(end!)}';
    }
    if (end == null) {
      return 'From ${_formatDate(start)}';
    }
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  static String _formatDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
