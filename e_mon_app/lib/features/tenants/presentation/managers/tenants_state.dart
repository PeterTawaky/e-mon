part of 'tenants_cubit.dart';

enum TenantsStatus { initial, loading, submitting, success, failure }

class TenantsState {
  const TenantsState({
    required this.status,
    required this.tenants,
    this.message,
  });

  final TenantsStatus status;
  final List<TenantModel> tenants;
  final String? message;

  factory TenantsState.initial() {
    return const TenantsState(status: TenantsStatus.initial, tenants: []);
  }

  TenantsState copyWith({
    TenantsStatus? status,
    List<TenantModel>? tenants,
    String? message,
  }) {
    return TenantsState(
      status: status ?? this.status,
      tenants: tenants ?? this.tenants,
      message: message,
    );
  }
}
