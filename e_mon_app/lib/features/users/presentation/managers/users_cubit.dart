import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/system_user_model.dart';
import '../../data/repositories/users_repo.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._usersRepo) : super(UsersState.initial());

  final UsersRepo _usersRepo;

  Future<void> loadUsers() async {
    emit(state.copyWith(status: UsersStatus.loading, message: null));
    try {
      final users = await _usersRepo.getUsers();
      emit(state.copyWith(status: UsersStatus.success, users: users));
    } catch (_) {
      emit(
        state.copyWith(
          status: UsersStatus.failure,
          message: 'Unable to load users.',
        ),
      );
    }
  }

  Future<void> createUser({
    required String user,
    required String password,
  }) async {
    if (user.trim().isEmpty || password.length < 6) {
      emit(
        state.copyWith(
          status: UsersStatus.failure,
          message: 'Enter a user and a password with at least 6 characters.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: UsersStatus.submitting, message: null));
    try {
      await _usersRepo.createUser(user: user, password: password);
      final users = await _usersRepo.getUsers();
      emit(
        state.copyWith(
          status: UsersStatus.success,
          users: users,
          message: 'User created successfully.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UsersStatus.failure,
          message: 'Could not create user. The user may already exist.',
        ),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    emit(state.copyWith(status: UsersStatus.submitting, message: null));
    try {
      await _usersRepo.deleteUser(id);
      final users = await _usersRepo.getUsers();
      emit(
        state.copyWith(
          status: UsersStatus.success,
          users: users,
          message: 'User deleted successfully.',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UsersStatus.failure,
          message: 'Could not delete user.',
        ),
      );
    }
  }
}
