import 'package:flutter/material.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/app_web_view.dart';

class FeaturePrivacyPolicy extends StatefulWidget implements FeatureItem {
  const FeaturePrivacyPolicy({super.key});

  @override
  String get label => 'Chính sách quyền riêng tư';

  @override
  IconData get icon => Icons.privacy_tip_outlined;

  @override
  String get go => '';

  @override
  State<FeaturePrivacyPolicy> createState() => FeaturePrivacyPolicyState();
}

class FeaturePrivacyPolicyState extends State<FeaturePrivacyPolicy> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      body: AppWebView(
        url: 'https://sv.pro.vn/chinhsach_svpro.html',
      ),
    );
  }
}
