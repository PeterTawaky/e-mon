part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  const LoginState({required this.status, this.user, this.errorMessage});

  final LoginStatus status;
  final AuthUserModel? user;
  final String? errorMessage;

  factory LoginState.initial() {
    return const LoginState(status: LoginStatus.initial);
  }

  LoginState copyWith({
    LoginStatus? status,
    AuthUserModel? user,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
