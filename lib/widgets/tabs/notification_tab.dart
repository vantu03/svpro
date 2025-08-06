import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/models/notification.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:svpro/ws/ws_client.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationTab extends StatefulWidget implements TabItem {
  const NotificationTab({super.key});

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
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timeago.setLocaleMessages('vi', timeago.ViMessages());

    wsService.onLoadNotification = () async {
      await loadNotifications();
    };

    wsService.onInsertNotification = (data) {
      try {
        final notification = NotificationModel.fromJson(data);

        setState(() {
          notifications.insert(0, notification);
        });
      } catch (e) {
        debugPrint(' Lỗi khi xử lý thông báo từ socket: $e');
      }
    };

    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  Future<void> loadNotifications() async {
    try {
      final response = await ApiService.getNotifications();
      final jsonData = jsonDecode(response.body);

      if (jsonData['detail']['status']) {
        final List<dynamic> data = jsonData['detail']['data'];
        setState(() {
          notifications = data.map((e) => NotificationModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        Notifier.error(context, jsonData['detail']['message']);
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
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
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return ListTile(
            leading: Icon(item.isRead ? Icons.mark_email_read : Icons.mark_email_unread, color: Colors.blue),
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.content),
                const SizedBox(height: 4),
                Text(
                  timeago.format(DateTime.parse(item.createdAt), locale: 'vi'),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            //trailing: Text(timeago.format(DateTime.parse(item.createdAt), locale: 'vi')),
            onTap: () {
              // Tùy ý xử lý đọc chi tiết
            },
          );
        },
      ),
    );
  }
}
