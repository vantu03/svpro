import 'package:flutter/material.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_scheduler.dart';
import 'package:svpro/widgets/time_picker_tile.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => NotificationSettingsScreenState();
}

class NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Cài đặt thông báo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ==== Cài đặt thông báo ngày mai ====
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Báo lịch học ngày mai'),
                      value: LocalStorage.notifyTomorrow,
                      onChanged: (val) async {
                        setState(() => LocalStorage.notifyTomorrow = val);
                        await LocalStorage.push();
                        await NotificationScheduler.setupAllLearningNotifications();
                      },
                    ),
                    if (LocalStorage.notifyTomorrow)
                      TimePickerTile(
                        label: 'Giờ thông báo',
                        time: TimeOfDay(
                          hour: LocalStorage.notifyTomorrowHour,
                          minute: LocalStorage.notifyTomorrowMinute,
                        ),
                        onPicked: (picked) async {
                          setState(() {
                            LocalStorage.notifyTomorrowHour = picked.hour;
                            LocalStorage.notifyTomorrowMinute = picked.minute;
                          });
                          await LocalStorage.push();
                          await NotificationScheduler.setupAllLearningNotifications();
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==== Cài đặt thông báo tuần tới ====
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Báo lịch học tuần tới (Chủ nhật)'),
                      value: LocalStorage.notifyWeekly,
                      onChanged: (val) async {
                        setState(() => LocalStorage.notifyWeekly = val);
                        await LocalStorage.push();
                        await NotificationScheduler.setupAllLearningNotifications();
                      },
                    ),
                    if (LocalStorage.notifyWeekly)
                      TimePickerTile(
                        label: 'Giờ thông báo',
                        time: TimeOfDay(
                          hour: LocalStorage.notifyWeeklyHour,
                          minute: LocalStorage.notifyWeeklyMinute,
                        ),
                        onPicked: (picked) async {
                          setState(() {
                            LocalStorage.notifyWeeklyHour = picked.hour;
                            LocalStorage.notifyWeeklyMinute = picked.minute;
                          });
                          await LocalStorage.push();
                          await NotificationScheduler.setupAllLearningNotifications();
                        },
                      ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
