import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/models/shiper.dart';
import 'package:svpro/services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShipperDetailWidget extends StatefulWidget {
  const ShipperDetailWidget({super.key});

  @override
  State<ShipperDetailWidget> createState() => ShipperDetailWidgetState();
}

class ShipperDetailWidgetState extends State<ShipperDetailWidget> {
  ShipperModel? shipper;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchShipper();
  }

  Future<void> fetchShipper() async {
    try {
      final res = await ApiService.getShipper();
      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      final data = jsonDecode(res.body);
      if (data['detail']['status']) {
        setState(() {
          shipper = ShipperModel.fromJson(data['detail']['data']);
        });
      } else {
        AppNavigator.error(data['detail']['message']);
      }
    } catch (e) {
      debugPrint("error: $e");
    } finally {

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin shipper'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin cá nhân
            Text("Thông tin cá nhân", style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            infoRow("Họ tên", shipper?.fullName),
            infoRow("Số điện thoại", shipper?.phoneNumber),
            infoRow(
              "Tham gia", timeago.format(DateTime.parse(shipper!.createdAt), locale: 'vi')
            ),

          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(
            flex: 5,
            child: Text(
              value ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
