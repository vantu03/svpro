import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:svpro/services/push_notification_service.dart';
import 'local_storage.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const baseUrl = 'https://api.sv.pro.vn';
  //static const baseUrl = 'http://127.0.0.1:8000';

  static MediaType getMediaType(String path) {
    final ext = path.toLowerCase().split('.').last;

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  static Map<String, String> get authHeaders => {
    'Authorization': 'Bearer ${LocalStorage.auth_token}',
    'Content-Type': 'application/json'
  };

  static Future<http.Response> login(String username, String password) async {

    return await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: authHeaders,
      body:  jsonEncode({
        'username': username,
        'password': password,
        'fcm_token': PushNotificationService.fcm_token,
      }),
    );
  }

  static Future<http.Response> getUser() async {
    return await http.get(
      Uri.parse('$baseUrl/user'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> logout() async {
    return await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> getSchedule() async {
    return await http.get(
      Uri.parse('$baseUrl/user/schedule/'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> getBanners() async {
    return await http.get(
      Uri.parse('$baseUrl/common/banners'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> registerShipper(
      String full_name,
      String phone_number,
      String identity_number,
      String address,
      String date_of_birth,
      String gender,
      String vehicle_type,
      String license_plate,
      String portrait_image,
      String identity_image_front,
      String identity_image_back,
      ) async {
    final uri = Uri.parse('$baseUrl/shipper/register');

    final body = {
      'full_name': full_name,
      'phone_number': phone_number,
      'identity_number': identity_number,
      'address': address,
      'date_of_birth': date_of_birth,
      'gender': gender,
      'vehicle_type': vehicle_type,
      'license_plate': license_plate,
      'portrait_image': portrait_image,
      'identity_image_front': identity_image_front,
      'identity_image_back': identity_image_back,
    };

    return await http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> uploadImage(
      XFile file,
      String fileType,
      ) async {
    final uri = Uri.parse('$baseUrl/upload/image');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${LocalStorage.auth_token}';
    request.fields['file_type'] = fileType;

    final bytes = await file.readAsBytes();
    final fileName = file.name;
    final mediaType = getMediaType(fileName);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
      contentType: mediaType,
    );

    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<http.Response> getShipperInfo() async {
    final uri = Uri.parse('$baseUrl/shipper/info');
    return await http.get(
      uri,
      headers: authHeaders,
    );
  }

  static Future<http.Response> getNotifications() async {
    final uri = Uri.parse('$baseUrl/notification');
    return await http.get(
      uri,
      headers: authHeaders,
    );
  }
}
