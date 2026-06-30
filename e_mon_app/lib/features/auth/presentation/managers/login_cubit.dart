import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/auth_user_model.dart';
import '../../data/repositories/auth_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepo) : super(LoginState.initial());

  final AuthRepo _authRepo;

  Future<void> login({required String user, required String password}) async {
    if (user.trim().isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'User and password are required.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      final authenticatedUser = await _authRepo.login(
        user: user,
        password: password,
      );
      if (authenticatedUser.role != 'admin') {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'Only admin users can access the system.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: LoginStatus.success,
          user: authenticatedUser,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Invalid user or password.',
        ),
      );
    }
  }
}
