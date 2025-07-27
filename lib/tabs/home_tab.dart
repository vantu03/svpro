import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/models/feature.dart';
import 'package:svpro/screens/dynamic_feature_screen.dart';
import 'package:svpro/services/api_service.dart';
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
  late Future<List<Feature>> futureFeatureList;

  @override
  void initState() {
    super.initState();
    futureFeatureList = fetchFeatureList();
  }

  Future<List<Feature>> fetchFeatureList() async {
    try {
      final response = await ApiService.getFeatureList();

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Feature.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load features: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading features: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiện ích',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            FutureBuilder<List<Feature>>(
              future: futureFeatureList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final list = snapshot.data ?? [];

                print(list);

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: list.map((item) {
                    return buildFeatureButton(
                      getIconByName(item.icon),
                      item.label,
                          () => handleFeatureTap(item.id),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData getIconByName(String name) {
    final iconMap = {
      'assignment': Icons.assignment,
      'send': Icons.send,
      'swap_horiz': Icons.swap_horiz,
      'history': Icons.history,
    };
    return iconMap[name] ?? Icons.extension;
  }

  void handleFeatureTap(String id) async {
    try {
      final response = await ApiService.getFeatureDetail(id);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DynamicFeatureScreen(data: data),
          ),
        );
      } else {
        showError('Failed to load detail: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildFeatureButton(
      IconData icon,
      String label,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 32),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
