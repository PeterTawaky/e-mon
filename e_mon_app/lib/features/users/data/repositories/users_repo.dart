import '../models/system_user_model.dart';

abstract class UsersRepo {
  Future<List<SystemUserModel>> getUsers();

  Future<SystemUserModel> createUser({
    required String user,
    required String password,
  });

  Future<void> deleteUser(int id);
}
