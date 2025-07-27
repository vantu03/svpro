import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_service.dart';


class PushNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Xin quyền nhận thông báo
    await messaging.requestPermission();

    // In ra token dùng để gửi từ server
    final token = await messaging.getToken();

    if (token != null) {
      LocalStorage.fcm_token = token;

      try {
        final response = await ApiService.sendFcmToken();

        if (response.statusCode == 200) {
          print("Token sent and saved: ${token.toString()}");
        }
        print("Failed to send token to server");
      } catch (e) {
        print("Exception: $e");
      }
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
