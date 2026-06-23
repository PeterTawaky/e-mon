enum PeakTier {
  offPeak('Off-Peak'),
  semiPeak('Semi-Peak'),
  onPeak('On-Peak');

  const PeakTier(this.label);

  final String label;
}

class PeakTierResult {
  const PeakTierResult({
    required this.minValue,
    required this.maxValue,
    required this.offPeakLimit,
    required this.onPeakLimit,
    required this.offPeakValues,
    required this.semiPeakValues,
    required this.onPeakValues,
    required this.offPeakSum,
    required this.semiPeakSum,
    required this.onPeakSum,
    required this.offPeakCount,
    required this.semiPeakCount,
    required this.onPeakCount,
  });

  final num minValue;
  final num maxValue;
  final num offPeakLimit;
  final num onPeakLimit;

  final List<num> offPeakValues;
  final List<num> semiPeakValues;
  final List<num> onPeakValues;

  final num offPeakSum;
  final num semiPeakSum;
  final num onPeakSum;

  final int offPeakCount;
  final int semiPeakCount;
  final int onPeakCount;

  Map<PeakTier, List<num>> get valuesByTier {
    return {
      PeakTier.offPeak: offPeakValues,
      PeakTier.semiPeak: semiPeakValues,
      PeakTier.onPeak: onPeakValues,
    };
  }

  Map<PeakTier, num> get sumsByTier {
    return {
      PeakTier.offPeak: offPeakSum,
      PeakTier.semiPeak: semiPeakSum,
      PeakTier.onPeak: onPeakSum,
    };
  }

  Map<PeakTier, int> get countsByTier {
    return {
      PeakTier.offPeak: offPeakCount,
      PeakTier.semiPeak: semiPeakCount,
      PeakTier.onPeak: onPeakCount,
    };
  }
}

abstract final class PeakTierCalculator {
  static PeakTierResult splitIntoAutoTiers(List<num> values) {
    if (values.isEmpty) {
      throw ArgumentError('Values list cannot be empty');
    }

    final normalizedValues = List<num>.from(values);
    final minValue = normalizedValues.reduce((a, b) => a < b ? a : b);
    final maxValue = normalizedValues.reduce((a, b) => a > b ? a : b);

    final range = maxValue - minValue;
    final offPeakLimit = minValue + range / 3;
    final onPeakLimit = minValue + range * 2 / 3;

    final offPeakValues = <num>[];
    final semiPeakValues = <num>[];
    final onPeakValues = <num>[];

    for (final value in normalizedValues) {
      if (value < offPeakLimit) {
        offPeakValues.add(value);
      } else if (value < onPeakLimit) {
        semiPeakValues.add(value);
      } else {
        onPeakValues.add(value);
      }
    }

    return PeakTierResult(
      minValue: minValue,
      maxValue: maxValue,
      offPeakLimit: offPeakLimit,
      onPeakLimit: onPeakLimit,
      offPeakValues: offPeakValues,
      semiPeakValues: semiPeakValues,
      onPeakValues: onPeakValues,
      offPeakSum: _sumList(offPeakValues),
      semiPeakSum: _sumList(semiPeakValues),
      onPeakSum: _sumList(onPeakValues),
      offPeakCount: offPeakValues.length,
      semiPeakCount: semiPeakValues.length,
      onPeakCount: onPeakValues.length,
    );
  }

  static PeakTier classifyValue({
    required num value,
    required PeakTierResult result,
  }) {
    if (value < result.offPeakLimit) {
      return PeakTier.offPeak;
    }
    if (value < result.onPeakLimit) {
      return PeakTier.semiPeak;
    }
    return PeakTier.onPeak;
  }

  static num _sumList(List<num> values) {
    if (values.isEmpty) {
      return 0;
    }

    return values.fold<num>(0, (sum, value) => sum + value);
  }
}
