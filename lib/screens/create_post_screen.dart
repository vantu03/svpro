import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/post.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/widgets/post/post_avatar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController controller = TextEditingController();
  bool canPost = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(onTextChanged);
  }

  void onTextChanged() {
    setState(() {
      canPost = controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    controller.removeListener(onTextChanged);
    controller.dispose();
    super.dispose();
  }

  void handlePost() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    AppNavigator.showLoadingDialog(message: "Đang đăng bài...");
    try {
      final res = await ApiService.createPost(text);

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }

      var jsonData = jsonDecode(res.body);
      if (jsonData['detail']['status']) {
        AppNavigator.pop();
        AppNavigator.pop(PostModel.fromJson(jsonData['detail']['data']));
        AppNavigator.success('Đã đăng bài thành công');
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e) {
      debugPrint("error: $e");
      AppNavigator.error('Không thể kết nối tới máy chủ');
    } finally {
      AppNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => AppNavigator.pop(),
        ),
        title: const Text(
          "Tạo bài viết",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: canPost ? handlePost : null,
            child: Text(
              "Đăng",
              style: TextStyle(
                color: canPost ? Colors.white : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Avatar + tên user
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  PostAvatar(url: LocalStorage.userAvatarUrl, radius: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      LocalStorage.userFullName ?? "",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Ô nhập nội dung
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: "Bạn đang nghĩ gì?",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
