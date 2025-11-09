class PostAttachmentModel {
  final int id;
  final int postId;
  final int type; // ví dụ: 1 = image, 2 = video, 3 = file
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostAttachmentModel({
    required this.id,
    required this.postId,
    required this.type,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostAttachmentModel.fromJson(Map<String, dynamic> json) {
    return PostAttachmentModel(
      id: json['id'],
      postId: json['post_id'],
      type: json['type'],
      url: json['url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
