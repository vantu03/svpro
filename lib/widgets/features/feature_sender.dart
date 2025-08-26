import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/sender.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/features/sender/sender_info_panel.dart';
import 'package:svpro/widgets/features/sender/sender_register_form.dart';

class FeatureSender extends StatefulWidget implements FeatureItem {
  const FeatureSender({super.key});

  @override
  String get label => 'Gửi đơn';

  @override
  IconData get icon => Icons.send;

  @override
  String get go => '';

  @override
  State<FeatureSender> createState() => FeatureSenderState();
}

class FeatureSenderState extends State<FeatureSender> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        centerTitle: false,
      ),
      body: FutureBuilder(
        future: ApiService.getSender(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi!'));
          } else {
            try {
              var jsonData = jsonDecode(snapshot.data!.body);
              if (jsonData['detail']['status']) {
                final sender = jsonData['detail']['data'];

                if (sender != null) {
                  return SenderInfoPanel(sender: SenderModel.fromJson(sender),);
                } else {
                  return const SenderRegisterForm();
                }
              } else {
                AppNavigator.error(jsonData['detail']['message']);
              }
            } catch (e) {
              debugPrint("error: $e");
            }
            return const Center(child: Text('Không thể tải dữ liệu.'));
          }
        },
      ),
    );
  }
}
