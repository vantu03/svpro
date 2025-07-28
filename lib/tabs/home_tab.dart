import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/features/feature_send.dart';
import 'package:svpro/widgets/features/feature_shipper.dart';
import 'package:svpro/widgets/tab_item.dart';

class HomeTab extends StatefulWidget implements TabItem {
  const HomeTab({super.key});

  @override
  String get label => 'Trang chủ';

  @override
  IconData get icon => Icons.home;

  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final List<FeatureItem> features = const [
    FeatureSend(),
    FeatureShipper(),
  ];

  List<String> banners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBanners();
  }


  Future<void> loadBanners() async {
    try {
      final response = await ApiService.getBanners();
      var jsonData = jsonDecode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          banners = (jsonData['urls'] as List).cast<String>();
          isLoading = false;
        });
      } else {

      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Xử lý lỗi nếu cần
      if (context.mounted) {
        Notifier.error(context, 'Error fetching banners: $e');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = LocalStorage.auth_token.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bannerSlider(),
            const SizedBox(height: 24),
            const Text(
              'Tiện ích',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            isLoggedIn ? featureGrid() : loginPrompt(context),
          ],
        ),
      ),
    );
  }

  Widget bannerSlider() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              banners[index],
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey));
              },
            ),
          ),
        ),
      ),
    );
  }


  Widget featureGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: features.map((item) {
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => item as Widget));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Ink(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.2),
                  shape: BoxShape.rectangle,
                ),
                child: Icon(item.icon, size: 32, color: Colors.blueAccent),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 72,
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget loginPrompt(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Bạn cần đăng nhập để sử dụng tiện ích.',
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.login),
          label: const Text('Đăng nhập'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        ),
      ],
    );
  }
}
