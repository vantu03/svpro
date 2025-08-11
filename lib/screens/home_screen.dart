
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/services/app_permission_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/widgets/tabs/home_tab.dart';
import 'package:svpro/widgets/tabs/schedule_tab.dart';
import 'package:svpro/widgets/tabs/notification_tab.dart';
import 'package:svpro/widgets/tabs/menu_tab.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:svpro/ws/ws_client.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key, this.initialTabId});
  final String? initialTabId;

  @override
  State<HomeScreen> createState() => HomeScreenState();

}

class HomeScreenState extends State<HomeScreen> {

  final List<TabItem> tabs = [
    const HomeTab(),
    const ScheduleTab(),
    const NotificationTab(),
    const MenuTab(),
  ];

  int currentIndex = 0;

  int indexFromParam(String? idOrIndex) {
    if (idOrIndex == null || idOrIndex.isEmpty) return 0;
    final n = int.tryParse(idOrIndex);
    if (n != null && n >= 0 && n < tabs.length) return n;
    final i = tabs.indexWhere((t) => t.id == idOrIndex);
    return i >= 0 ? i : 0;
  }

  @override
  void initState() {
    super.initState();

    currentIndex = indexFromParam(widget.initialTabId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (LocalStorage.auth_token.isEmpty) {
        AppNavigator.safeGo('/login');
      } else {

        wsService.connect();
        //Đăng ký các hàm
        wsService.onLogout = () async {
          LocalStorage.auth_token = '';
          LocalStorage.schedule = {};
          await LocalStorage.push();
          await NotificationScheduler.setupAllLearningNotifications();
          AppNavigator.safeGo('/login');
        };

        if (!LocalStorage.notificationsAsked) {
          await AppNavigator.showConfirmationDialog(
            title: 'Bật thông báo',
            content: 'Bật để nhận lịch học và nhắc nhở quan trọng.',
            confirmText: 'Bật ngay',
            confirmColor: Colors.blueAccent,
            onConfirm: () async {

              LocalStorage.notificationsAsked = true;
              await LocalStorage.push();

              final granted = await NotificationPermissionService.requestNotificationPermission();
              if (!granted) {
                await AppNavigator.showConfirmationDialog(
                    title: '',
                    content: 'Bật lại thông báo hãy mở \'Cài đặt\' nhé!',
                    confirmText: 'OK',
                    cancelText: null,
                    onConfirm: () {});
              }
            },
          );
        }
      }
    });
  }

  @override
  void dispose() {
    wsService.disconnect();
    super.dispose();
  }

  void switchToTab(int index) {

    if (currentIndex == index) return;
    setState(() {
      currentIndex = index;
    });
    tabs[index].onTab();
    AppNavigator.safeGo('/home?tab=${tabs[index].id}');
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabId != widget.initialTabId) {
      final newIndex = indexFromParam(widget.initialTabId);
      switchToTab(newIndex);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (LocalStorage.auth_token.isEmpty) {
      return Center(child: CircularProgressIndicator(),);
    }
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs.cast<Widget>(),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switchToTab(index);
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(tab.icon),
            label: tab.label,
          );
        }).toList(),
      ),

    );
  }
}
