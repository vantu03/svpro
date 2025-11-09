import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_storage.dart';

class NotificationPermissionService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Kiểm tra xem quyền thông báo đã được cấp chưa
  static Future<bool> isNotificationPermissionGranted() async {
    if (kIsWeb) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    if (Platform.isAndroid) {
      final androidPlugin =
      _localNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final enabled = await androidPlugin?.areNotificationsEnabled();
      return enabled ?? true;
    }

    return true;
  }

  /// Xin quyền thông báo (nếu cần)
  static Future<bool> requestNotificationPermission({bool needExactAlarm = true}) async {
    // WEB
    if (kIsWeb) {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    // iOS / macOS
    if (Platform.isIOS || Platform.isMacOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    // ANDROID
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdk = androidInfo.version.sdkInt ?? 0;

      if (sdk >= 33) {
        final res = await Permission.notification.request();
        if (!res.isGranted) return false;
      }
      if (needExactAlarm && sdk >= 31) {
        final res = await Permission.scheduleExactAlarm.request();
        if (!res.isGranted) return false;
      }
      return true;
    }

    return true;
  }

  /// Lấy và lắng nghe token FCM
  static Future<void> initFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      LocalStorage.fcm_token = token;
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (LocalStorage.fcm_token != newToken) {
        LocalStorage.fcm_token = newToken;
      }
    });
  }
}
