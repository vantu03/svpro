
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'local_storage.dart';

class NotificationPermissionService {

  static Future<bool> requestNotificationPermission({bool needExactAlarm = true}) async {
    // 🌐 WEB
    if (kIsWeb) {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    // 🍎 iOS / macOS
    if (Platform.isIOS || Platform.isMacOS) {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true, badge: true, sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    // 🤖 ANDROID
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

  static Future<void> initFcmToken() async {


    // Lấy token ban đầu
    FirebaseMessaging.instance.getToken().then((token) async {
      if (token != null) {
        LocalStorage.fcm_token = token;
      } else {
        print('Da bi chan lay token');
      }
    });

    // Lắng nghe khi token đổi
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (LocalStorage.fcm_token != newToken) {
        LocalStorage.fcm_token = newToken;
      }
    });
  }

}
