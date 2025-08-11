import 'package:flutter/material.dart';
import 'package:svpro/widgets/feature_item.dart';

class FeatureSchedule extends StatelessWidget implements FeatureItem {
  const FeatureSchedule({super.key});

  @override
  String get label => 'Xem lịch';

  @override
  IconData get icon => Icons.event_note;

  @override
  String get go => '/home?tab=schedule';

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

}
