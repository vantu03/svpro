import 'package:flutter/material.dart';
import 'package:svpro/widgets/tab_item.dart';

class NotificationTab extends StatefulWidget implements TabItem {
  const NotificationTab({super.key});

  @override
  String get label => 'Thông báo';

  @override
  IconData get icon => Icons.notifications;

  @override
  State<NotificationTab> createState() => NotificationTabState();
}

class NotificationTabState extends State<NotificationTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notifications_off, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Chưa có thông báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Khi có thông báo, chúng sẽ xuất hiện tại đây.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
