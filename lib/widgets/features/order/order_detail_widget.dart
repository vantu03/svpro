import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/models/order.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/call_phone_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderDetailWidget extends StatefulWidget {
  final OrderModel order;

  const OrderDetailWidget({super.key, required this.order});

  @override
  State<OrderDetailWidget> createState() => OrderDetailWidgetState();
}

class OrderDetailWidgetState extends State<OrderDetailWidget> {

  Future<void> canceledOrder() async {
    AppNavigator.showLoadingDialog();
    try {
      final res = await ApiService.cancelOrder(widget.order.id);

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      final jsonData = jsonDecode(res.body);
      if (jsonData['detail']['status']) {
        AppNavigator.success(jsonData['detail']['message']);
        setState(() {
          widget.order.status = jsonData['detail']['data']['status'];
        });
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e) {
      debugPrint("error: $e");
    } finally {
      AppNavigator.hideDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = AppCore.orderStatusInfo[widget.order.status];
    final statusName = statusInfo?['name'] ?? 'Không xác định';
    final statusColor = statusInfo?['color'] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Mã đơn + trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${widget.order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Chip(
                  label: Text(statusName),
                  backgroundColor: statusColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Thời gian tạo
            Text(
              'Tạo: ${timeago.format(DateTime.parse(widget.order.createAt), locale: 'vi')}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),

            // Người nhận
            const Text('Người nhận', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(widget.order.receiverName),

            CallPhoneWidget(phoneNumber: widget.order.receiverPhone),
            Text(widget.order.receiverAddress),
            const Divider(height: 24),

            // Giá trị đơn
            const Text('Giá trị đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${AppCore.formatMoney(widget.order.itemValue)}đ',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Phí ship
            const Text('Phí ship', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${AppCore.formatMoney(widget.order.shippingFee ?? 0)}đ',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const Divider(height: 24),

            // Ghi chú (nếu có)
            if (widget.order.note != null && widget.order.note!.isNotEmpty) ...[
              const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey.shade50,
                ),
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Text(widget.order.note!),
                ),
              ),
              const Divider(height: 24),
            ],

            // Shipper nhận đơn
            if (widget.order.shipper != null) ...[
              const Text('Shipper nhận', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: (widget.order.shipper!.avatarUrl != null &&
                        widget.order.shipper!.avatarUrl!.isNotEmpty)
                        ? NetworkImage(widget.order.shipper!.avatarUrl!)
                        : const AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.shipper!.fullName ?? 'Không rõ tên',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),

                        CallPhoneWidget(phoneNumber: widget.order.shipper!.phoneNumber ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],

            // Nút hủy đơn
            if (widget.order.status == 'accepted_pending') ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.offline_pin, color: Colors.white),
                label: const Text(
                  'Đồng ý cho shipper tới lấy hàng',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
              ),
              SizedBox(height: 8,),
              ElevatedButton.icon(
                icon: const Icon(Icons.block, color: Colors.red),
                label: const Text('Từ chối shipper nhận đơn', style: TextStyle(color: Colors.red),),
                onPressed: () {},
              ),
            ],

            // Nút hủy đơn
            if (widget.order.status == 'pending' || widget.order.status == 'accepted_pending')
              ElevatedButton.icon(
                icon: const Icon(Icons.cancel, color: Colors.red),
                label: const Text('Huỷ đơn', style: TextStyle(color: Colors.red),),
                onPressed: canceledOrder,
              ),
          ],
        ),
      ),
    );
  }
}
