import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/feature.dart';
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

  static Future<void> Function()? scheduleMergerState;

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

      if (!isLoading && LocalStorage.schedules.isNotEmpty && LocalStorage.lastUpdateTime != null &&
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

    ScheduleTab.scheduleMergerState = () async {
      ScheduleDisplay.isInitialized = false;
      setState(() {
        isLoading = true;
      });
      await scheduleMerger();
      setState(() {
        isLoading = false;
      });
    };
  }

  @override
  void dispose() {
    timer?.cancel();
    ScheduleTab.scheduleMergerState = null;
    super.dispose();
  }

  Future<void> scheduleMerger() async {
    final scheduleOld = List<Map<String, dynamic>>.from(
        LocalStorage.schedules.map((e) => Map<String, dynamic>.from(e)));

    LocalStorage.schedules = [];

    // Gộp dữ liệu từ API trước
    LocalStorage.schedules.addAll((LocalStorage.schedule['schedule'] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList());

    // Gộp lịch custom
    for (final s in LocalStorage.customSchedules) {
      try {
        final startDate = DateFormat('dd/MM/yyyy').parse(s['startDate']);
        final endDate = DateFormat('dd/MM/yyyy').parse(s['endDate']);
        final int dayOfWeek = s['dayOfWeek'] ?? 0;

        // Duyệt qua toàn bộ khoảng ngày
        for (DateTime d = startDate;
        !d.isAfter(endDate);
        d = d.add(const Duration(days: 1))) {

          final weekday = d.weekday;

          // Nếu dayOfWeek = 0 (cả tuần) hoặc trùng thứ thì thêm
          if (dayOfWeek == 0 || dayOfWeek == weekday) {
            LocalStorage.schedules.add({
              'date': DateFormat('dd/MM/yyyy').format(d),
              'timeRange': '${s['startTime']} - ${s['endTime']}',
              'scheduleType': s['scheduleType'],
              'className': s['className'],
              'detail': Map<String, dynamic>.from(s['detail']),
              'hidden': Map<String, dynamic>.from(s['hidden']),
              'isCustom': true,
            });


          }
        }

      } catch (e, stack) {
        debugPrint("error: $e");
        debugPrintStack(stackTrace: stack);
      }
    }
    const deepEq = DeepCollectionEquality.unordered();

    final isDifferent = !deepEq.equals(scheduleOld, LocalStorage.schedules);


    if (isDifferent) {
      await NotificationService().showNotification(
        id: 1000,
        title: 'Lịch có thay đổi',
        body: 'Hãy chú ý, lịch học đã được cập nhật.',
        sound: 'sound_tongtong.mp3',
      );
      HapticFeedback.mediumImpact();
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'Chỉnh sửa',
              onPressed: () async {
                AppNavigator.safePush("/custom_schedule");
              }
          ),
          IconButton(
            icon: isLoading ? RotatingWidget(
              isRotating: true,
              child: Icon(Icons.sync),
            ): Icon(Icons.sync),
            tooltip: 'Tải lại lịch',
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
          if (LocalStorage.schedules.isEmpty) ...[
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
        ScheduleDisplay.isInitialized = false;

        LocalStorage.schedule = jsonData['detail']['data'];
        await scheduleMerger();

        await NotificationScheduler.setupAllLearningNotifications();
        await LocalStorage.push();
        AppNavigator.success('Lịch đã được đồng bộ với hệ thống!');
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e, stack) {
      debugPrint("error: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

}
