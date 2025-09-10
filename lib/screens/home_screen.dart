
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/widgets/tabs/home_tab.dart';
import 'package:svpro/widgets/tabs/schedule_tab.dart';
import 'package:svpro/widgets/tabs/notification_tab.dart';
import 'package:svpro/widgets/tabs/menu_tab.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:svpro/ws/ws_client.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key, this.initialTabId});
  final String? initialTabId;

  @override
  State<HomeScreen> createState() => HomeScreenState();

}

class HomeScreenState extends State<HomeScreen> {

  late final List<TabItem> tabs;

  final Map<String, int> badges = {};

  void setBadge(String tabId, int count) {
    setState(() => badges[tabId] = count < 0 ? 0 : count);
  }

  int badgeOf(TabItem t) => badges[t.id] ?? 0;

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

    tabs = [
      const HomeTab(),
      const ScheduleTab(),
      NotificationTab(onBadgeChanged: setBadge),
      const MenuTab(),
    ];

    currentIndex = indexFromParam(widget.initialTabId);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (LocalStorage.auth_token.isEmpty) {
        AppNavigator.safeGo('/login');
      } else {

        wsService.connect(AppCore.ws_url);
        //Đăng ký các hàm
        wsService.onLogout = () async {
          LocalStorage.auth_token = '';
          LocalStorage.schedule = {};
          await LocalStorage.push();
          await NotificationScheduler.setupAllLearningNotifications();
          AppNavigator.safeGo('/login');
        };
      }
    });

    AppNavigator.flushPending();
    initHome();
  }

  Future<void> initHome() async {
    await checkForUpdate();
  }

 Future<void> checkForUpdate() async {
    try {
      final res = await ApiService.checkUpdate();

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }

      final jsonData = jsonDecode(res.body);
      if (jsonData['detail']['status'] == true) {
        final data = jsonData['detail']['data'];



        if (data['update']) {
          if (data['force']) {
            AppNavigator.showForcedActionDialog(
              title: data['title'],
              content: data['content'],
              onConfirm: () async {
                final url = Uri.parse(data['url']);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              confirmText: data['confirm_text'],
            );
          } else {
            AppNavigator.showConfirmationDialog(
              title: data['title'],
              content: data['content'],
              confirmText: data['confirm_text'],
              onConfirm: () async {
                final url = Uri.parse(data['url']);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            );
          }
        }
      }
    } catch (e) {
      debugPrint("error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    //wsService.disconnect();
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: switchToTab,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: tabs.map((tab) {
          final badge = badgeOf(tab);
          return BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(tab.icon),
                if (badge > 0)
                  Positioned(
                    right: -15, top: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: const BoxDecoration(
                          color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(10))),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            label: tab.label,
          );
        }).toList(),
      ),


    );
  }
}
