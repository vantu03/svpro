import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/widgets/tab_item.dart';

class MenuTab extends StatefulWidget implements TabItem {
  const MenuTab({super.key});

  @override
  String get label => 'Menu';

  @override
  IconData get icon => Icons.menu;

  @override
  State<MenuTab> createState() => MenuTabState();
}

class MenuTabState extends State<MenuTab> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            onTap: () => context.push('/settings'),
          ),

          if (LocalStorage.auth_token.isNotEmpty) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () => {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text('Bạn có chắc muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        child: const Text('Hủy'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Đăng xuất'),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          LocalStorage.auth_token = '';
                          LocalStorage.schedule = {};
                          await LocalStorage.push();
                          await NotificationScheduler.setupAllLearningNotifications();
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                      ),
                    ],
                  ),
                )
              },
            ),
          ]
        ],
      ),
    );
  }
}
