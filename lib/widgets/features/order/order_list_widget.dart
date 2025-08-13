import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/models/order.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/widgets/features/order/order_item_widget.dart';
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

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    scrollController.addListener(onScroll);
    loadOrders(initial: true);
  }

  Future<void> loadOrders({bool initial = false}) async {
    try {
      final res = await ApiService.getOrders(offset: offset, limit: limit);
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
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        AppNavigator.error(jsonData['detail']['message']);
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint('OrderListWidget error: $e');
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
            onTap: () {
              AppNavigator.safePushWidget(OrderDetailWidget(order: orders[index],));
            },
          );
        },
      ),
    );
  }
}
