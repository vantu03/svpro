import 'package:flutter/material.dart';

abstract class TabItem {
  String get id;
  String get label;
  IconData get icon;

  void onTab();

}
