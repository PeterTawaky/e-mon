import 'package:e_mon_app/core/services/calculations/peak_tier_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('splits values into off, semi, and on peak tiers', () {
    final result = PeakTierCalculator.splitIntoAutoTiers([
      10,
      25,
      5,
      40,
      55,
      70,
      90,
    ]);

    expect(result.minValue, 5);
    expect(result.maxValue, 90);
    expect(result.offPeakValues, [10, 25, 5]);
    expect(result.semiPeakValues, [40, 55]);
    expect(result.onPeakValues, [70, 90]);
    expect(result.offPeakSum, 40);
    expect(result.semiPeakSum, 95);
    expect(result.onPeakSum, 160);
    expect(result.offPeakCount, 3);
    expect(result.semiPeakCount, 2);
    expect(result.onPeakCount, 2);
  });

  test('classifies a single value using an existing tier result', () {
    final result = PeakTierCalculator.splitIntoAutoTiers([10, 20, 30]);

    expect(
      PeakTierCalculator.classifyValue(value: 10, result: result),
      PeakTier.offPeak,
    );
    expect(
      PeakTierCalculator.classifyValue(value: 20, result: result),
      PeakTier.semiPeak,
    );
    expect(
      PeakTierCalculator.classifyValue(value: 30, result: result),
      PeakTier.onPeak,
    );
  });
}
