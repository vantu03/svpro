import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/services/app_permission_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_service.dart';
import 'package:svpro/services/push_notification_service.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  static bool initialized = false;

  @override
  State<InitScreen> createState() => InitScreenState();
}
class InitScreenState extends State<InitScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initApp();
    });
  }

  Future<void> initApp() async {
    print("🔁 initApp started");
    await LocalStorage.init();
    try {
      await NotificationService.instance.init();
    } catch (e) {
      print("❌ Notification init error: $e");
    }

    try {
      await PushNotificationService().init();
      await NotificationPermissionService.initFcmToken();
    } catch (e) {
      print("❌ Push init error: $e");
    }
    print('init complate...');
    InitScreen.initialized = true;

    if (NotificationService.instance.processPendingPayload()) {
      return;
    }
    if (AppNavigator.hasPending) {
      AppNavigator.flushPending();
    } else if (mounted) {
      AppNavigator.safeGo('/home');
    }

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: LinearProgressIndicator(
              value: progress,
              color: Colors.white,
              backgroundColor: Colors.white30,
              minHeight: 6,
            ),
          ),
          Center(
            child: Image.asset(
              'assets/icon/app_icon.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),

        ],
      ),
    );
  }
}
