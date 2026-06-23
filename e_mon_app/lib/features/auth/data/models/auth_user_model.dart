class AuthUserModel {
  const AuthUserModel({required this.id, required this.user});

  final int id;
  final String user;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(id: json['id'] as int, user: json['user'] as String);
  }
}
