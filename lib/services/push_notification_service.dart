import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:svpro/services/notification_service.dart';


class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<void> init() async {

    //Nhận thông báo khi app đang chạy (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {

        final payload = message.data['payload'];
        final meta = jsonDecode(message.data['__meta']);
        NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          payload: payload,
          sound: meta['sound']
        );
      }
    });

    // Nhận khi nhấn vào notification (app background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationService.pendingPayload = message.data['payload'];
      NotificationService.instance.processPendingPayload();

    });

    // Nhận khi app đang bị **tắt hoàn toàn** (terminated) và mở từ notification
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      NotificationService.pendingPayload = initial.data['payload'];
    }
  }
}
