import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/widgets/schedule/schedule_card.dart';
import 'package:svpro/widgets/tabs/schedule_tab.dart';

class CustomScheduleScreen extends StatefulWidget {
  const CustomScheduleScreen({super.key});

  @override
  State<CustomScheduleScreen> createState() => CustomScheduleScreenState();
}

class CustomScheduleScreenState extends State<CustomScheduleScreen> {
  List<Map<String, dynamic>> schedules = [];

  final Map<int, String> weekOptions = {
    0: 'Cả tuần',
    2: 'Thứ 2',
    3: 'Thứ 3',
    4: 'Thứ 4',
    5: 'Thứ 5',
    6: 'Thứ 6',
    7: 'Thứ 7',
    1: 'Chủ nhật',
  };


  @override
  void initState() {
    super.initState();
    schedules = List<Map<String, dynamic>>.from(LocalStorage.customSchedules);
  }
  Future<void> _addOrEditSchedule({Map<String, dynamic>? schedule, int? index}) async {
    final typeController = TextEditingController(text: schedule?['scheduleType'] ?? '');
    final nameController = TextEditingController(text: schedule?['className'] ?? '');
    final startDateController = TextEditingController(
        text: schedule?['startDate'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now()));
    final endDateController = TextEditingController(
        text: schedule?['endDate'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now()));
    int dayOfWeek = schedule?['dayOfWeek'] ?? 0;

    // Không đặt giá trị mặc định cho giờ bắt đầu và giờ kết thúc
    final startTimeController = TextEditingController(text: schedule?['startTime'] ?? '');
    final endTimeController = TextEditingController(text: schedule?['endTime'] ?? '');

    List<Map<String, String>> details = [];
    if (schedule != null && schedule['detail'] is Map) {
      schedule['detail'].forEach((k, v) {
        details.add({'key': k, 'value': v});
      });
    }
    if (details.isEmpty) details.add({'key': '', 'value': ''});

    List<Map<String, String>> hidden = [];
    if (schedule != null && schedule['hidden'] is Map) {
      schedule['hidden'].forEach((k, v) {
        hidden.add({'key': k, 'value': v});
      });
    }

    await AppNavigator.showAlertDialog(
      AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Tuỳ chỉnh lịch'),
        content: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Loại lịch =====
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: 'Loại lịch',
                  hintText: 'Lịch học, Lịch thi, Sự kiện...',
                ),
              ),
              const SizedBox(height: 10),

              // ===== Tên lịch =====
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên lịch',
                  hintText: 'Tên môn học, tên sự kiện, ...',
                ),
              ),
              const SizedBox(height: 10),

              // ===== Ngày bắt đầu - kết thúc =====
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startDateController,
                      decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          startDateController.text =
                              DateFormat('dd/MM/yyyy').format(picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: endDateController,
                      decoration: const InputDecoration(labelText: 'Ngày kết thúc'),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          endDateController.text =
                              DateFormat('dd/MM/yyyy').format(picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ===== Trong tuần =====
              DropdownButtonFormField<int>(
                value: dayOfWeek,
                decoration: const InputDecoration(labelText: 'Diễn ra'),
                items: weekOptions.entries
                    .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
                    .toList(),
                onChanged: (v) => setModalState(() => dayOfWeek = v ?? 0),
              ),
              const SizedBox(height: 10),

              // ===== Khoảng thời gian =====
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Giờ bắt đầu',
                        hintText: 'hh:mm',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Giờ kết thúc',
                        hintText: 'hh:mm',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== Chi tiết lịch =====
              const Text('Chi tiết lịch', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...List.generate(details.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: 'Địa điểm, Tiết, ...'),
                          controller: TextEditingController(text: details[i]['key']),
                          onChanged: (v) => details[i]['key'] = v,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: 'C1, 1,2,3, ...'),
                          controller: TextEditingController(text: details[i]['value']),
                          onChanged: (v) => details[i]['value'] = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Colors.red),
                        onPressed: () {
                          details.removeAt(i);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                  onPressed: () {
                    details.add({'key': '', 'value': ''});
                    setModalState(() {});
                  },
                ),
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              // ===== Mô tả ẩn =====
              const Text('Chi tiết phụ (Không bắt buộc)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...List.generate(hidden.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: 'Ghi chú, giáo viên, ...'),
                          controller: TextEditingController(text: hidden[i]['key']),
                          onChanged: (v) => hidden[i]['key'] = v,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(hintText: 'Nội dung, ...'),
                          controller: TextEditingController(text: hidden[i]['value']),
                          onChanged: (v) => hidden[i]['value'] = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Colors.red),
                        onPressed: () {
                          hidden.removeAt(i);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                  onPressed: () {
                    hidden.add({'key': '', 'value': ''});
                    setModalState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final detailMap = <String, String>{};
              for (var d in details) {
                if (d['key']!.isNotEmpty && d['value']!.isNotEmpty) {
                  detailMap[d['key']!] = d['value']!;
                }
              }

              final hiddenMap = <String, String>{};
              for (var d in hidden) {
                if (d['key']!.isNotEmpty && d['value']!.isNotEmpty) {
                  hiddenMap[d['key']!] = d['value']!;
                }
              }

              final data = {
                'scheduleType': typeController.text.trim(),
                'className': nameController.text.trim(),
                'startDate': startDateController.text.trim(),
                'endDate': endDateController.text.trim(),
                'dayOfWeek': dayOfWeek,
                'startTime': startTimeController.text.trim(),
                'endTime': endTimeController.text.trim(),
                'detail': detailMap,
                'hidden': hiddenMap,
              };

              if (index != null) {
                schedules[index] = data;
              } else {
                schedules.add(data);
              }

              LocalStorage.customSchedules = schedules;
              await LocalStorage.push();
              AppNavigator.success('Lưu lịch thành công!');
              setState(() {});
              AppNavigator.pop();
              ScheduleTab.scheduleMergerState?.call();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Tuỳ chỉnh lịch'),
          centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditSchedule(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm mới'),

      ),
      body: schedules.isEmpty
          ? const Center(child: Text('Chưa có lịch nào được thêm.'))
          : ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final item = schedules[index];
          return ScheduleCard(
            item: item,
            index: index,
            onEdit: (schedule, i) => _addOrEditSchedule(schedule: schedule, index: i),
            onDeleted: () {
              setState(() {
                schedules.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }
}
