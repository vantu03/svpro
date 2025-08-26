import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/models/order.dart';
import 'package:svpro/widgets/call_phone_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderItemWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderItemWidget({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = AppCore.orderStatusInfo[order.status];
    final statusName = statusInfo?['name'] ?? 'Không xác định';
    final statusColor = statusInfo?['color'] ?? Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mã đơn + Trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    statusName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Người nhận + SĐT (dùng CallPhoneWidget)
              Row(
                children: [
                  Expanded(
                    child: Text(order.receiverName),
                  ),
                  CallPhoneWidget(phoneNumber: order.receiverPhone),
                ],
              ),

              // Địa chỉ
              Text(
                order.receiverAddress,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 6),

              Text(
                '${AppCore.formatMoney(order.itemValue)}đ',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // Thời gian tạo (cách đây bao lâu) ở góc phải
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    timeago.format(DateTime.parse(order.createAt), locale: 'vi'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
