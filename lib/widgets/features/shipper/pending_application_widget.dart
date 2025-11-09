import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class PendingApplicationWidget extends StatelessWidget {
  final Map<String, dynamic> application;

  const PendingApplicationWidget({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_bottom, color: Colors.orange, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Đơn đăng ký của bạn đang chờ duyệt",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Họ tên:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(application['full_name'] ?? 'Không rõ'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("SĐT:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(application['phone_number'] ?? 'Không rõ'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Thời gian gửi:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(timeago.format(DateTime.parse(application['created_at']), locale: 'vi')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
