import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/features/shipper/approved_application_widget.dart';
import 'package:svpro/widgets/features/shipper/pending_application_widget.dart';
import 'package:svpro/widgets/features/shipper/shipper_register_form.dart';

class FeatureShipper extends StatefulWidget implements FeatureItem {
  const FeatureShipper({super.key});

  @override
  String get label => 'Shipper sinh viên';

  @override
  IconData get icon => Icons.delivery_dining;

  @override
  String get go => '';

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

                    final reason = application['reject_reason'] ?? 'Hồ sơ của bạn không được chấp nhận.';
                    bool showForm = false;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hồ sơ của bạn đã bị từ chối',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Lý do từ chối:',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(reason),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    showForm = !showForm;
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: Text("Cập nhật lại"),
                              ),
                              const SizedBox(height: 12),
                              if (showForm) const ShipperRegisterForm(),
                            ],
                          ),
                        );
                      },
                    );
                  }
                } else {
                  return const ShipperRegisterForm();
                }
              } else {
                AppNavigator.error(jsonData['detail']['message']);
              }
            } catch (e) {
              print(e);
            }
            return const Center(child: Text('Không thể tải dữ liệu.'));
          }
        },
      ),
    );
  }

}
