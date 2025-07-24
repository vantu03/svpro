import 'package:flutter/material.dart';
import 'package:svpro/models/schedule.dart';
import 'package:intl/intl.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/widgets/schedule/schedule_item.dart';

class ScheduleDisplay extends StatefulWidget {

  const ScheduleDisplay({super.key});

  @override
  State<ScheduleDisplay> createState() => ScheduleDisplayState();
}

class ScheduleDisplayState extends State<ScheduleDisplay> {

  late List<Schedule> events = [];
  late List<DateTime> days = [];

  void initSchedule() {
    final startDate = DateFormat('dd/MM/yyyy').parse(LocalStorage.schedule['startDate']);
    final endDate = DateFormat('dd/MM/yyyy').parse(LocalStorage.schedule['endDate']);
    events = (LocalStorage.schedule['schedule'] as List)
        .map((e) => Schedule.fromJson(e))
        .toList();
    days = List.generate(
      endDate
          .difference(startDate)
          .inDays + 1,
          (i) => startDate.add(Duration(days: i)),
    );
    NotificationScheduler.setupAllLearningNotifications();
  }
  @override
  Widget build(BuildContext context) {

    initSchedule();

    return Container(
      color: Colors.grey[200],
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        itemBuilder: (context, index) {
          final date = days[index];
          final filtered = events.where(
                (e) => e.date == DateFormat('dd/MM/yyyy').format(date),
          ).toList();
          return Column(
            children: [
              if (filtered.isEmpty)
                Item(event: null, date: date, showDate: true)
              else
                for (int i = 0; i < filtered.length; i++)
                  Item(
                    event: filtered[i],
                    date: date,
                    showDate: i == 0,
                  ),
            ],
          );
        },
      ),
    );
  }
}