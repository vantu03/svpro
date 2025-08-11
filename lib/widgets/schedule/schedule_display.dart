import 'dart:async';

import 'package:flutter/material.dart';
import 'package:svpro/models/schedule.dart';
import 'package:intl/intl.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/widgets/schedule/schedule_calendar.dart';
import 'package:svpro/widgets/schedule/schedule_day_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleDisplay extends StatefulWidget {

  static bool isInitialized = false;

  const ScheduleDisplay({super.key});

  @override
  State<ScheduleDisplay> createState() => ScheduleDisplayState();

}

DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

class ScheduleDisplayState extends State<ScheduleDisplay> {

  late List<Schedule> events = [];
  late List<DateTime> days = [];

  static final DateTime today = normalizeDate(DateTime.now());
  DateTime firstDay = today;
  DateTime lastDay = today.add(Duration(days: 30));
  DateTime focusedDay = today;
  int lastScroll = 0;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  bool _scrollScheduled = false;
  int _lastOnScrollMs = 0;
  static const int kOnScrollThrottleMs = 500;

  @override
  void initState() {
    super.initState();
    initSchedule();


    itemPositionsListener.itemPositions.addListener(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_scrollScheduled) return;

      if (now - _lastOnScrollMs >= kOnScrollThrottleMs) {
        _lastOnScrollMs = now;
        onScroll(); // chạy ngay
      } else {
        _scrollScheduled = true;
        final delay = Duration(milliseconds: kOnScrollThrottleMs - (now - _lastOnScrollMs));
        Future.delayed(delay, () {
          _scrollScheduled = false;
          _lastOnScrollMs = DateTime.now().millisecondsSinceEpoch;
          onScroll(); // chạy trễ 1 lần
        });
      }
    });
  }

  void onScroll() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final topItem = positions.reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b);

    final scrolledDay = days[topItem.index];
    if (!isSameDay(scrolledDay, focusedDay)) {
      setState(() {
        focusedDay = scrolledDay;
      });
    }

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
    firstDay = today.add(const Duration(days: -365 * 4));//DateFormat('dd/MM/yyyy').parse(LocalStorage.schedule['startDate']);
    lastDay = today.add(const Duration(days: 365));//DateFormat('dd/MM/yyyy').parse(LocalStorage.schedule['endDate']);

    events = (LocalStorage.schedule['schedule'] as List)
        .map((e) => Schedule.fromJson(e))
        .toList();
    days = List.generate(
      lastDay.difference(today).inDays + 1,
          (i) => today.add(Duration(days: i)),
    );
    ScheduleDisplay.isInitialized = true;
  }

  void jumpToDate(DateTime date) {
    final normalized = normalizeDate(date);

    if (normalized.isBefore(days.first)) {
      final daysToAdd = days.first.difference(normalized).inDays;

      final newDays = List.generate(
        daysToAdd,
            (i) => normalized.add(Duration(days: i)),
      );

      setState(() {
        days.insertAll(0, newDays);
      });

    }
    // Nếu ngày đã tồn tại rồi thì scroll luôn
    int index = days.indexWhere((d) => d == normalized);
    if (index != -1 && itemScrollController.isAttached) {
      itemScrollController.jumpTo(index: index);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {

    if (!ScheduleDisplay.isInitialized) {
      initSchedule();
    }
    return Stack(
      children: [
        Column(
          children: [
            Container(

              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: ScheduleCalendar(
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
                  );
                },
              ),
            ),
          ],
        ),

        if (!isSameDay(focusedDay, today))
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              tooltip: 'Lịch hiện tại',
              onPressed: () {
                setState(() {
                  focusedDay = today;
                });
                jumpToDate(today);
              },
              child: const Icon(
                Icons.explore,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }

}