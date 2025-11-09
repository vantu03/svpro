import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/models/order.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/widgets/features/order/order_item_widget.dart';
import 'package:svpro/ws/ws_client.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'order_detail_widget.dart';

class OrderListWidget extends StatefulWidget {
  const OrderListWidget({super.key});

  @override
  State<OrderListWidget> createState() => OrderListWidgetState();
}

class OrderListWidgetState extends State<OrderListWidget> {
  final int limit = 10;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int offset = 0;

  List<OrderModel> orders = [];
  final ScrollController scrollController = ScrollController();

  String? subId;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    scrollController.addListener(onScroll);
    loadOrders(initial: true);

    wsService.onOrderStatusChanged = (payload) {
      final int orderId = payload['order_id'];
      final String status = payload['status'];

      setState(() {
        final idx = orders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          orders[idx].status = status;
        }
      });
    };

    wsService.onOrderInserted = (data) {
      try {
        final order = OrderModel.fromJson(data);
        setState(() {
          orders.insert(0, order);
        });
      } catch (e) {
        debugPrint("error: $e");
      }
    };

    subId = wsService.addSubscription(refreshOrders);
  }

  Future<void> loadOrders({bool initial = false}) async {
    try {
      final res = await ApiService.getOrders(offset: offset, limit: limit);

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      final jsonData = jsonDecode(res.body);

      if (jsonData['detail']['status']) {
        final List<dynamic> data = jsonData['detail']['data'];
        final newOrders = data.map((e) => OrderModel.fromJson(e)).toList();

        setState(() {
          if (initial) {
            orders = newOrders;
          } else {
            orders.addAll(newOrders);
          }
          offset += newOrders.length;
          hasMore = newOrders.length == limit;
        });
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e) {
      debugPrint('OrderListWidget error: $e');
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void onScroll() {
    if (!hasMore || isLoadingMore || isLoading) return;
    if (!scrollController.hasClients) return;

    const threshold = 10.0;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - threshold) {
      loadMoreOrders();
    }
  }

  Future<void> refreshOrders() async {
    setState(() {
      isLoading = true;
      offset = 0;
      hasMore = true;
    });
    await loadOrders(initial: true);
  }

  Future<void> loadMoreOrders() async {
    setState(() => isLoadingMore = true);
    await loadOrders(initial: false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
    wsService.onOrderStatusChanged = null;
    wsService.onOrderInserted = null;
    if (subId != null) {
      wsService.removeSubscription(subId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text('Chưa có đơn hàng', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshOrders,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: orders.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return OrderItemWidget(
            order: orders[index],
            onTap: () async {
              await AppNavigator.safePushWidget(OrderDetailWidget(order: orders[index],));
            },
          );
        },
      ),
    );
  }
}
