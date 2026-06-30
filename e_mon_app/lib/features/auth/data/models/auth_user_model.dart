class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.user,
    required this.role,
  });

  final int id;
  final String user;
  final String role;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as int,
      user: json['user'] as String,
      role: json['role'] as String,
    );
  }
}
