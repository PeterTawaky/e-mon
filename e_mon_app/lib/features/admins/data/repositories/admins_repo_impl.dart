import 'package:e_mon_app/core/services/networking/api_constants.dart';
import 'package:e_mon_app/core/services/networking/api_consumer.dart';

import '../models/admin_model.dart';
import 'admins_repo.dart';

class AdminsRepoImpl implements AdminsRepo {
  AdminsRepoImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<AdminModel>> getAdmins() async {
    final response = await _apiConsumer.get(ApiEndpoints.admins);
    final admins = response as List<dynamic>;

    return admins
        .map((admin) => AdminModel.fromJson(admin as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AdminModel> createAdmin({
    required String user,
    required String password,
  }) async {
    final response = await _apiConsumer.post(
      ApiEndpoints.admins,
      data: {'user': user.trim(), 'password': password},
    );

    return AdminModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAdmin(int id) async {
    await _apiConsumer.delete('${ApiEndpoints.admins}/$id');
  }
}
