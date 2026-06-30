import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/tenant_model.dart';
import '../../data/repositories/tenants_repo.dart';

part 'tenants_state.dart';

class TenantsCubit extends Cubit<TenantsState> {
  TenantsCubit(this._tenantsRepo) : super(TenantsState.initial());

  final TenantsRepo _tenantsRepo;

  Future<void> loadTenants() async {
    emit(state.copyWith(status: TenantsStatus.loading, message: null));
    try {
      final tenants = await _tenantsRepo.getTenants();
      emit(state.copyWith(status: TenantsStatus.success, tenants: tenants));
    } catch (_) {
      emit(
        state.copyWith(
          status: TenantsStatus.failure,
          message: 'Unable to load tenants.',
        ),
      );
    }
  }

  Future<void> createTenant({
    required String user,
    required String password,
    String? registerNo,
    String? gatewayIp,
    String? email,
    String? phoneNo,
  }) async {
    if (user.trim().isEmpty || password.length < 6) {
      emit(
        state.copyWith(
          status: TenantsStatus.failure,
          message: 'Enter a tenant and a password with at least 6 characters.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: TenantsStatus.submitting, message: null));
    try {
      await _tenantsRepo.createTenant(
        user: user,
        password: password,
        registerNo: registerNo,
        gatewayIp: gatewayIp,
        email: email,
        phoneNo: phoneNo,
      );
      final tenants = await _tenantsRepo.getTenants();
      emit(
        state.copyWith(
          status: TenantsStatus.success,
          tenants: tenants,
          message: 'Tenant created successfully.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TenantsStatus.failure,
          message: 'Could not create tenant. The tenant may already exist.',
        ),
      );
    }
  }

  Future<void> deleteTenant(int id) async {
    emit(state.copyWith(status: TenantsStatus.submitting, message: null));
    try {
      await _tenantsRepo.deleteTenant(id);
      final tenants = await _tenantsRepo.getTenants();
      emit(
        state.copyWith(
          status: TenantsStatus.success,
          tenants: tenants,
          message: 'Tenant deleted successfully.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TenantsStatus.failure,
          message: 'Could not delete tenant.',
        ),
      );
    }
  }
}
