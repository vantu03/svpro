import 'package:flutter/material.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/app_web_view.dart';

class FeatureUtilities extends StatefulWidget implements FeatureItem {
  const FeatureUtilities({super.key});

  @override
  String get label => 'Tiện ích';

  @override
  IconData get icon => Icons.extension_rounded;

  @override
  String get go => '';

  @override
  State<FeatureUtilities> createState() => FeatureUtilitiesState();
}

class FeatureUtilitiesState extends State<FeatureUtilities> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        centerTitle: false,
      ),
      body: AppWebView(
        url: LocalStorage.utilities,
      ),
    );
  }
}
