import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/widgets/schedule/schedule_day_item.dart';
import 'package:svpro/widgets/tabs/schedule_tab.dart';

class ScheduleCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  final Function(Map<String, dynamic> schedule, int index) onEdit;
  final VoidCallback onDeleted;

  const ScheduleCard({
    super.key,
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header: Thời gian + Loại lịch =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item['startTime'] ?? ''} - ${item['endTime'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  item['scheduleType']?.isNotEmpty == true
                      ? item['scheduleType']
                      : '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            const Divider(height: 8),

            // ===== Tên lịch =====
            Text(
              item['className']?.isNotEmpty == true
                  ? item['className']
                  : 'Chưa có tên',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 6),

            // ===== Chi tiết chính =====
            ...ItemContent.buildDetailList(item['detail'], Colors.black),
            if (isExpanded)
              ...ItemContent.buildDetailList(item['hidden'], Colors.black),


            const SizedBox(height: 4),
            // ===== Hàng nút hành động =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Chỉnh sửa lịch',
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => widget.onEdit(item, widget.index),
                ),
                IconButton(
                  tooltip: 'Xoá lịch',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    AppNavigator.showAlertDialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: const Text("Xác nhận"),
                        content: const Text("Bạn có chắc chắn muốn xoá lịch này?"),
                        actions: [
                          TextButton(
                            onPressed: AppNavigator.pop,
                            child: const Text("Hủy"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              AppNavigator.pop();
                              widget.onDeleted();
                              LocalStorage.customSchedules = LocalStorage.customSchedules
                                  .where((e) => e != item)
                                  .toList();
                              await LocalStorage.push();
                              AppNavigator.success('Đã xoá lịch!');
                              ScheduleTab.scheduleMergerState?.call();
                            },
                            child: const Text("Xoá"),
                          ),
                        ],
                      ),
                    );
                  },


                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
