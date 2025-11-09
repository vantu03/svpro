class PostViewModel {
  final int id;
  final int postId;
  final int userId;
  final String createdAt;

  PostViewModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory PostViewModel.fromJson(Map<String, dynamic> json) {
    return PostViewModel(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      createdAt: json['created_at'] ?? '',
    );
  }

}
