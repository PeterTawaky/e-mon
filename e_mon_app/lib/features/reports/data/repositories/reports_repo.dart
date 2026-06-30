import 'package:e_mon_app/features/home/data/models/reading_model.dart';

abstract class ReportsRepo {
  Future<List<ReadingModel>> getRangeReadings({
    required DateTime startDate,
    required int tenantId,
    DateTime? endDate,
  });

  Future<List<ReadingModel>> getMonthlyReadings({required int tenantId});
}
