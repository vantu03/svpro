import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/schedule.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/services/notification_service.dart';
import 'package:svpro/widgets/rotating_widget.dart';
import 'package:svpro/widgets/schedule/schedule_display.dart';
import 'package:svpro/widgets/tab_item.dart';

class ScheduleTab extends StatefulWidget implements TabItem {
  const ScheduleTab({super.key});

  @override
  String get id => 'schedule';

  @override
  String get label => 'Lịch';

  @override
  IconData get icon => Icons.calendar_today;

  @override
  State<ScheduleTab> createState() => ScheduleTabState();

  @override
  void onTab() {

  }
}

class ScheduleTabState extends State<ScheduleTab> {

  bool isLoading = false;
  late List<Schedule> events = [];
  late List<DateTime> days = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 20), (_) async {

      if (!isLoading && LocalStorage.schedule.isNotEmpty && LocalStorage.lastUpdateTime != null &&
          DateTime.now().difference(LocalStorage.lastUpdateTime!) > const Duration(minutes: 5)
      ) {
        setState(() {
          isLoading = true;
        });
        await fetchSchedule();
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        actions: [
          IconButton(
            icon: isLoading ? RotatingWidget(
              isRotating: true,
              child: Icon(Icons.sync),
            ): Icon(Icons.sync),
            tooltip: 'Tải lại lịch học',
            onPressed: () async {
              if (!isLoading) {
                setState(() {
                  isLoading = true;
                });
                await fetchSchedule();
                setState(() {
                  isLoading = false;
                });
              }
            },
          ),
        ],

        centerTitle: false,
      ),
      body: Row(
        children: [
          if (LocalStorage.schedule.isEmpty) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Chưa có dữ liệu lịch học.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (!isLoading)
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await fetchSchedule();
                          setState(() {
                            isLoading = false;
                          });
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Cập nhật lịch học'),
                      ),
                    if (isLoading)
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            )
          ] else
          Expanded(
            child: ScheduleDisplay(),
          ),
        ],
      ),
    );
  }

  Future<void> fetchSchedule() async {

    try {
      final response = await ApiService.getSchedule();
      var jsonData = jsonDecode(response.body);
      if (jsonData['detail']['status']) {
        LocalStorage.lastUpdateTime = DateTime.now();
        if (LocalStorage.schedule.isNotEmpty &&
            jsonEncode(LocalStorage.schedule) != jsonEncode(jsonData['detail']['data'])) {
          await NotificationService().showNotification(
            id: 1000,
            title: 'Lịch có thay đổi',
            body: 'Hãy chú ý lịch đã có một số thay đổi rồi.',
          );
        }
        ScheduleDisplay.isInitialized = false;

        LocalStorage.schedule = jsonData['detail']['data'];
        await NotificationScheduler.setupAllLearningNotifications();
        await LocalStorage.push();
        AppNavigator.success('Lịch đã được đồng bộ với hệ thống!');
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e){
      debugPrint("error: $e");
    }
  }

}
