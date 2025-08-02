import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svpro/models/schedule.dart';

class Item extends StatefulWidget {
  final Schedule? event;
  final DateTime date;
  final bool showDate;

  const Item({
    super.key,
    required this.event,
    required this.date,
    this.showDate = false,
  });

  @override
  State<Item> createState() => ItemState();
}

class ItemState extends State<Item> {
  bool isExpanded = false;

  String get dayString => DateFormat('dd/MM').format(widget.date);
  String get weekDay => ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][widget.date.weekday % 7];

  Color getBackgroundColor() {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    final target = DateTime(widget.date.year, widget.date.month, widget.date.day);
    final diff = target.difference(d).inDays;
    if (diff < 0) return const Color(0xFFCCCCCC); // past
    if (diff == 0) return const Color(0xFFECB472); // today
    if (diff == 1) return const Color(0xFF9968B5); // tomorrow
    return const Color(0xFF6ABAA3); // future
  }

  bool isPast() {
    final now = DateTime.now();
    final date = DateTime(widget.date.year, widget.date.month, widget.date.day);
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  @override
  Widget build(BuildContext context) {
    if (isPast()) {
      return Visibility(
        visible: false,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: const SizedBox.shrink(),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() => isExpanded = !isExpanded);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showDate)
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Text(dayString, style: const TextStyle(fontSize: 10)),
                      Text(weekDay, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                    ],
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: getBackgroundColor(),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...[
                        if (widget.event != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.event!.timeRange, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(widget.event!.scheduleType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(color: Colors.white70),
                          Text(widget.event!.className, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          ...widget.event!.detail.entries.map(
                                (e) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: Colors.white, fontSize: 12)),
                                Expanded(
                                  child: Text('${e.key}: ${e.value}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded && widget.event!.hidden.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.event!.hidden.entries.map(
                                    (e) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    Expanded(
                                      child: Text('${e.key}: ${e.value}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ).toList(),
                            ),
                        ] else ...[
                          Center(child: Text('Bạn rảnh...', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                        ],
                      ],

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
