import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage.dart';

class ApiService {
  static const baseUrl = 'https://api.sv.pro.vn';

  static Map<String, String> get authHeaders => {
    'Authorization': 'Bearer ${LocalStorage.auth_token}',
    'Content-Type': 'application/json'
  };

  static Future<http.Response> login(String username, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
        'fcm_token': LocalStorage.fcm_token,
      },
    );
  }

  static Future<http.Response> getProfile() async {
    return await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> sendFcmToken() async {
    return await http.post(
      Uri.parse('$baseUrl/notify/token'),
      headers: {
        ...authHeaders,
      },
      body: jsonEncode({'token': LocalStorage.fcm_token}),
    );
  }

  static Future<http.Response> getSchedule() async {
    return await http.post(
      Uri.parse('$baseUrl/schedule/'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> getBanners() async {
    return await http.get(
      Uri.parse('$baseUrl/home/banners'),
      headers: authHeaders,
    );
  }

}
