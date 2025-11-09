
import 'package:svpro/models/post_attachment.dart';

class PostModel {
  final int id;
  final int userId;
  final String userFullName;
  final String? userAvatarUrl;
  int views;
  final String? content;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isInteract;
  int interactCount;
  int commentCount;
  final List<PostAttachmentModel> attachments;

  PostModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.views,
    this.userAvatarUrl,
    this.content,
    required this.isInteract,
    required this.interactCount,
    required this.commentCount,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.attachments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['user_id'],
      userFullName: json['user_full_name'],
      userAvatarUrl: json['user_avatar_url'],
      content: json['content'],
      views: json['views'],
      isInteract: json['is_interact'],
      interactCount: json['interact_count'],
      commentCount: json['comment_count'],
      isDeleted: json['is_deleted'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((e) => PostAttachmentModel.fromJson(e))
          .toList(),
    );
  }

}
