import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/widgets/features/shipper/shipper_detail_widget.dart';
import 'package:svpro/widgets/features/shipper/shipper_pending_list_widget.dart';

class ApprovedApplicationWidget extends StatelessWidget {
  const ApprovedApplicationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // === Phần trên: Các nút chức năng ===
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              menuButton(
                icon: Icons.person,
                label: "Hồ sơ cá nhân",
                onTap: () {
                  AppNavigator.safePushWidget(const ShipperDetailWidget());
                },
              ),
              menuButton(
                icon: Icons.local_shipping,
                label: "Đơn đang giao",
                onTap: () {},
              ),
              menuButton(
                icon: Icons.history,
                label: "Lịch sử đơn",
                onTap: () {},
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // === Heading của danh sách đơn chờ ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                'Danh sách đơn chờ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
        ),

        // === Danh sách đơn pending ===
        const Expanded(
          child: OrderPendingListWidget(),
        ),
      ],
    );
  }

  Widget menuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Colors.blue),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
