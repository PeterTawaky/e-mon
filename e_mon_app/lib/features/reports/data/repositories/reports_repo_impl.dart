import 'package:e_mon_app/core/services/networking/api_constants.dart';
import 'package:e_mon_app/core/services/networking/api_consumer.dart';
import 'package:e_mon_app/features/home/data/models/reading_model.dart';
import 'package:e_mon_app/features/reports/data/repositories/reports_repo.dart';

class ReportsRepoImpl implements ReportsRepo {
  ReportsRepoImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<ReadingModel>> getRangeReadings({
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final response = await _apiConsumer.get(
      ApiEndpoints.readingsRange,
      queryParameters: {
        'start_date': _formatApiDate(startDate),
        if (endDate != null) 'end_date': _formatApiDate(endDate),
      },
    );

    return _parseReadings(response);
  }

  @override
  Future<List<ReadingModel>> getMonthlyReadings() async {
    final response = await _apiConsumer.get(ApiEndpoints.readingsMonthly);

    return _parseReadings(response);
  }

  List<ReadingModel> _parseReadings(Object? response) {
    final readings = response as List<dynamic>;

    return readings
        .map(
          (reading) => ReadingModel.fromJson(reading as Map<String, dynamic>),
        )
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  String _formatApiDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
