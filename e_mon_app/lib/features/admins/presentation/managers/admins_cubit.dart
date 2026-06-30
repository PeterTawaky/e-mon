import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/admin_model.dart';
import '../../data/repositories/admins_repo.dart';

part 'admins_state.dart';

class AdminsCubit extends Cubit<AdminsState> {
  AdminsCubit(this._adminsRepo) : super(AdminsState.initial());

  final AdminsRepo _adminsRepo;

  Future<void> loadAdmins() async {
    emit(state.copyWith(status: AdminsStatus.loading, message: null));
    try {
      final admins = await _adminsRepo.getAdmins();
      emit(state.copyWith(status: AdminsStatus.success, admins: admins));
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminsStatus.failure,
          message: 'Unable to load admins.',
        ),
      );
    }
  }

  Future<void> createAdmin({
    required String user,
    required String password,
  }) async {
    if (user.trim().isEmpty || password.length < 6) {
      emit(
        state.copyWith(
          status: AdminsStatus.failure,
          message: 'Enter an admin and a password with at least 6 characters.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AdminsStatus.submitting, message: null));
    try {
      await _adminsRepo.createAdmin(user: user, password: password);
      final admins = await _adminsRepo.getAdmins();
      emit(
        state.copyWith(
          status: AdminsStatus.success,
          admins: admins,
          message: 'Admin created successfully.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminsStatus.failure,
          message: 'Could not create admin. The admin may already exist.',
        ),
      );
    }
  }

  Future<void> deleteAdmin(int id) async {
    emit(state.copyWith(status: AdminsStatus.submitting, message: null));
    try {
      await _adminsRepo.deleteAdmin(id);
      final admins = await _adminsRepo.getAdmins();
      emit(
        state.copyWith(
          status: AdminsStatus.success,
          admins: admins,
          message: 'Admin deleted successfully.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AdminsStatus.failure,
          message: 'Could not delete admin.',
        ),
      );
    }
  }
}
