import '../models/tenant_model.dart';

abstract class TenantsRepo {
  Future<List<TenantModel>> getTenants();

  Future<TenantModel> createTenant({
    required String user,
    required String password,
    String? registerNo,
    String? gatewayIp,
    String? email,
    String? phoneNo,
  });

  Future<void> deleteTenant(int id);
}
