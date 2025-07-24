import 'package:flutter/material.dart';

class Notifier {
  static void show(
      BuildContext context,
      String message, {
        Color backgroundColor = Colors.black87,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  static void warning(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.orange,
    );
  }

  static void info(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.blue,
    );
  }
}
