class UserModel {
  final int id;
  final String username;
  final String? fullName;
  String? avatarUrl;
  final String? email;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      email: json['email'],
    );
  }
}
