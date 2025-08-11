import 'package:flutter/material.dart';

typedef BadgeSetter = void Function(String tabId, int count);

abstract class TabItem {
  String get id;
  String get label;
  IconData get icon;

  void onTab();
}
