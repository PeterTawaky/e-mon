import 'package:e_mon_app/features/home/data/models/reading_model.dart';

abstract class HomeRepo {
  Future<List<ReadingModel>> getReadings();
}
