import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:svpro/services/local_storage.dart';

class ApiService {
  static const baseUrl = 'https://api.sv.pro.vn';

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

  static Future<http.Response> getProfile(String token) async {
    return await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<http.Response> sendFcmToken(String token) async {
    return await http.post(
      Uri.parse('$baseUrl/notify/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
  }

  static Future<http.Response> getSchedule() async {
    return await http.post(
      Uri.parse('$baseUrl/schedule/'),
      headers: {'Authorization': 'Bearer ${LocalStorage.auth_token}'},
    );
  }

}
