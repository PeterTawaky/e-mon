import 'package:e_mon_app/core/services/networking/api_constants.dart';
import 'package:e_mon_app/core/services/networking/api_consumer.dart';

import '../models/tenant_model.dart';
import 'tenants_repo.dart';

class TenantsRepoImpl implements TenantsRepo {
  TenantsRepoImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<TenantModel>> getTenants() async {
    final response = await _apiConsumer.get(ApiEndpoints.tenants);
    final tenants = response as List<dynamic>;

    return tenants
        .map((tenant) => TenantModel.fromJson(tenant as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TenantModel> createTenant({
    required String user,
    required String password,
    String? registerNo,
    String? gatewayIp,
    String? email,
    String? phoneNo,
  }) async {
    final response = await _apiConsumer.post(
      ApiEndpoints.tenants,
      data: {
        'user': user.trim(),
        'password': password,
        'register_no': _blankToNull(registerNo),
        'gateway_ip': _blankToNull(gatewayIp),
        'email': _blankToNull(email),
        'phone_no': _blankToNull(phoneNo),
      },
    );

    return TenantModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTenant(int id) async {
    await _apiConsumer.delete('${ApiEndpoints.tenants}/$id');
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
