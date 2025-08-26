import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/sender.dart';
import 'package:svpro/widgets/features/order/order_list_widget.dart';
import 'package:svpro/widgets/features/sender/sender_create_order_form.dart';
import 'package:timeago/timeago.dart' as timeago;

class SenderInfoPanel extends StatelessWidget {
  const SenderInfoPanel({
    super.key,
    required this.sender,
  });

  final SenderModel sender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin người gửi (không dùng Card)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Tên + nút đơn mới
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sender.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Đơn mới'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0, // phẳng hơn
                      ),
                      onPressed: () {
                        AppNavigator.safePushWidget(SenderCreateOrderForm(sender: sender));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // SĐT
                Row(
                  children: [
                    const Icon(Icons.phone, size: 18),
                    const SizedBox(width: 6),
                    Text(sender.phoneNumber,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),

                // Địa chỉ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.home, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        sender.defaultAddress,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Ngày tham gia
                Text(
                  'Tham gia: ${timeago.format(DateTime.parse(sender.createdAt), locale: 'vi')}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

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

          Expanded(
            child: OrderListWidget(),
          ),
        ],
      ),
    );
  }
}
