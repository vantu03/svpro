import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svpro/models/schedule.dart';
import 'package:svpro/widgets/schedule/schedule_day_item.dart';

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
          width: 35,
          child: Column(
            children: [
              Text(
                DateFormat('d').format(date),
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 4),
              Text(
                ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][date.weekday % 7],
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

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