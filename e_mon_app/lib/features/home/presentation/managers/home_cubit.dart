import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/reading_model.dart';
import '../../data/repositories/home_repo.dart';
import 'chart_range.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepo) : super(HomeState.initial());

  final HomeRepo _homeRepo;
  Timer? _refreshTimer;

  Future<void> startLiveUpdates() async {
    await fetchReadings();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => fetchReadings(silent: true),
    );
  }

  Future<void> loadInitialReadings() {
    return fetchReadings();
  }

  Future<void> fetchReadings({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    }

    try {
      final readings = await _homeRepo.getReadings();
      emit(
        state.copyWith(
          status: HomeStatus.success,
          readings: readings,
          lastUpdated: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  void changeRange(ChartRange range) {
    emit(state.copyWith(selectedRange: range));
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
