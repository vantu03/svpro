import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:svpro/config.dart';
import 'local_storage.dart';

class ApiService {

  static Map<String, String> get authHeaders => {
    'Authorization': 'Bearer ${LocalStorage.auth_token}',
    'Content-Type': 'application/json'
  };

  static Future<http.Response> login(String username, String password) async {

    return await http.post(
      Uri.parse('${Config.request_url}/auth/login'),
      headers: authHeaders,
      body:  jsonEncode({
        'username': username,
        'password': password,
        'fcm_token': LocalStorage.fcm_token,
      }),
    );
  }

  static Future<http.Response> getUser() async {
    return await http.get(
      Uri.parse('${Config.request_url}/user/'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> logout() async {
    return await http.post(
      Uri.parse('${Config.request_url}/auth/logout'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> getSchedule() async {
    return await http.get(
      Uri.parse('${Config.request_url}/user/schedule'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> getBanners() async {
    return await http.get(
      Uri.parse('${Config.request_url}/common/banners'),
      headers: authHeaders,
    );
  }


  static Future<http.Response> getShipperInfo() async {
    final uri = Uri.parse('${Config.request_url}/shipper/info');
    return await http.get(
      uri,
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
    final uri = Uri.parse('${Config.request_url}/shipper/register');

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
    final uri = Uri.parse('${Config.request_url}/upload/image');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${LocalStorage.auth_token}';
    request.fields['file_type'] = fileType;

    final bytes = await file.readAsBytes();
    final fileName = file.name;
    final mediaType = Config.getMediaType(fileName);

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

  static Future<http.Response> getNotifications({
    int offset = 0,
    int limit = 10,
    String? status,
  }) async {
    final uri = Uri.parse('${Config.request_url}/notification/').replace(
      queryParameters: {
        'offset': offset.toString(),
        'limit': limit.toString(),
        if (status != null)
          'status': status,
      },
    );

    return await http.get(
      uri,
      headers: authHeaders,
    );
  }

  static Future<http.Response> markNotificationRead(int notificationId) async {
    final uri = Uri.parse('${Config.request_url}/notification/read');
    return await http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode({'id': notificationId}),
    );
  }
  static Future<http.Response> getUnreadCount() async {
    final uri = Uri.parse('${Config.request_url}/notification/unread-count');
    return await http.get(uri, headers: authHeaders);
  }


  static Future<http.Response> getSenderInfo() async {
    final uri = Uri.parse('${Config.request_url}/sender/info');
    return await http.get(
      uri,
      headers: authHeaders,
    );
  }

  static Future<http.Response> registerSender(
      String fullName,
      String phoneNumber,
      String defaultAddress,
      ) async {
    final uri = Uri.parse('${Config.request_url}/sender/register');

    final body = {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'default_address': defaultAddress,
    };

    return await http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> createOrder(
    {
      String? pickupAddress,
      int? itemValue,
      int? shippingFee,
      String? note,
      required String receiverName,
      required String receiverPhone,
      required String receiverAddress,
    }
  ) async {
    final uri = Uri.parse('${Config.request_url}/order/create');

    return http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode({
        'pickup_address'  : pickupAddress?.trim(),
        'item_value'      : itemValue,
        'shipping_fee'    : shippingFee,
        'note'            : note?.trim(),
        'receiver_name'   : receiverName.trim(),
        'receiver_phone'  : receiverPhone.trim(),
        'receiver_address': receiverAddress.trim(),
      }),
    );
  }


  static Future<http.Response> getOrders({
    int offset = 0,
    int limit = 10,
  }) async {
    final uri = Uri.parse('${Config.request_url}/order/').replace(
      queryParameters: {
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
    );

    return await http.get(
      uri,
      headers: authHeaders,
    );
  }

}
