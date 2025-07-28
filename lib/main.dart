import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/screens/home_screen.dart';
import 'package:svpro/screens/login_screen.dart';
import 'package:svpro/screens/settings_screen.dart';
import 'package:svpro/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => SplashScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => NotificationSettingsScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => LoginScreen(),
          ),
        ],
      ),
    );
  }
}
