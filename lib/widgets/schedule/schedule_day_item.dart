import 'package:flutter/material.dart';
import 'package:svpro/models/schedule.dart';

class ItemContent extends StatefulWidget {
  final Schedule? event;
  final DateTime date;

  const ItemContent({
    super.key,
    required this.event,
    required this.date,
  });

  @override
  State<ItemContent> createState() => ItemContentState();
}

class ItemContentState extends State<ItemContent> {
  bool isExpanded = false;

  Color getBackgroundColor() {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    final target = DateTime(widget.date.year, widget.date.month, widget.date.day);
    final diff = target.difference(d).inDays;

    if (diff < 0) return const Color(0xFFCCCCCC); // Past
    if (diff == 0) return const Color(0xFFECB472); // Today
    if (diff == 1) return const Color(0xFF9968B5); // Tomorrow
    return const Color(0xFF6ABAA3); // Future
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: widget.event == null
          ? const Center(
        child: Text(
          'Bạn rảnh...',
          style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
      )
          : GestureDetector(
        onTap: () => setState(() => isExpanded = !isExpanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng giờ + loại lịch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.event!.timeRange,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Text(widget.event!.scheduleType,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.white70),
            Text(widget.event!.className, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Column(
              children: [
                ...widget.event!.detail.entries.map(
                      (e) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style:
                          TextStyle(color: Colors.white, fontSize: 12)),
                      Expanded(
                        child: Text('${e.key}: ${e.value}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),

                    ],
                  ),
                ),
                if (isExpanded && widget.event!.hidden.isNotEmpty) ...widget.event!.hidden.entries.map(
                      (e) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style:
                          TextStyle(color: Colors.white, fontSize: 12)),
                      Expanded(
                        child: Text('${e.key}: ${e.value}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
