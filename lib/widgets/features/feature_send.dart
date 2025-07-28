import 'package:flutter/material.dart';
import 'package:svpro/widgets/feature_item.dart';

class FeatureSend extends StatelessWidget implements FeatureItem {
  const FeatureSend({super.key});

  @override
  String get label => 'Bắn đơn';

  @override
  IconData get icon => Icons.send;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text('Giao diện Bắn đơn')),
    );
  }
}
