import '../models/auth_user_model.dart';

abstract class AuthRepo {
  Future<AuthUserModel> login({required String user, required String password});
}
