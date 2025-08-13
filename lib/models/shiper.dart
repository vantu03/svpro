class ShipperModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;

  ShipperModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
  });

  factory ShipperModel.fromJson(Map<String, dynamic> json) {
    return ShipperModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }
}
