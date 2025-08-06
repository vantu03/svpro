import 'package:flutter/material.dart';
import 'package:svpro/widgets/feature_item.dart';

class FeatureSend extends StatefulWidget implements FeatureItem {
  const FeatureSend({super.key});

  @override
  String get label => 'Gửi đơn';

  @override
  IconData get icon => Icons.send;

  @override
  State<FeatureSend> createState() => FeatureSendState();
}

class FeatureSendState extends State<FeatureSend> {

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
              return Center(child: Text('Đang cập nhật...'));
            }
          },
        ),
    );
  }
}
