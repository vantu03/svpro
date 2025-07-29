import 'package:flutter/material.dart';
import 'package:svpro/widgets/tabs/home_tab.dart';
import 'package:svpro/widgets/tabs/schedule_tab.dart';
import 'package:svpro/widgets/tabs/notification_tab.dart';
import 'package:svpro/widgets/tabs/menu_tab.dart';
import 'package:svpro/widgets/tab_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  void switchToTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs.cast<Widget>(),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
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
