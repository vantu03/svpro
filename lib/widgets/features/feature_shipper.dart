import 'package:flutter/material.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/features/shipper_register_form.dart';

class FeatureShipper extends StatefulWidget implements FeatureItem {
  const FeatureShipper({super.key});

  @override
  String get label => 'Shipper';

  @override
  IconData get icon => Icons.delivery_dining;

  @override
  State<FeatureShipper> createState() => FeatureShipperState();
}

class FeatureShipperState extends State<FeatureShipper> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body:
      FutureBuilder(
        future: Future.delayed(Duration(seconds: 1)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi!'));
          } else {
            return ShipperRegisterForm();
          }
        },
      ),
    );
  }
}
