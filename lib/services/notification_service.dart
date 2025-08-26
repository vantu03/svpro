import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:svpro/app_navigator.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static final NotificationService instance = NotificationService.internal();
  factory NotificationService() => instance;

  static String? pendingPayload;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService.internal();


  Future<void> init() async {
    // Timezone cho schedule
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Android (đảm bảo đã có icon trong mipmap/drawable)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS & macOS: KHÔNG tự xin quyền ở init (để xin khi cần)
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // Khi app đang foreground vẫn hiện thông báo
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const WindowsInitializationSettings initializationSettingsWindows =
    WindowsInitializationSettings(
      appName: 'SVPro',
      appUserModelId: 'com.example.flutter_notifications',
      guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground, // optional
    );



    final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if ((details?.didNotificationLaunchApp ?? false) &&
        details?.notificationResponse != null) {
      pendingPayload = details!.notificationResponse!.payload;
    }
  }

  // Tap khi app đang chạy
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    pendingPayload = response.payload;
    processPendingPayload();
  }

  // Tap khi app bị kill (Android background isolate)
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    debugPrint('Background tap: ${response.payload}');
    pendingPayload = response.payload;
  }

  bool processPendingPayload() {
    if (pendingPayload?.isNotEmpty == true) {
      handlePayload(pendingPayload);
      pendingPayload = null;
      return true;
    }
    return false;
  }

  void handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      final action = data['action'] ?? 'navigate';
      switch (action) {
        case 'navigate': {
          final route = (data['route'] as String?) ?? '/';
          final params = (data['params'] as Map?)?.cast<String, dynamic>() ?? const {};
          final uri = Uri(path: route, queryParameters: params.map((k, v) => MapEntry(k, '$v')));
          AppNavigator.safeGo(uri.toString());
          break;
        }

        case 'open_url': {
          final url = data['url'] as String?;
          if (url != null && url.isNotEmpty) {
            final uri = Uri.parse(url);
            launchUrl(uri, mode: LaunchMode.inAppWebView);
          }
          break;
        }

        case 'open_url_blank': {
          final url = data['url'] as String?;
          if (url != null && url.isNotEmpty) {
            final uri = Uri.parse(url);
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          break;
        }

        default: {
          AppNavigator.safeGo(payload);
        }
      }
    } catch (e) {
      debugPrint("error: $e");

      Timer(const Duration(seconds: 5), () {
        AppNavigator.warning(e.toString());
      });
    }
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool bumpBadge = false,
    String? sound
  }) async {

    if (bumpBadge) {
      _badgeCount = (_badgeCount + 1).clamp(0, 9999);
    }

    final androidDetails = AndroidNotificationDetails(
      'immediate_channel',
      'SVPro',
      channelDescription: 'Channel for immediate notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      channelShowBadge: true,
      number: badgeCount,
      playSound: true,
      sound: sound != null
          ? RawResourceAndroidNotificationSound(sound.split(".")[0].trim())
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: badgeCount,
      sound: (sound ?? "default"),
    );


    final notificationDetails = NotificationDetails(
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
    await applyBadge();
  }

  /// Schedule a notification for a specific time (even after reboot if allowed)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
    BuildContext? context,
    bumpBadge = false,
    String? sound,

  }) async {

    if (scheduledDateTime.isBefore(DateTime.now())) {
      debugPrint("warning: The notification schedule is overdue( $scheduledDateTime)");
      return;
    }

    if (bumpBadge) {
      _badgeCount = (_badgeCount + 1).clamp(0, 9999);
    }
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDateTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Channel for scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      channelShowBadge: true,
      number: badgeCount,
      playSound: true,
      sound: sound != null
          ? RawResourceAndroidNotificationSound(sound.split(".")[0].trim())
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: (sound ?? "default"),
      badgeNumber: badgeCount,
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
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  int _badgeCount = 0;
  int get badgeCount => _badgeCount;

  Future<void> setBadgeFromServer(int unread) async {
    _badgeCount = unread.clamp(0, 9999);
    await applyBadge();
  }

  Future<void> incBadge([int step = 1]) async {
    _badgeCount = (_badgeCount + step).clamp(0, 9999);
    await applyBadge();
  }

  Future<void> clearBadge() async {
    _badgeCount = 0;
    await applyBadge();
  }

  Future<void> applyBadge() async {
    if (badgeCount <= 0) {
      await AppBadgePlus.updateBadge(0);
    } else {
      await AppBadgePlus.updateBadge(badgeCount);
    }
  }

}
