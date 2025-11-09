class ShipperModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String createdAt;
  final String updatedAt;
  final bool isActive;

  ShipperModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory ShipperModel.fromJson(Map<String, dynamic> json) {
    return ShipperModel(
      id: json['id'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isActive: json['is_active'],
    );
  }
}
