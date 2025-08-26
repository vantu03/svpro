import 'package:flutter/material.dart';

class AppTheme {

  static Color getColorByDate(DateTime date) {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(d).inDays;

    if (diff < 0) return Colors.grey; // Past
    if (diff == 0) return Color(0xffe8a85d); // Today
    if (diff == 1) return Color(0xff874fa6); // Tomorrow
    return  Color(0xff4baf93); // Future
  }

  static ThemeData lightBlueTheme = ThemeData(
    useMaterial3: false,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      toolbarTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(Colors.blue),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(Colors.blue),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Colors.blue),
      trackColor: MaterialStateProperty.all(Colors.blue.shade200),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.blue,
      thumbColor: Colors.blue,
      inactiveTrackColor: Colors.blue.shade100,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.blue,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.white,
      dialHandColor: Colors.blue,
      dialBackgroundColor: Colors.blue.shade50,
      hourMinuteTextColor: Colors.blue,
      entryModeIconColor: Colors.blue,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
    ).copyWith(
      secondary: Colors.blue,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
  );

}
