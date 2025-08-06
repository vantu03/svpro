import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/services/notification_service.dart';
import 'package:svpro/utils/dialog_helper.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:svpro/ws/ws_client.dart';

class MenuTab extends StatefulWidget implements TabItem {
  const MenuTab({super.key});

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
              DialogHelper.showConfirmationDialog(
                context: context,
                title: 'Xác nhận',
                content: 'Bạn có chắc muốn đăng xuất?',
                confirmText: 'Đăng xuất',
                confirmColor: Colors.red,
                onConfirm: () async {
                  DialogHelper.showLoadingDialog(context);

                  try {
                    final response = await ApiService.logout();
                    final jsonData = jsonDecode(response.body);

                    if (jsonData['detail']['status']) {
                      if (context.mounted) {
                        Notifier.warning(context, jsonData['detail']['message']);
                      }
                    } else {
                      if (context.mounted) {
                        Notifier.error(context, jsonData['detail']['message']);
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Notifier.error(context, 'Lỗi hệ thống: $e');
                    }
                  } finally {

                    LocalStorage.auth_token = '';
                    LocalStorage.schedule = {};
                    await LocalStorage.push();
                    await NotificationScheduler.setupAllLearningNotifications();

                    if (context.mounted) {
                      context.go('/login');
                      DialogHelper.hideDialog(context);
                    }
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
                Notifier.success(context, "Đã gửi yêu cầu test qua socket.");
              } else {
                Notifier.error(context, "Socket chưa kết nối.");
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_alarm, color: Colors.green),
            title: const Text('Kiểm tra thông báo',
                style: TextStyle(color: Colors.green)),
            onTap: () async {
              final now = DateTime.now();

              // Gửi thông báo ngay
              await NotificationService().showNotification(
                id: 999,
                title: 'Test ngay',
                body: 'Thông báo hiển thị ngay lập tức!',
              );

              // Gửi thông báo sau 5 giây
              await NotificationService().scheduleNotification(
                id: 1000,
                title: 'Test sau 5s',
                body: 'Thông báo được gửi sau 5 giây!',
                scheduledDateTime: now.add(const Duration(seconds: 5)),
              );
            },
          ),
        ],
      ),
    );
  }
}
