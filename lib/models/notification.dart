class NotificationModel {
  final int id;
  final String title;
  final String content;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isRead: json['is_read'],
      createdAt: json['created_at'],
    );
  }
}
