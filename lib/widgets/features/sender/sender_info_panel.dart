import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/sender.dart';
import 'package:svpro/widgets/features/sender/sender_create_order_form.dart';

class SenderInfoPanel extends StatelessWidget {
  const SenderInfoPanel({
    super.key,
    required this.sender,
  });

  final SenderModel sender;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sender.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('SĐT: ${sender.phoneNumber}'),
                        const SizedBox(height: 8),
                        Text('Địa chỉ: ${sender.defaultAddress}'),
                        const SizedBox(height: 8),
                        Text('Tham gia lúc: ${sender.createdAt}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Gửi đơn mới', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                AppNavigator.safePushWidget(SenderCreateOrderForm());
              },
            ),
          ),
        ],
      ),
    );
  }
}
