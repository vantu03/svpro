import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/models/user.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/features/feature_send.dart';
import 'package:svpro/widgets/features/feature_shipper.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:svpro/ws/ws_client.dart';

class HomeTab extends StatefulWidget implements TabItem {
  const HomeTab({super.key});

  @override
  String get label => 'SVPro';

  @override
  IconData get icon => Icons.home;

  @override
  State<HomeTab> createState() => HomeTabState();

  @override
  void onTab() {}
}

class HomeTabState extends State<HomeTab> {
  final List<FeatureItem> features = const [
    //FeatureSend(),
    FeatureShipper(),
  ];

  UserModel? user;

  List<String> banners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    wsService.onLoadHome = () async {
      await loadBanners();
      await loadUserInfo();
    };
  }

  Future<void> loadUserInfo() async {
    try {
      final response = await ApiService.getUser();
      final jsonData = jsonDecode(response.body);

      if (jsonData['detail']['status']) {
        setState(() {
          user = UserModel.fromJson(jsonData['detail']['data']);
        });
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> loadBanners() async {
    try {
      final response = await ApiService.getBanners();
      var jsonData = jsonDecode(response.body);
      if (jsonData['detail']['status']) {
        setState(() {
          banners = (jsonData['detail']['data'] as List)
              .map((e) => e['url'] as String)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bannerSlider(),
            const SizedBox(height: 24),
            userInfoCard(),
            const SizedBox(height: 24),
            const Text(
              'Tiện ích sinh viên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            featureGrid(),
          ],
        ),
      ),
    );
  }

  Widget bannerSlider() {
    if (isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CachedNetworkImage(
            imageUrl: banners[index],
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget userInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'Xin chào',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                user?.username.toUpperCase() ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
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
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 36, color: Colors.blueAccent),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
