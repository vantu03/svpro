import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svpro/models/schedule.dart';
import 'package:svpro/widgets/schedule/schedule_day_item.dart';


Color getColorByDate(DateTime date) {
  final now = DateTime.now();
  final d = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(d).inDays;

  if (diff < 0) return Colors.grey; // Past
  if (diff == 0) return Colors.orange; // Today
  if (diff == 1) return Colors.purple; // Tomorrow
  return  Colors.teal; // Future
}

class ScheduleDayView extends StatelessWidget {
  final DateTime date;
  final List<Schedule> schedules;

  const ScheduleDayView({
    super.key,
    required this.date,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột trái: ngày và thứ
        Container(
          padding: const EdgeInsets.only(top: 8.0),
          width: 40,
          child: Column(
            children: [
              Text(
                DateFormat('d').format(date),
                style: TextStyle(fontSize: 22, color: getColorByDate(date)),
              ),
              Text(
                ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][date.weekday % 7],
                style: TextStyle(
                  fontSize: 16, color: getColorByDate(date)
                ),
              ),
            ],
          ),
        ),

        // Cột phải: danh sách lịch học
        Expanded(
          child: Column(
            children: schedules.isEmpty ? [
              ItemContent(event: null, date: date),
            ] : schedules.expand((e) => [
              ItemContent(event: e, date: date),
            ]).toList(),
          ),
        ),
      ],
    );
  }
}