class SenderModel {
  final int id;
  final int userId;
  final String fullName;
  final String phoneNumber;
  final String? defaultAddress;
  final String status;
  final String createdAt;
  final String updatedAt;

  SenderModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.defaultAddress,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });


  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      fullName: json['full_name'].toString(),
      phoneNumber: json['phone_number'],
      defaultAddress: json['default_address'],
      status: json['status'],
      createdAt: json['create_at'],
      updatedAt: json['update_at'],
    );
  }
}
