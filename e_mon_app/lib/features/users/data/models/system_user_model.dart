class SystemUserModel {
  const SystemUserModel({
    required this.id,
    required this.user,
    required this.password,
    required this.createdAt,
  });

  final int id;
  final String user;
  final String password;
  final DateTime createdAt;

  factory SystemUserModel.fromJson(Map<String, dynamic> json) {
    return SystemUserModel(
      id: json['id'] as int,
      user: json['user'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
