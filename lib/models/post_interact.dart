class PostInteractModel {
  final int id;
  final int postId;
  final int userId;
  final int reactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostInteractModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.reactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostInteractModel.fromJson(Map<String, dynamic> json) {
    return PostInteractModel(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      reactionId: json['reaction_id'] as int,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

}
