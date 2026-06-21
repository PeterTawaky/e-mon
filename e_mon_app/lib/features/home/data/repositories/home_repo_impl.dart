import 'package:e_mon_app/core/services/networking/api_constants.dart';
import 'package:e_mon_app/core/services/networking/api_consumer.dart';
import 'package:e_mon_app/features/home/data/repositories/home_repo.dart';

import '../models/reading_model.dart';

class HomeRepoImpl implements HomeRepo {
  HomeRepoImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<ReadingModel>> getReadings() async {
    final response = await _apiConsumer.get(ApiEndpoints.readings);
    final readings = response as List<dynamic>;

    return readings
        .map(
          (reading) => ReadingModel.fromJson(reading as Map<String, dynamic>),
        )
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
}
