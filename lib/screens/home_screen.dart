import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/widgets/tabs/home_tab.dart';
import 'package:svpro/widgets/tabs/schedule_tab.dart';
import 'package:svpro/widgets/tabs/notification_tab.dart';
import 'package:svpro/widgets/tabs/menu_tab.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:svpro/ws/ws_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}


WebSocketClient? wsService;

class HomeScreenState extends State<HomeScreen> {

  final List<TabItem> tabs = [
    const HomeTab(),
    const ScheduleTab(),
    const NotificationTab(),
    const MenuTab(),
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LocalStorage.auth_token.isEmpty) {
        context.go('/login');
      } else {
        wsService?.disconnect();
        wsService = WebSocketClient();
        wsService?.onLogout = () async {
          LocalStorage.auth_token = '';
          LocalStorage.schedule = {};
          await LocalStorage.push();
          await NotificationScheduler.setupAllLearningNotifications();
          if (mounted) {
            context.go('/login');
          }
        };
        //wsService?.connect("wss://api.sv.pro.vn/ws/");
        wsService?.connect("ws://127.0.0.1:8000/ws/");
      }
    });
  }

  @override
  void dispose() {
    wsService?.disconnect();
    super.dispose();
  }

  void switchToTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (LocalStorage.auth_token.isEmpty) {
      return CircularProgressIndicator();
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
          setState(() => currentIndex = index);
          tabs[index].onTab();
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
