import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/models/order.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/location_service.dart';
import 'package:svpro/widgets/call_phone_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderPendingItemWidget extends StatefulWidget {
  final OrderModel order;

  const OrderPendingItemWidget({super.key, required this.order});

  @override
  State<OrderPendingItemWidget> createState() => OrderPendingItemWidgetState();
}

class OrderPendingItemWidgetState extends State<OrderPendingItemWidget> {
  bool isAcceptOrder = false;
  bool isLoading = false;

  Future<void> acceptOrder() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService.acceptOrder(widget.order.id);

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      final data = jsonDecode(res.body);

      if (data['detail']['status'] == true) {
        AppNavigator.success(data['detail']['message']);
      } else {
        AppNavigator.error(data['detail']['message']);
      }
    } catch (e) {
      debugPrint("error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isAcceptOrder = true;
          isLoading = false;
        });
      }
    }
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(thickness: 1),
        ),
      ],
    );
  }

  Widget _buildInfoBlock({
    required String name,
    required String address,
    required String phone,
    required IconData iconColor,
    double? lat,
    double? lng,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên người
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Colors.blue),
              const SizedBox(width: 6),
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          // Địa chỉ
          Row(
            children: [
              const Icon(Icons.place, size: 18, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Khoảng cách + Mở bản đồ
          if (LocationService.positionStream != null && lat != null && lng != null)
            Row(
              children: [
                const Icon(Icons.directions_walk, size: 18, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Cách bạn: ${LocationService.formatDistance(
                          LocationService.positionStream!.latitude,
                          LocationService.positionStream!.longitude,
                          lat,
                          lng,
                        )}",
                        style: const TextStyle(color: Colors.orange, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => LocationService.openMap(lat, lng),
                        child: const Text(
                          "Mở bản đồ",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          CallPhoneWidget(phoneNumber: phone),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Mã đơn & thời gian
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đơn #${order.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  timeago.format(DateTime.parse(order.createAt), locale: 'vi'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 18, thickness: 1.2),

            // Người gửi
            _buildSectionTitle("Bắt đầu từ", Colors.blue),
            _buildInfoBlock(
              name: order.senderName,
              address: order.pickupAddress,
              phone: order.senderPhone,
              iconColor: Icons.store,
              lat: order.pickupLat,
              lng: order.pickupLng,
            ),

            // Người nhận
            _buildSectionTitle("Giao tới", Colors.red),
            _buildInfoBlock(
              name: order.receiverName,
              address: order.receiverAddress,
              phone: order.receiverPhone,
              iconColor: Icons.location_on,
              lat: order.receiverLat,
              lng: order.receiverLng,
            ),

            const Divider(height: 18, thickness: 1),

            // Giá trị + phí ship + nút nhận đơn
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Giá trị hàng: ${AppCore.formatMoney(order.itemValue)} đ",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.red),
                    ),
                    if (order.shippingFee != null)
                      Text(
                        "Phí ship: ${AppCore.formatMoney(order.shippingFee!)} đ",
                        style:
                        const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                  ],
                ),
                if (order.status == 'pending' && !isAcceptOrder)
                  isLoading
                      ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    ),
                  )
                      : ElevatedButton(
                    onPressed: acceptOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Nhận đơn",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
