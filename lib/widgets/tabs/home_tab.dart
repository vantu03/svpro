import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/user.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/feature_item.dart';
import 'package:svpro/widgets/features/feature_schedule.dart';
import 'package:svpro/widgets/features/feature_privacy_policy.dart';
import 'package:svpro/widgets/features/feature_shipper.dart';
import 'package:svpro/widgets/tab_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:svpro/ws/ws_client.dart';

class HomeTab extends StatefulWidget implements TabItem {
  const HomeTab({super.key});

  @override
  String get id => 'home';

  @override
  String get label => 'Trang chủ';

  @override
  IconData get icon => Icons.home;

  @override
  State<HomeTab> createState() => HomeTabState();

  @override
  void onTab() {}

}

class HomeTabState extends State<HomeTab> {
  final List<FeatureItem> features = const [
    FeatureSchedule(),
    //FeatureSend(),
    FeatureShipper(),
    FeaturePrivacyPolicy(),
  ];

  UserModel? user;

  List<String> banners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    wsService.onLoadHome = () async {
      await handleRefresh();
    };
  }

  Future<void> handleRefresh() async {
    await loadBanners();
    await loadUserInfo();
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
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          physics: AlwaysScrollableScrollPhysics(),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bannerSlider(),
              const SizedBox(height: 24),
              userInfoCard(),
              const SizedBox(height: 24),
              featureList(),
              const SizedBox(height: 100),
            ],
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
                user?.username ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget featureList() {
    return Column(
      children: features.map((item) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(item.icon, color: Colors.blueAccent, size: 30),
            title: Text(
              item.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (item.go.isNotEmpty) {
                AppNavigator.safeGo(item.go);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item as Widget),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }


}
