import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // ==== Biến RAM tạm ====
  static String auth_token = '';

  static Map<String, dynamic> schedule = {};
  static DateTime? lastUpdateTime;

  static bool notifyTomorrow = true;
  static bool notifyWeekly = true;
  static int notifyTomorrowHour = 20;
  static int notifyTomorrowMinute = 0;
  static int notifyWeeklyHour = 20;
  static int notifyWeeklyMinute = 0;

  /// ==== Load toàn bộ từ SharedPreferences vào RAM ====
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    auth_token = prefs.getString('auth_token') ?? '';

    final jsonString = prefs.getString('schedule_json');
    schedule = jsonString != null ? jsonDecode(jsonString) : {};

    final lastUpdateRaw = prefs.getString('last_update');
    lastUpdateTime = lastUpdateRaw != null ? DateTime.tryParse(lastUpdateRaw) : null;

    notifyTomorrow = prefs.getBool('notifyTomorrow') ?? true;
    notifyWeekly = prefs.getBool('notifyWeekly') ?? true;
    notifyTomorrowHour = prefs.getInt('notifyTomorrowHour') ?? 20;
    notifyTomorrowMinute = prefs.getInt('notifyTomorrowMinute') ?? 0;
    notifyWeeklyHour = prefs.getInt('notifyWeeklyHour') ?? 20;
    notifyWeeklyMinute = prefs.getInt('notifyWeeklyMinute') ?? 0;

  }

  /// ==== Lưu toàn bộ RAM vào SharedPreferences ====
  static Future<void> push() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', auth_token);

    await prefs.setString('schedule_json', jsonEncode(schedule));

    if (lastUpdateTime != null) {
      await prefs.setString('last_update', lastUpdateTime!.toIso8601String());
    }

    await prefs.setBool('notifyTomorrow', notifyTomorrow);
    await prefs.setBool('notifyWeekly', notifyWeekly);
    await prefs.setInt('notifyTomorrowHour', notifyTomorrowHour);
    await prefs.setInt('notifyTomorrowMinute', notifyTomorrowMinute);
    await prefs.setInt('notifyWeeklyHour', notifyWeeklyHour);
    await prefs.setInt('notifyWeeklyMinute', notifyWeeklyMinute);

  }

}
