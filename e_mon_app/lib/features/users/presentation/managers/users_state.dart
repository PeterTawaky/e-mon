part of 'users_cubit.dart';

enum UsersStatus { initial, loading, submitting, success, failure }

class UsersState {
  const UsersState({required this.status, required this.users, this.message});

  final UsersStatus status;
  final List<SystemUserModel> users;
  final String? message;

  factory UsersState.initial() {
    return const UsersState(status: UsersStatus.initial, users: []);
  }

  UsersState copyWith({
    UsersStatus? status,
    List<SystemUserModel>? users,
    String? message,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      message: message,
    );
  }
}
