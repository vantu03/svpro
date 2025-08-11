import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/screens/home_screen.dart';
import 'package:svpro/screens/login_screen.dart';
import 'package:svpro/screens/settings_screen.dart';
import 'package:svpro/screens/init_screen.dart';

import 'app_navigator.dart';
import 'firebase_options.dart';

void main() async {
  debugPrint('main() called');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('MyApp.build');
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      locale: const Locale('vi'),
      supportedLocales: const [
        Locale('vi'),
        Locale('en'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: GoRouter(
        navigatorKey: AppNavigator.key,
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => InitScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              String? initialTabId = state.uri.queryParameters['tab'];
              return HomeScreen(initialTabId:initialTabId);
            },
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
