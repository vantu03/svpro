import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:svpro/app_core.dart';
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
    debugPrint("🔁 initApp started");
    await LocalStorage.init();
    try {
      await NotificationService.instance.init();
    } catch (e) {
      debugPrint("error: $e");
    }

    try {
      await PushNotificationService().init();
      await NotificationPermissionService.initFcmToken();
    } catch (e) {
      debugPrint("error: $e");
    }

    AppCore.packageInfo = await PackageInfo.fromPlatform();
    debugPrint("init complate...");
    InitScreen.initialized = true;

    if (NotificationService.instance.processPendingPayload()) {
      return;
    }
    AppNavigator.safeGo('/home');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
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
