import 'package:flutter/material.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'feedback/feedback_form.dart';

class FeatureFeedback extends StatefulWidget implements FeatureItem {
  const FeatureFeedback({super.key});

  @override
  String get label => 'Góp ý phát triển';

  @override
  IconData get icon => Icons.feedback_outlined;

  @override
  String get go => '';

  @override
  State<FeatureFeedback> createState() => FeatureFeedbackState();
}

class FeatureFeedbackState extends State<FeatureFeedback> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        centerTitle: false,
      ),
      body: const FeedbackForm(),
    );
  }
}
