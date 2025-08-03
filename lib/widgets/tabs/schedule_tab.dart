import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:svpro/models/schedule.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:svpro/widgets/schedule/schedule_display.dart';
import 'package:svpro/widgets/tab_item.dart';

class ScheduleTab extends StatefulWidget implements TabItem {
  const ScheduleTab({super.key});

  @override
  String get label => 'Lịch học';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (isLoading) ...[
            const CircularProgressIndicator()
          ] else ...[
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Tải lại lịch học',
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                await fetchSchedule();
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ],
        centerTitle: false,
      ),

      backgroundColor: Colors.white,
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

    Notifier.info(context, 'Đang tải lịch học...');

    try {
      final response = await ApiService.getSchedule();
      var jsonData = jsonDecode(response.body);
      if (jsonData['detail']['status']) {
        LocalStorage.lastUpdateTime = DateTime.now();
        LocalStorage.schedule = jsonData['detail']['data'];
        await NotificationScheduler.setupAllLearningNotifications();
        await LocalStorage.push();
        if (mounted) {
          Notifier.success(context, 'Lịch đã được đồng bộ với hệ thống!');
        }
      } else {
        if (mounted) {
          Notifier.error(context, jsonData['detail']['message']);
        }
      }
    } catch (e){
      if (mounted) {
        Notifier.error(context, 'Lỗi hệ thống: $e');
      }
    }
  }

}
