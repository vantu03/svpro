import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/sender.dart';
import 'package:svpro/widgets/features/order/order_list_widget.dart';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin người gửi (cố định)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sender.fullName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('SĐT: ${sender.phoneNumber}'),
                        Text('Địa chỉ: ${sender.defaultAddress}'),
                        Text('Tham gia: ${sender.createdAt}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Đơn mới', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      AppNavigator.safePushWidget(SenderCreateOrderForm(sender: sender));
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Đơn hàng gần đây
          Row(
            children: const [
              Icon(Icons.local_shipping, color: Colors.blueAccent),
              SizedBox(width: 6),
              Text(
                'Đơn hàng gần đây',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Danh sách đơn (cuộn riêng)
          Expanded(
            child: OrderListWidget(),
          ),
        ],
      ),
    );
  }
}
