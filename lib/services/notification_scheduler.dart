import 'package:svpro/models/feature.dart';
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
    for (int i = 0; i <= 4; i++) {

      final nextDay = now.add(Duration(days: i));
      // === Thông báo mỗi ngày cho ngày hôm sau ===
      if (LocalStorage.notifyTomorrow) {
        final targetDate = nextDay.add(Duration(days: 1));
        final dateStr = DateFormat('dd/MM/yyyy').format(targetDate);
        final eventsOnTarget = events.where((e) => e.date == dateStr).toList();

        final msg = eventsOnTarget.isEmpty
            ? 'Mai bạn rảnh?'
            : 'Mai bạn có ${eventsOnTarget.length} lịch cần thực hiện.';

        final scheduledTime = DateTime(
          nextDay.year,
          nextDay.month,
          nextDay.day,
          LocalStorage.notifyTomorrowHour,
          LocalStorage.notifyTomorrowMinute,
        );

        await NotificationService().scheduleNotification(
          id: 200 + i,
          title: 'Lịch học ngày ${DateFormat('dd/MM').format(targetDate)}',
          body: msg,
          scheduledDateTime: scheduledTime,
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

        final msg = nextWeekEvents.isEmpty
            ? 'Tuần sau bạn rảnh, đã chuẩn bị thư giãn chưa?'
            : 'Tuần sau bạn có ${nextWeekEvents
            .length} lịch học cần thực hiện.';

        final scheduledTime = DateTime(
          nextDay.year,
          nextDay.month,
          nextDay.day,
          LocalStorage.notifyWeeklyHour,
          LocalStorage.notifyWeeklyMinute,
        );

        await NotificationService().scheduleNotification(
          id: 999 + i,
          title: 'Lịch học tuần tới',
          body: msg,
          scheduledDateTime: scheduledTime,
        );
      }
    }
  }
}
