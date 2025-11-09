import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/post.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/post/post_attachments.dart';
import 'package:svpro/widgets/post/post_avatar.dart';
import 'package:svpro/widgets/post/post_comment.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  bool markedViewed = false;

  Future<void> markViewed() async {
    if (markedViewed) return;
    markedViewed = true;
    await ApiService.addView(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('post-${widget.post.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          markViewed();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PostAvatar(url: widget.post.userAvatarUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userFullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          timeago.format(widget.post.createdAt, locale: 'vi'),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading:
                                const Icon(Icons.delete, color: Colors.red),
                                title: const Text("Xoá bài viết"),
                                onTap: () async {
                                  AppNavigator.pop();

                                  await AppNavigator.showAlertDialog(
                                    AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                      title: const Text("Xác nhận"),
                                      content: const Text(
                                          "Bạn có chắc chắn muốn xoá bài viết này không?"),
                                      actions: [
                                        TextButton(
                                          onPressed: AppNavigator.pop,
                                          child: const Text("Hủy"),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          onPressed: () async {
                                            AppNavigator.pop();
                                            AppNavigator.showLoadingDialog(
                                                message: "Đang xoá...");

                                            try {
                                              final res =
                                              await ApiService.deletePost(
                                                  widget.post.id);

                                              if (res.statusCode == 422) {
                                                AppCore.handleValidationError(
                                                    res.body);
                                                return;
                                              }

                                              final jsonData =
                                              jsonDecode(res.body);

                                              if (jsonData['detail']
                                              ['status']) {
                                                AppNavigator.pop();
                                                AppNavigator.info(
                                                    "Đã xoá bài viết");
                                              } else {
                                                AppNavigator.error(jsonData[
                                                'detail']['message'] ??
                                                    "Không thể xoá bài viết.");
                                              }
                                            } catch (e) {
                                              debugPrint(
                                                  "error: ${e.toString()}");
                                              AppNavigator.pop();
                                              AppNavigator.error(
                                                  "Lỗi khi xoá bài viết.");
                                            }
                                          },
                                          child: const Text("Xoá"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (widget.post.content != null &&
                  widget.post.content!.isNotEmpty)
                Text(widget.post.content!,
                    style: const TextStyle(fontSize: 15, height: 1.4)),

              const SizedBox(height: 8),

              if (widget.post.attachments.isNotEmpty)
                PostAttachments(attachments: widget.post.attachments),

              Row(
                children: [
                  Icon(Icons.remove_red_eye,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    "${AppCore.formatCompact(widget.post.views)} lượt xem",
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      setState(() {
                        if (widget.post.isInteract) {
                          widget.post.isInteract = false;
                          widget.post.interactCount--;
                        } else {
                          widget.post.isInteract = true;
                          widget.post.interactCount++;
                        }
                      });

                      try {
                        final res =
                        await ApiService.interactPost(widget.post.id);

                        if (res.statusCode == 422) {
                          AppCore.handleValidationError(res.body);
                          return;
                        }
                        jsonDecode(res.body);
                      } catch (e) {
                        debugPrint("error: ${e.toString()}");
                      }
                    },
                    icon: Icon(
                      widget.post.isInteract
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.post.isInteract
                          ? Colors.red
                          : Colors.grey,
                    ),
                    label: Row(
                      children: [
                        const Text("Thích"),
                        if (widget.post.interactCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            AppCore.formatCompact(
                                widget.post.interactCount),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) =>
                            CommentSheet(postId: widget.post.id),
                      );
                    },
                    icon: const Icon(Icons.comment_outlined),
                    label: Row(
                      children: [
                        const Text("Bình luận"),
                        if (widget.post.commentCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            AppCore.formatCompact(
                                widget.post.commentCount),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
