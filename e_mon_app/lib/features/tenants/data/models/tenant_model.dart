class TenantModel {
  const TenantModel({
    required this.id,
    required this.user,
    required this.createdAt,
    this.registerNo,
    this.gatewayIp,
    this.email,
    this.phoneNo,
  });

  final int id;
  final String user;
  final String? registerNo;
  final String? gatewayIp;
  final String? email;
  final String? phoneNo;
  final DateTime createdAt;

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as int,
      user: json['user'] as String,
      registerNo: json['register_no'] as String?,
      gatewayIp: json['gateway_ip'] as String?,
      email: json['email'] as String?,
      phoneNo: json['phone_no'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
