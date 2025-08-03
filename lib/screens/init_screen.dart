import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:svpro/firebase_options.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_service.dart';
import 'package:svpro/services/push_notification_service.dart';
import 'package:go_router/go_router.dart';

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
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print("❌ Firebase init error: $e");
    }

    try {
      await NotificationService.instance.init();
    } catch (e) {
      print("❌ Notification init error: $e");
    }

    try {
      await PushNotificationService().init();
    } catch (e) {
      print("❌ Push init error: $e");
    }

    await Future.delayed(const Duration(milliseconds: 100));
    print('init complate...');
    InitScreen.initialized = true;
    if (mounted) {
      context.go('/home');
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
          /*Image.asset('assets/images/background.jpg', fit: BoxFit.cover),*/
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
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
