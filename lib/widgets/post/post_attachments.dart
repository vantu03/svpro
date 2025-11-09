import 'package:flutter/material.dart';
import 'package:svpro/models/post_attachment.dart';
// Nếu muốn phát video thật sự thì import package video_player
// import 'package:video_player/video_player.dart';

class PostAttachments extends StatelessWidget {
  final List<PostAttachmentModel> attachments;

  const PostAttachments({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    if (attachments.length == 1) {
      return buildAttachment(attachments[0]);
    } else {
      int count = attachments.length > 4 ? 4 : attachments.length;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          if (index == 3 && attachments.length > 4) {
            return Stack(
              fit: StackFit.expand,
              children: [
                buildAttachment(attachments[index]),
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Text(
                      "+${attachments.length - 4}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          }
          return buildAttachment(attachments[index]);
        },
      );
    }
  }

  Widget buildAttachment(PostAttachmentModel attachment) {
    if (attachment.type == 1) {
      // Ảnh
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(attachment.url, fit: BoxFit.cover),
      );
    } else if (attachment.type == 2) {
      // Video (tạm dùng container với icon play)
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black12,
              image: DecorationImage(
                image: NetworkImage("https://picsum.photos/500/300?blur"), // thumbnail tạm
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
