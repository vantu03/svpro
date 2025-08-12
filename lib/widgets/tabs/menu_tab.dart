import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/services/notification_service.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:svpro/ws/ws_client.dart';

class MenuTab extends StatefulWidget implements TabItem {
  const MenuTab({super.key, this.onBadgeChanged});

  final BadgeSetter? onBadgeChanged;

  @override
  String get id => 'menu';

  @override
  String get label => 'Menu';

  @override
  IconData get icon => Icons.menu;

  @override
  State<MenuTab> createState() => MenuTabState();

  @override
  void onTab() {

  }

}

class MenuTabState extends State<MenuTab> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              AppNavigator.showConfirmationDialog(
                title: 'Xác nhận',
                content: 'Bạn có chắc muốn đăng xuất?',
                confirmText: 'Đăng xuất',
                confirmColor: Colors.red,
                onConfirm: () async {
                  try {
                    AppNavigator.showLoadingDialog();
                    final response = await ApiService.logout();
                    final jsonData = jsonDecode(response.body);

                    if (jsonData['detail']['status']) {
                      AppNavigator.warning(jsonData['detail']['message']);
                    } else {
                      AppNavigator.error(jsonData['detail']['message']);
                    }
                  } catch (e) {
                    print(e);
                    AppNavigator.error('Không thể kết nối tới máy chủ');
                  } finally {

                    LocalStorage.auth_token = '';
                    LocalStorage.schedule = {};
                    await LocalStorage.push();
                    await NotificationScheduler.setupAllLearningNotifications();
                    AppNavigator.safeGo('/login');
                  }
                },
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.add_alert, color: Colors.green),
            title: const Text('Thêm thông báo',
                style: TextStyle(color: Colors.green)),
            onTap: () {
              if (wsService.isConnected) {
                wsService.send("add_test_notification", {});
                AppNavigator.success("Đã gửi yêu cầu test qua socket.");
              } else {
                AppNavigator.error("Socket chưa kết nối.");
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_alarm, color: Colors.green),
            title: const Text('Kiểm tra thông báo',
                style: TextStyle(color: Colors.green)),
            onTap: () async {

              final payload = {
                "action": "navigate",
                "route": "/home",
                "params": {
                  "tab": "notifications"
                },
              };

              final now = DateTime.now();

              // Gửi thông báo ngay
              await NotificationService().showNotification(
                id: 999,
                title: 'Test ngay',
                body: 'Thông báo hiển thị ngay lập tức!',
                payload: jsonEncode(payload),
                sound: 'sound_warning.wav',
              );

              // Gửi thông báo sau 5 giây
              await NotificationService().scheduleNotification(
                id: 1000,
                title: 'Test sau 5s',
                body: 'Thông báo được gửi sau 5 giây!',
                scheduledDateTime: now.add(const Duration(seconds: 5)),
                payload: jsonEncode(payload),
                sound: 'sound_schedule.wav',
              );
            },
          ),

        ],
      ),
    );
  }
}
