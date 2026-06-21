enum ChartRange {
  day('Day'),
  week('Week'),
  month('Month'),
  sixMonths('6 Months'),
  year('Year');

  const ChartRange(this.label);

  final String label;

  DateTime startDate(DateTime now) {
    return switch (this) {
      ChartRange.day => now.subtract(const Duration(days: 1)),
      ChartRange.week => now.subtract(const Duration(days: 7)),
      ChartRange.month => DateTime(now.year, now.month - 1, now.day),
      ChartRange.sixMonths => DateTime(now.year, now.month - 6, now.day),
      ChartRange.year => DateTime(now.year - 1, now.month, now.day),
    };
  }
}
