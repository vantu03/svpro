import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/screens/home_screen.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/utils/dialog_helper.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:svpro/widgets/tab_item.dart';

class MenuTab extends StatefulWidget implements TabItem {
  const MenuTab({super.key});

  @override
  String get label => 'Menu';

  @override
  IconData get icon => Icons.menu;

  @override
  State<MenuTab> createState() => _MenuTabState();

  @override
  void onTab() {

  }

}

class _MenuTabState extends State<MenuTab> {

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
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.green),
            title: const Text('Thêm thông báo test',
                style: TextStyle(color: Colors.green)),
            onTap: () {
              if (wsService?.isConnected ?? false) {
                wsService!.send("add_test_notification", {});
                Notifier.success(context, "Đã gửi yêu cầu test qua socket.");
              } else {
                Notifier.error(context, "Socket chưa kết nối.");
              }
            },
          ),

        ],
      ),
    );
  }
}
