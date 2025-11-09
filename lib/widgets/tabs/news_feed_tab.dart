import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/post.dart';
import 'package:svpro/screens/create_post_screen.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/widgets/post/post_avatar.dart';
import 'package:svpro/widgets/post/post_card.dart';
import 'package:svpro/widgets/tab_item.dart';

class NewsFeedTab extends StatefulWidget implements TabItem {
  const NewsFeedTab({super.key});

  @override
  String get id => 'newsfeed';

  @override
  String get label => 'Bản tin';

  @override
  IconData get icon => Icons.article;

  @override
  State<NewsFeedTab> createState() => NewsFeedTabState();

  @override
  void onTab() {
  }
}

class NewsFeedTabState extends State<NewsFeedTab> {
  final ScrollController scrollController = ScrollController();

  List<PostModel> posts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    loadPosts(initial: true);
    scrollController.addListener(onScroll);
  }

  Future<void> loadPosts({bool initial = false}) async {
    try {
      final res = await ApiService.getNews(initial);
      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      final jsonData = jsonDecode(res.body);
      if (jsonData['detail']['status']) {
        final List<dynamic> data = jsonData['detail']['data'];
        final items = data.map((e) => PostModel.fromJson(e)).toList();

        setState(() {
          if (initial) {
            posts = items;
          } else {
            posts.addAll(items);
          }
          hasMore = items.isNotEmpty;
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


  void onScroll() {
    if (!hasMore || isLoadingMore || isLoading) return;
    if (!scrollController.hasClients) return;

    final threshold = 50.0;
    final position = scrollController.position;
    final reachedEnd = position.pixels >= (position.maxScrollExtent - threshold);

    if (reachedEnd) {
      loadMorePosts();
    }
  }

  Future<void> refreshPosts() async {
    setState(() {
      isLoading = true;
      hasMore = true;
    });
    await loadPosts(initial: true);
  }

  Future<void> loadMorePosts() async {
    setState(() => isLoadingMore = true);
    await loadPosts(initial: false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: refreshPosts,
        child: ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 1 + posts.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Ô nhập bài viết luôn ở đầu
            if (index == 0) {
              return InkWell(
                onTap: () async {
                  final newPost = await AppNavigator.safePushWidget<PostModel>(CreatePostScreen());
                  if (newPost != null) {
                    setState(() {
                      posts.insert(0, newPost);
                    });
                  }
                },
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        PostAvatar(url: LocalStorage.userAvatarUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Bạn đang nghĩ gì?",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Loading cuối danh sách
            if (index == posts.length + 1) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Danh sách post
            final post = posts[index - 1]; // trừ 1 vì slot 0 là "Bạn đang nghĩ gì?"
            return PostCard(post: post);
          },
        ),
      ),

    );
  }

}
