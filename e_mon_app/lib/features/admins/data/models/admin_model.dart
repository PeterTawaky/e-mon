class AdminModel {
  const AdminModel({
    required this.id,
    required this.user,
    required this.createdAt,
  });

  final int id;
  final String user;
  final DateTime createdAt;

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as int,
      user: json['user'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
