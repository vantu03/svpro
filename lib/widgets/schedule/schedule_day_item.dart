import 'package:flutter/material.dart';
import 'package:svpro/app_theme.dart';
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


  static List<Widget> buildDetailList(Map? data, Color color) {
    if (data == null || data.isEmpty) return [];
    return (data.entries).map<Widget>((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(
                Icons.circle,
                size: 6,
                color: color
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${e.key}: ${e.value}',
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class ItemContentState extends State<ItemContent> {
  bool isExpanded = false;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppTheme.getColorByDate(widget.date),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: widget.event == null
          ? const Center(
        heightFactor: 2,
        child: Text(
          'Bạn rảnh...',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
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
                ...ItemContent.buildDetailList(widget.event!.detail, Colors.white),
                if (isExpanded && widget.event!.hidden.isNotEmpty)
                  ...ItemContent.buildDetailList(widget.event!.hidden, Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
