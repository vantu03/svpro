import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:svpro/firebase_options.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/services/notification_service.dart';
import 'package:svpro/services/push_notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:flutter/foundation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  double progress = 0;

  Future<void> initApp() async {
      await LocalStorage.init();
      setState(() => progress = 0.2);

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        if (mounted) {
          Notifier.error(context, "Init error: $e");
        }
        print("ERROR1: ${e.toString()}");
      }
      setState(() => progress = 0.5);
      try {
        await NotificationService.instance.init();
      } catch (e) {
        if (mounted) {
          Notifier.error(context, "Init error: $e");
        }
        print("ERROR2: ${e.toString()}");
      }

      setState(() => progress = 0.75);

      //if (defaultTargetPlatform == TargetPlatform.android ||
      //      defaultTargetPlatform == TargetPlatform.iOS ||
      //      kIsWeb) {
        try {
          await PushNotificationService().init();
        } catch (e) {
          if (mounted) {
            Notifier.error(context, "Init error: $e");
          }
          print("ERROR3: ${e.toString()}");
        }
      //}
      setState(() => progress = 1.0);

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        context.go('/home');
      }
  }

  @override
  void initState() {
    super.initState();
    initApp();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh nền
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [const Text(
                "Đnag tải...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
                LinearProgressIndicator(
                  value: progress,
                  color: Colors.white,
                  backgroundColor: Colors.white30,
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

}
