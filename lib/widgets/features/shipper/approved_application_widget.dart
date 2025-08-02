import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApprovedApplicationWidget extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApprovedApplicationWidget({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Icon(Icons.verified_user, color: Colors.green, size: 60),
                SizedBox(height: 8),
                Text(
                  "Bạn đã được duyệt làm Shipper",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text("Thông tin cá nhân", style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          infoRow("Họ tên", application['full_name']),
          infoRow("Số điện thoại", application['phone_number']),
          infoRow("CMND/CCCD", application['identity_number']),
          infoRow("Ngày sinh", application['date_of_birth'] != null ? formatter.format(DateTime.parse(application['date_of_birth'])) : "Chưa có"),
          infoRow("Giới tính", application['gender'] ?? "Chưa rõ"),
          infoRow("Địa chỉ", application['address']),
          const SizedBox(height: 16),
          Text("Thông tin phương tiện", style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
          infoRow("Loại xe", application['vehicle_type']),
          infoRow("Biển số", application['license_plate']),
          const SizedBox(height: 16),
          infoRow("Ngày đăng ký", application['created_at'] != null ? formatter.format(DateTime.parse(application['created_at'])) : "Không rõ"),
        ],
      ),
    );
  }

  Widget infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(flex: 5, child: Text(value ?? "-", style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
