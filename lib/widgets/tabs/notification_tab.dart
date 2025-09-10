import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/models/notification.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/notification_service.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:svpro/ws/ws_client.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTab extends StatefulWidget implements TabItem {
  const NotificationTab({super.key, this.onBadgeChanged});


  final BadgeSetter? onBadgeChanged;

  @override
  String get id => 'notifications';

  @override
  String get label => 'Thông báo';

  @override
  IconData get icon => Icons.notifications;

  @override
  State<NotificationTab> createState() => NotificationTabState();

  @override
  void onTab() {

  }
}

class NotificationTabState extends State<NotificationTab> {

  final ScrollController scrollController = ScrollController();

  List<NotificationModel> notifications = [];

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  Timer? timer;
  int offset = 0;
  final int limit = 10;

  static const double kItemExtent = 88.0;

  String? subId;

  @override
  void initState() {
    super.initState();

    timeago.setLocaleMessages('vi', timeago.ViMessages());

    subId = wsService.addSubscription(refreshNotifications);

    wsService.onNotificationInserted = (data) {
      try {
        final notification = NotificationModel.fromJson(data);
        NotificationService.instance.setBadgeFromServer(NotificationService.instance.badgeCount + 1);
        widget.onBadgeChanged?.call(widget.id, NotificationService.instance.badgeCount);
        setState(() {
          notifications.insert(0, notification);
        });
      } catch (e) {
        debugPrint("error: $e");
      }
    };

    wsService.onReadNotification = (data) {
      try {

        setState(() {
          final index = notifications.indexWhere((n) => n.id == data['id']);
          if (index != -1) {
            notifications[index].isRead = true;
          }
        });
        NotificationService.instance.setBadgeFromServer(data['unread_count']);
        widget.onBadgeChanged?.call(widget.id, NotificationService.instance.badgeCount);
      } catch (e) {
        debugPrint('Lỗi khi xử lý thông báo từ socket: $e');
      }
    };

    wsService.onReadNotificationAll = () {
      setState(() {
          for (var n in notifications) {
            n.isRead = true;
          }
        });
        NotificationService.instance.setBadgeFromServer(0);
        widget.onBadgeChanged?.call(widget.id, 0);
    };

    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
    scrollController.addListener(onScroll);
  }

  Future<void> loadUnreadCount() async {
    try {
      final res = await ApiService.getUnreadCount();
      final jsonData = jsonDecode(res.body);
      if (jsonData['detail']['status'] == true) {
        NotificationService.instance.setBadgeFromServer((jsonData['detail']['data']['unread_count'] as num).toInt());

        widget.onBadgeChanged?.call(widget.id, NotificationService.instance.badgeCount);
      }
    } catch (e) {
      debugPrint("error: $e");
    }
  }

  Future<void> loadNotifications({bool initial = false}) async {
    try {
      final res = await ApiService.getNotifications(offset: offset, limit: limit);

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      final jsonData = jsonDecode(res.body);

      if (jsonData['detail']['status']) {
        final List<dynamic> data = jsonData['detail']['data'];

        final items = data.map((e) => NotificationModel.fromJson(e)).toList();

        setState(() {
          if (initial) {
            notifications = items;
          } else {
            notifications.addAll(items);
          }
          offset += items.length;
          hasMore = items.length == limit;
        });
      } else {
        AppNavigator.error(jsonData['detail']['message']);
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

    final threshold = 10.0;
    final position = scrollController.position;
    final reachedEnd = position.pixels >= (position.maxScrollExtent - threshold);

    if (reachedEnd) {
      loadMoreNotifications();
    }
  }

  Future<void> refreshNotifications() async {
    setState(() {
      isLoading = true;
      offset = 0;
      hasMore = true;
    });
    await loadNotifications(initial: true);
    await loadUnreadCount();
  }

  Future<void> loadMoreNotifications() async {
    setState(() => isLoadingMore = true);
    await loadNotifications(initial: false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    timer?.cancel();
    if (subId != null) {
      wsService.removeSubscription(subId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (BuildContext context) {
                  return DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.25,
                    minChildSize: 0.25,
                    maxChildSize: 0.9,
                    builder: (context, scrollController) {
                      return Column(
                        children: [
                          Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.mark_email_read_rounded),
                                  title: const Text("Đánh dấu tất cả là đã đọc"),
                                  onTap: () async {
                                    setState(() {
                                      for (var n in notifications) {
                                        n.isRead = true;
                                      }
                                    });
                                    NotificationService.instance.setBadgeFromServer(0);
                                    widget.onBadgeChanged?.call(widget.id, 0);
                                    await ApiService.markAllNotificationsRead();
                                    AppNavigator.pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );

            }

          ),
        ],

      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text('Chưa có thông báo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Khi có thông báo, chúng sẽ xuất hiện tại đây.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          :
      RefreshIndicator(
        onRefresh: refreshNotifications,
        child: ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: notifications.length + (isLoadingMore ? 1 : 0),
          itemExtent: kItemExtent,
          itemBuilder: (context, index) {
            if (index == notifications.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final item = notifications[index];
            final isUnread = !item.isRead;

            return InkWell(
              onTap: () async {
                if (isUnread) {
                  try {
                    setState(() => item.isRead = true);
                    NotificationService.instance.setBadgeFromServer(
                      NotificationService.instance.badgeCount - 1,
                    );
                    widget.onBadgeChanged?.call(widget.id, NotificationService.instance.badgeCount);
                    await ApiService.markNotificationRead(item.id);
                  } catch (e) {
                    debugPrint("error: $e");
                  }
                }
              },
              child: Container(
                color: isUnread ? Colors.blue.shade50 : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Icon(
                        isUnread ? Icons.mark_email_unread : Icons.mark_email_read,
                        color: isUnread ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Content: tối đa 2 dòng, ellipsis
                          Text(
                            item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          // Thời gian: 1 dòng, xám
                          Text(
                            timeago.format(DateTime.parse(item.createdAt), locale: 'vi'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isUnread)
                      const Icon(Icons.brightness_1, size: 10, color: Colors.blue),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
