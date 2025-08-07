import 'package:flutter/material.dart';
import 'package:svpro/models/schedule.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleCalendar extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime? selectedDay;

  final List<Schedule> events;
  final void Function(DateTime)? onDaySelected;

  const ScheduleCalendar({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    this.onDaySelected,
  });

  @override
  State<ScheduleCalendar> createState() => ScheduleCalendarState();
}

class ScheduleCalendarState extends State<ScheduleCalendar> {
  CalendarFormat calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMonth = calendarFormat == CalendarFormat.month;

    return Column(
      children: [
        TableCalendar(
          locale: 'vi',
          focusedDay: widget.focusedDay,
          firstDay: widget.firstDay,
          lastDay: widget.lastDay,
          calendarFormat: calendarFormat,

          startingDayOfWeek: StartingDayOfWeek.monday,
          headerVisible: calendarFormat == CalendarFormat.month,
          eventLoader: (day) {
            final formatted = DateFormat('dd/MM/yyyy').format(day);
            return widget.events
                .where((e) => e.date == formatted)
                .toList();
          },

          selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),


          onDaySelected: (selected, focused) {
            widget.onDaySelected?.call(selected);
          },

          onPageChanged: (day) {
            widget.onDaySelected?.call(day);
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, eventsForDay) {
              if (eventsForDay.isEmpty) return const SizedBox.shrink();

              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    eventsForDay.length.clamp(0, 4),
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Toggle Hiện thêm / Ẩn bớt
        Center(
          child: InkWell(
            onTap: () {
              setState(() {
                calendarFormat = isMonth
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMonth
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isMonth ? 'Ẩn bớt' : 'Hiện thêm',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
