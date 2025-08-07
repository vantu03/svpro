import 'package:flutter/material.dart';
import 'package:svpro/models/schedule.dart';
import 'package:intl/intl.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/widgets/schedule/schedule_calendar.dart';
import 'package:svpro/widgets/schedule/schedule_day_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleDisplay extends StatefulWidget {

  const ScheduleDisplay({super.key});

  @override
  State<ScheduleDisplay> createState() => ScheduleDisplayState();
}


DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

class ScheduleDisplayState extends State<ScheduleDisplay> {

  late List<Schedule> events = [];
  late List<DateTime> days = [];

  DateTime firstDay = normalizeDate(DateTime.now());
  DateTime lastDay = normalizeDate(DateTime.now()).add(Duration(days: 7));
  DateTime focusedDay = normalizeDate(DateTime.now());

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    initSchedule();

    itemPositionsListener.itemPositions.addListener(onScroll);
  }
  void onScroll() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // 1. Chỉ xét các item đang "visible: true"
    final visiblePositions = positions.where((position) {
      final date = days[position.index];
      final now = normalizeDate(DateTime.now());

      // Tính toán lại logic visible giống như bên ScheduleDayView
      return normalizeDate(date) == normalizeDate(focusedDay) ||
          !(date.isBefore(focusedDay) && date.isBefore(now));
    }).toList();

    if (visiblePositions.isEmpty) return;

    // 2. Lấy item đang ở trên cùng
    final topVisibleIndex = visiblePositions
        .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b)
        .index;

    final scrolledDay = days[topVisibleIndex];

    // 3. Nếu khác ngày hiện tại thì cập nhật focus
    if (!isSameDay(scrolledDay, focusedDay)) {
      setState(() {
        focusedDay = scrolledDay;
      });
    }

    // 4. Add thêm ngày nếu cần
    final maxIndex = positions.map((e) => e.index).reduce((a, b) => a > b ? a : b);
    if (maxIndex >= days.length - 1) {
      addMoreDays();
    }
  }


  void addMoreDays() {
    final newDays = List.generate(7, (i) => lastDay.add(Duration(days: i + 1)),);

    setState(() {
      days.addAll(newDays);
      lastDay = days.last;
    });
  }

  void initSchedule() {
    final now = normalizeDate(DateTime.now());
    firstDay = DateFormat('dd/MM/yyyy').parse(LocalStorage.schedule['startDate']);
    lastDay = DateFormat('dd/MM/yyyy').parse(LocalStorage.schedule['endDate']);

    if (lastDay.isBefore(now)) {
      lastDay = now.add(const Duration(days: 30));
    }
    events = (LocalStorage.schedule['schedule'] as List)
        .map((e) => Schedule.fromJson(e))
        .toList();
    days = List.generate(
      lastDay.difference(firstDay).inDays + 1,
          (i) => firstDay.add(Duration(days: i)),
    );
    NotificationScheduler.setupAllLearningNotifications();
  }

  void jumpToDate(DateTime date) {
    final index = days.indexWhere((d) => normalizeDate(d) == normalizeDate(date));
    if (index != -1 && itemScrollController.isAttached) {
      itemScrollController.jumpTo(index: index);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScheduleCalendar(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: focusedDay,
          selectedDay: focusedDay,
          events: events,
          onDaySelected: (selected) {
            setState(() {
              focusedDay = selected;
            });
            jumpToDate(selected);
          },
        ),

        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            itemCount: days.length,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            itemBuilder: (context, index) {
              final date = days[index];
              final filtered = events.where(
                    (e) => e.date == DateFormat('dd/MM/yyyy').format(date),
              ).toList();

              return ScheduleDayView(
                date: date,
                schedules: filtered,
                visible: normalizeDate(date) == normalizeDate(focusedDay) ||
                    !(date.isBefore(focusedDay) && date.isBefore(normalizeDate(DateTime.now()))),
              );
            },
          ),
        ),

      ],
    );


  }


}