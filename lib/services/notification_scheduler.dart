import 'dart:convert';

import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_service.dart';
import 'package:svpro/models/schedule.dart';
import 'package:intl/intl.dart';

class NotificationScheduler {
  static Future<void> setupAllLearningNotifications() async {
    if (LocalStorage.schedule.isEmpty) return;

    final events = (LocalStorage.schedule['schedule'] as List)
        .map((e) => Schedule.fromJson(e))
        .toList();

    await NotificationService().cancelAllNotifications();

    final now = DateTime.now();
    for (int i = 0; i <= 14; i++) {

      final nextDay = now.add(Duration(days: i));
      // === Thông báo mỗi ngày cho ngày hôm sau ===
      if (LocalStorage.notifyTomorrow) {
        final targetDate = nextDay.add(Duration(days: 1));
        final dateStr = DateFormat('dd/MM/yyyy').format(targetDate);
        final eventsOnTarget = events.where((e) => e.date == dateStr).toList();

        final scheduledTime = DateTime(
          nextDay.year,
          nextDay.month,
          nextDay.day,
          LocalStorage.notifyTomorrowHour,
          LocalStorage.notifyTomorrowMinute,
        );


        final payload = {
          "action": "navigate",
          "route": "/home",
          "params": {
            "tab": "schedule"
          },
        };

        await NotificationService().scheduleNotification(
          id: 200 + i,
          title: eventsOnTarget.isEmpty ? 'Mai bạn rảnh?' : 'Mai bạn có ${eventsOnTarget.length} lịch cần thực hiện.',
          body: 'Lịch ngày ${DateFormat('dd/MM').format(targetDate)}',
          scheduledDateTime: scheduledTime,
          payload: jsonEncode(payload),
        );
      }

      // === Thông báo tuần tới: chỉ chạy nếu hôm nay là Chủ nhật ===
      if (LocalStorage.notifyWeekly && nextDay.weekday == DateTime.sunday) {
        final nextMonday = nextDay.add(const Duration(days: 1));
        final nextSunday = nextMonday.add(const Duration(days: 6));

        final nextWeekEvents = events.where((e) {
          final eDate = DateFormat('dd/MM/yyyy').parse(e.date);
          return !eDate.isBefore(nextMonday) && !eDate.isAfter(nextSunday);
        }).toList();

        final startStr = DateFormat('dd/MM').format(nextMonday);
        final endStr = DateFormat('dd/MM').format(nextSunday);
        final uniqueDays = nextWeekEvents.map((e) => e.date).toSet().length;

        final scheduledTime = DateTime(
          nextDay.year,
          nextDay.month,
          nextDay.day,
          LocalStorage.notifyWeeklyHour,
          LocalStorage.notifyWeeklyMinute,
        );

        final payload = {
          "action": "navigate",
          "route": "/home",
          "params": {
            "tab": "schedule"
          },
        };

        await NotificationService().scheduleNotification(
          id: 999 + i,
          title: nextWeekEvents.isEmpty ? 'Tuần sau bạn rảnh' : 'Tuần sau bạn có $uniqueDays ngày cần thực hiện.',
          body: 'Tuần tới sẽ bắt đầu từ $startStr kết thúc $endStr.${nextWeekEvents.isEmpty ? 'Bạn đã chuẩn bị đi chơi chưa?' : 'Bạn đã chuẩn bị tới đâu rồi...'}',
          scheduledDateTime: scheduledTime,
          payload: jsonEncode(payload),
        );
      }
    }
  }
}
