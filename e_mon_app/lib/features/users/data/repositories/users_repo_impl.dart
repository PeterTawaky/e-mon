import 'package:e_mon_app/core/services/networking/api_constants.dart';
import 'package:e_mon_app/core/services/networking/api_consumer.dart';

import '../models/system_user_model.dart';
import 'users_repo.dart';

class UsersRepoImpl implements UsersRepo {
  UsersRepoImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<SystemUserModel>> getUsers() async {
    final response = await _apiConsumer.get(ApiEndpoints.users);
    final users = response as List<dynamic>;

    return users
        .map((user) => SystemUserModel.fromJson(user as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SystemUserModel> createUser({
    required String user,
    required String password,
  }) async {
    final response = await _apiConsumer.post(
      ApiEndpoints.users,
      data: {'user': user.trim(), 'password': password},
    );

    return SystemUserModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _apiConsumer.delete('${ApiEndpoints.users}/$id');
  }
}
