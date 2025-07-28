import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:svpro/utils/notifier.dart';

class NotificationService {
  static final NotificationService instance = NotificationService.internal();
  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService.internal();

  Future<void> init() async {
    // Init timezone (required for scheduled notifications)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

// Android init (phải đặt icon trong `android/app/src/main/res/drawable/`)
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');


// iOS & macOS
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

// Linux
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

// Windows
    final WindowsInitializationSettings initializationSettingsWindows =
    WindowsInitializationSettings(
      appName: 'SVPro',
      appUserModelId: 'com.example.flutter_notifications',
      guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
    );

// Gộp tất cả platform vào InitializationSettings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
    );

// Khởi tạo plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground, // optional
    );

    //Xin quyền ios
    final plugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final settings = await plugin?.requestPermissions(alert: true, badge: true, sound: true);
    print('🟢 iOS notification permission granted: $settings');



  }
    // Handle when notification is tapped
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // handle tap action here
    print("🔔 Notification clicked: ${response.payload}, ${response.id}, ${response.actionId}");
  }

  // Required entrypoint for background notification response
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    print('🔕 Background Notification tapped: ${response.payload}, ${response.id}, ${response.actionId}');
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'immediate_channel',
      'SVPro',
      channelDescription: 'Channel for immediate notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );


    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
    print('Da gui thong bao');
  }

  /// Schedule a notification for a specific time (even after reboot if allowed)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
    BuildContext? context,
  }) async {

    if (scheduledDateTime.isBefore(DateTime.now())) {
      print('⛔ Thời gian đặt thông báo đã trôi qua: $scheduledDateTime');
      return;
    }
    // Kiểm tra quyền exact alarm nếu Android 12+
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        final status = await Permission.scheduleExactAlarm.status;
        if (!status.isGranted) {
          final result = await Permission.scheduleExactAlarm.request();
          if (!result.isGranted) {

            if (context != null) {
              Notifier.error(context, 'Quền đặt lịch thông báo chính xác bị từ chối.');
            } else {
              print('❌ Không được phép đặt lịch thông báo chính xác.');
            }
            return;
          }
        }
      }
    }
    final tz.TZDateTime scheduledTZ =
    tz.TZDateTime.from(scheduledDateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Channel for scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const winDetails = WindowsNotificationDetails(
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      windows: winDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('Da gui thong bao lich');
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> test() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'Test title',
      'Test body',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

}
