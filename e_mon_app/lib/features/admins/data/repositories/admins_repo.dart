import '../models/admin_model.dart';

abstract class AdminsRepo {
  Future<List<AdminModel>> getAdmins();

  Future<AdminModel> createAdmin({
    required String user,
    required String password,
  });

  Future<void> deleteAdmin(int id);
}
