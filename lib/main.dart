import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/app_theme.dart';
import 'package:svpro/screens/custom_schedule_screen.dart';
import 'package:svpro/screens/home_screen.dart';
import 'package:svpro/screens/login_screen.dart';
import 'package:svpro/screens/settings_screen.dart';
import 'package:svpro/screens/init_screen.dart';

import 'app_navigator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      navigatorKey: AppNavigator.key,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const InitScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final tabId = state.uri.queryParameters['tab'];
            return HomeScreen(initialTabId: tabId);
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/custom_schedule',
          builder: (context, state) => const CustomScheduleScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightBlueTheme,
      locale: const Locale('vi'),
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
