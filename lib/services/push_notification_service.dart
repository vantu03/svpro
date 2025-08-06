import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_service.dart';


class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String fcm_token = '';
  Future<void> init() async {
    // Xin quyền nhận thông báo
    await messaging.requestPermission();

    // In ra token dùng để gửi từ server
    final token = await messaging.getToken();

    if (token != null) {
      PushNotificationService.fcm_token = token;
    }

    //Nhận thông báo khi app đang chạy (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        NotificationService().showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
        );
      }
    });

    // Nhận khi nhấn vào notification (app background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked (background): ${message.data}");

    });

    // Nhận khi app đang bị **tắt hoàn toàn** (terminated) và mở từ notification
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print("Notification clicked (terminated): ${initialMessage.data}");

    }
  }
}
