part of 'admins_cubit.dart';

enum AdminsStatus { initial, loading, submitting, success, failure }

class AdminsState {
  const AdminsState({required this.status, required this.admins, this.message});

  final AdminsStatus status;
  final List<AdminModel> admins;
  final String? message;

  factory AdminsState.initial() {
    return const AdminsState(status: AdminsStatus.initial, admins: []);
  }

  AdminsState copyWith({
    AdminsStatus? status,
    List<AdminModel>? admins,
    String? message,
  }) {
    return AdminsState(
      status: status ?? this.status,
      admins: admins ?? this.admins,
      message: message,
    );
  }
}
