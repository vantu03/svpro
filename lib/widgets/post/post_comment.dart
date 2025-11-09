import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/post_comment.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/widgets/post/post_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentSheet extends StatefulWidget {
  final int postId;
  const CommentSheet({super.key, required this.postId});

  @override
  State<CommentSheet> createState() => CommentSheetState();
}

class CommentSheetState extends State<CommentSheet> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();

  List<PostCommentModel> comments = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int offset = 0;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    loadComments(initial: true);
  }

  Future<void> loadComments({bool initial = false}) async {
    try {
      if (initial) {
        setState(() {
          isLoading = true;
          offset = 0;
          hasMore = true;
          comments = [];
        });
      }

      final res = await ApiService.getComments(widget.postId, offset: offset, limit: limit);
      final jsonData = jsonDecode(res.body);

      if (jsonData['detail']['status']) {
        final items = (jsonData['detail']['data'] as List)
            .map((e) => PostCommentModel.fromJson(e))
            .toList();

        setState(() {
          comments.addAll(items);
          offset += items.length;
          hasMore = items.length == limit;
        });
      }
    } catch (e) {
      debugPrint("error: $e");
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> sendComment() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();

    try {
      final res = await ApiService.createComment(widget.postId, text);
      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      var jsonData = jsonDecode(res.body);

      if (jsonData['detail']['status']) {
        setState(() {
          comments.insert(0, PostCommentModel.fromJson(jsonData['detail']['data']));
        });
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e) {
      debugPrint("error: $e");
      AppNavigator.error('Không thể kết nối tới máy chủ');
    }
  }

  void _showCommentOptions(PostCommentModel cmt, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              if (LocalStorage.userId == cmt.userId)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Xoá bình luận"),
                  onTap: () async {
                    AppNavigator.pop();
                    AppNavigator.showLoadingDialog(message: "Đang xoá bình luận...");
                    try {
                      final res = await ApiService.deleteComment(widget.postId, cmt.id);
                      if (res.statusCode == 422) {
                        AppCore.handleValidationError(res.body);
                        return;
                      }
                      var jsonData = jsonDecode(res.body);
                      if (jsonData['detail']['status']) {
                        setState(() => comments.removeAt(index));
                        AppNavigator.info("Đã xoá");
                      } else {
                        AppNavigator.error(jsonData['detail']['message']);
                      }
                    } catch (e) {
                      debugPrint("error: $e");
                      AppNavigator.error('Không thể kết nối tới máy chủ');
                    } finally {
                      AppNavigator.pop();
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bình luận",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Danh sách bình luận
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                  ? const Center(
                child: Text(
                  "Chưa có bình luận nào",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: comments.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == comments.length) {
                    return TextButton(
                      onPressed: () {
                        if (!isLoadingMore) {
                          setState(() => isLoadingMore = true);
                          loadComments(initial: false);
                        }
                      },
                      child: isLoadingMore
                          ? const CircularProgressIndicator()
                          : const Text("Xem thêm"),
                    );
                  }

                  final cmt = comments[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PostAvatar(url: cmt.userAvatarUrl),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cmt.userFullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          timeago.format(cmt.createdAt, locale: 'vi'),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_horiz, size: 18),
                                    onPressed: () => _showCommentOptions(cmt, index),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          cmt.content,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Ô nhập bình luận
            AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: Row(
                    children: [
                      PostAvatar(url: LocalStorage.userAvatarUrl),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: "Viết bình luận...",
                            filled: true,
                            fillColor: Colors.transparent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: sendComment,
                      ),
                    ],
                  ),
                ),
              ),
            )

          ],
        );
      },
    );
  }
}
