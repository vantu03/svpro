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
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue,
                width: 1,
              ),
            ),
            todayTextStyle: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),


            defaultTextStyle: TextStyle(color: Colors.black),
            weekendTextStyle: TextStyle(color: Colors.red),
            selectedTextStyle: TextStyle(color: Colors.white),
          ),

          startingDayOfWeek: StartingDayOfWeek.monday,
          headerVisible: calendarFormat != CalendarFormat.week,
          eventLoader: (day) {
            final formatted = DateFormat('dd/MM/yyyy').format(day);
            return widget.events
                .where((e) => e.date == formatted)
                .toList();
          },

          onFormatChanged: (format) {
            setState(() {
              calendarFormat = format;
            });
          },
          selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),


          onDaySelected: (selected, focused) {
            widget.onDaySelected?.call(selected);
          },

          onPageChanged: (day) {

          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, eventsForDay) {
              if (eventsForDay.isEmpty) return const SizedBox.shrink();

              return Positioned(
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    eventsForDay.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                calendarFormat =
                isMonth ? CalendarFormat.week : CalendarFormat.month;
              });
            },
            icon: Icon(
              isMonth ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.blue,
            ),
            label: Text(
              isMonth ? 'Ẩn bớt' : 'Hiện thêm',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
