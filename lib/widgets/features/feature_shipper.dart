import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/features/shipper/approved_application_widget.dart';
import 'package:svpro/widgets/features/shipper/pending_application_widget.dart';
import 'package:svpro/widgets/features/shipper/shipper_register_form.dart';

class FeatureShipper extends StatefulWidget implements FeatureItem {
  const FeatureShipper({super.key});

  @override
  String get label => 'Shipper';

  @override
  IconData get icon => Icons.delivery_dining;

  @override
  State<FeatureShipper> createState() => FeatureShipperState();
}

class FeatureShipperState extends State<FeatureShipper> {

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: ApiService.getShipperInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi!'));
          } else {
            try {
              var jsonData = jsonDecode(snapshot.data!.body);
              if (jsonData['detail']['status']) {
                final data = jsonData['detail']['data'];
                final shipper = data['shipper'];
                final application = data['application'];

                if (shipper != null) {
                  // Đã được duyệt làm shipper
                  return ApprovedApplicationWidget(application: application);
                } else if (application != null) {
                  final status = application['status'];
                  if (status == 'pending') {
                    return PendingApplicationWidget(application: application);
                  } else {
                    return const ShipperRegisterForm(); // fallback
                  }
                } else {
                  return const ShipperRegisterForm(); // chưa từng đăng ký
                }
              } else {
                if (context.mounted) {
                  Notifier.error(context, jsonData['detail']['message']);
                }
              }
            } catch (e) {
              if (context.mounted) {
                Notifier.error(context, 'Lỗi hệ thống: $e');
              }
            }
            return const Center(child: Text('Không thể tải dữ liệu.'));
          }
        },
      ),
    );
  }

}
