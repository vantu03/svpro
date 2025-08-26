import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/models/order.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/services/location_service.dart';
import 'package:svpro/ws/ws_client.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'order_pending_item_widget.dart';

class OrderPendingListWidget extends StatefulWidget {
  const OrderPendingListWidget({super.key});

  @override
  State<OrderPendingListWidget> createState() => OrderPendingListWidgetState();
}

class OrderPendingListWidgetState extends State<OrderPendingListWidget> {

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

    subId = wsService.addSubscription(() async {
      wsService.send("subscribe_order_pending", {});
      await refreshOrders();
    });

    wsService.onOrderRemoved = (payload) {
      int orderId = payload['order_id'];
      setState(() {
        orders.removeWhere((o) => o.id == orderId);
      });
    };
    _initList();
  }
  Future<void> _initList() async {
    LocationService.locationStream = await LocationService.startLocationStream((pos) {
      setState(() {
        LocationService.positionStream = pos;
        wsService.send("location", {
          "latitude": pos.latitude,
          "longitude": pos.longitude,
          "timestamp": DateTime.now().toIso8601String(),
        });
      });
    });
  }

  Future<void> loadOrders({bool initial = false}) async {
    try {
      // 🔹 Gọi API lấy đơn pending cho shipper
      final res = await ApiService.getPendingOrders(
        offset: offset,
        limit: limit,
      );

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
      debugPrint('OrderPendingListWidget error: $e');
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

    wsService.send("unsubscribe_order_pending", {});
    if (subId != null) {
      wsService.removeSubscription(subId!);
    }
    wsService.onOrderRemoved = null;
    LocationService.locationStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text('Không có đơn chờ nhận', style: TextStyle(color: Colors.grey)),
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
          return OrderPendingItemWidget(
            order: orders[index],
          );

        },
      ),
    );
  }

  Future<void> acceptOrder(int orderId) async {
    try {
      final res = await ApiService.acceptOrder(orderId);
      final data = jsonDecode(res.body);

      if (data['detail']['status']) {
        AppNavigator.success("Nhận đơn thành công!");
        refreshOrders();
      } else {
        AppNavigator.error(data['detail']['message']);
      }
    } catch (e) {
      AppNavigator.error("Lỗi khi nhận đơn: $e");
    }
  }
}
