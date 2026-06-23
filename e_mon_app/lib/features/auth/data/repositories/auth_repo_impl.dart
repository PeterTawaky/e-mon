import 'package:e_mon_app/core/services/networking/api_constants.dart';
import 'package:e_mon_app/core/services/networking/api_consumer.dart';

import '../models/auth_user_model.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<AuthUserModel> login({
    required String user,
    required String password,
  }) async {
    final response = await _apiConsumer.post(
      ApiEndpoints.login,
      data: {'user': user.trim(), 'password': password},
    );

    return AuthUserModel.fromJson(response as Map<String, dynamic>);
  }
}
