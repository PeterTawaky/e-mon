part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState {
  const HomeState({
    required this.status,
    required this.readings,
    required this.selectedRange,
    this.lastUpdated,
    this.errorMessage,
  });

  final HomeStatus status;
  final List<ReadingModel> readings;
  final ChartRange selectedRange;
  final DateTime? lastUpdated;
  final String? errorMessage;

  factory HomeState.initial() {
    return const HomeState(
      status: HomeStatus.initial,
      readings: [],
      selectedRange: ChartRange.day,
    );
  }

  List<ReadingModel> get visibleReadings {
    final start = selectedRange.startDate(DateTime.now());
    return readings
        .where((reading) => !reading.createdAt.isBefore(start))
        .toList();
  }

  ReadingModel? get latestReading {
    if (readings.isEmpty) {
      return null;
    }
    return readings.last;
  }

  double get totalRelativeValue {
    return visibleReadings.fold(
      0,
      (sum, reading) => sum + reading.relativeValue,
    );
  }

  HomeState copyWith({
    HomeStatus? status,
    List<ReadingModel>? readings,
    ChartRange? selectedRange,
    DateTime? lastUpdated,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      readings: readings ?? this.readings,
      selectedRange: selectedRange ?? this.selectedRange,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage,
    );
  }
}
