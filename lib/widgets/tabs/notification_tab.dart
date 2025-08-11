import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
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

  @override
  void initState() {
    super.initState();

    timeago.setLocaleMessages('vi', timeago.ViMessages());

    wsService.onLoadNotification = () async {
      await loadNotifications();
      await loadUnreadCount();
    };

    wsService.onInsertNotification = (data) {
      try {
        final notification = NotificationModel.fromJson(data);
        NotificationService.instance.setBadgeFromServer(NotificationService.instance.badgeCount + 1);
        widget.onBadgeChanged?.call(widget.id, NotificationService.instance.badgeCount);
        setState(() {
          notifications.insert(0, notification);
        });
      } catch (e) {
        debugPrint(' Lỗi khi xử lý thông báo từ socket: $e');
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
      debugPrint('loadUnreadCount error: $e');
    }
  }

  Future<void> loadNotifications({bool initial = false}) async {
    try {
      final response = await ApiService.getNotifications(offset: offset, limit: limit);
      final jsonData = jsonDecode(response.body);

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
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e) {
      debugPrint('$e');
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
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
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
          : RefreshIndicator(
        onRefresh: refreshNotifications,
        child: ListView.builder(
          controller: scrollController, // QUAN TRỌNG
          itemCount: notifications.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == notifications.length) {
              // item loader ở cuối danh sách
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final item = notifications[index];
            final isUnread = !item.isRead;

            return InkWell(
              onTap: () async {
                if (isUnread) {
                  try {
                    setState(() => item.isRead = true);
                    NotificationService.instance.setBadgeFromServer(NotificationService.instance.badgeCount - 1);
                    widget.onBadgeChanged?.call(widget.id, NotificationService.instance.badgeCount);
                    await ApiService.markNotificationRead(item.id);
                  } catch (e) {
                    debugPrint('$e');
                  }
                }
              },
              child: Container(
                color: isUnread ? Colors.blue.shade50 : Colors.white,
                child: ListTile(
                  leading: Icon(
                    isUnread ? Icons.mark_email_unread : Icons.mark_email_read,
                    color: isUnread ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.content),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(DateTime.parse(item.createdAt), locale: 'vi'),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: isUnread
                      ? const Icon(Icons.brightness_1, size: 10, color: Colors.blue)
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
