class PostCommentModel {
  final int id;
  final int postId;
  final int userId;
  final String userFullName;
  final String? userAvatarUrl;
  final String content;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userFullName,
    this.userAvatarUrl,
    required this.content,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      userFullName: json['user_full_name'],
      userAvatarUrl: json['user_avatar_url'],
      content: json['content'],
      isDeleted: json['is_deleted'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

}
