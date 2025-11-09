import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:svpro/app_core.dart';
import 'local_storage.dart';

class ApiService {

  static Map<String, String> get authHeaders => {
    'Authorization': 'Bearer ${LocalStorage.auth_token}',
    'Content-Type': 'application/json',
  };

  static Future<http.Response> login(String username, String password, deviceInfo) async {
    return await http.post(
      Uri.parse('${AppCore.request_url}/auth/login'),
      headers: authHeaders,
      body:  jsonEncode({
        'username': username,
        'password': password,
        'device_info': deviceInfo,
        'fcm_token': LocalStorage.fcm_token,
      }),
    );
  }

  static Future<http.Response> getUser() async {
    return await http.get(
      Uri.parse('${AppCore.request_url}/user/'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> logout() async {
    return await http.post(
      Uri.parse('${AppCore.request_url}/auth/logout'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> getSchedule() async {
    return await http.get(
      Uri.parse('${AppCore.request_url}/user/schedule'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> getBanners() async {
    return await http.get(
      Uri.parse('${AppCore.request_url}/common/banners'),
      headers: authHeaders,
    );
  }

  static Future<http.Response> checkUpdate() async {
    final info = await AppCore.getDeviceInfo();

    return await http.post(
      Uri.parse('${AppCore.request_url}/application/update/version'),
      headers: authHeaders,
      body: jsonEncode({
        'app_version': info['appVersion'],
        'build_number': info['buildNumber'],
        'os_name': info['osName'],
        'os_version': info['osVersion'],
        'device_name': info['deviceName'],
        'device_model': info['deviceModel'],
      }),
    );
  }


  static Future<http.Response> getShipperInfo() async {
    final uri = Uri.parse('${AppCore.request_url}/shipper/info');
    return await http.get(
      uri,
      headers: authHeaders,
    );
  }

  static Future<http.Response> registerShipper(
      String fullName,
      String phoneNumber,
      String address,
      ) async {
    final uri = Uri.parse('${AppCore.request_url}/shipper/register');

    final body = {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address': address,
    };

    return await http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> uploadFile(
      XFile file,
      String fileType,
      ) async {
    final uri = Uri.parse('${AppCore.request_url}/upload/');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${LocalStorage.auth_token}';
    request.fields['file_type'] = fileType;

    final bytes = await file.readAsBytes();
    final fileName = file.name;

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
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
    final uri = Uri.parse('${AppCore.request_url}/notification/').replace(
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
    final uri = Uri.parse('${AppCore.request_url}/notification/read');
    return await http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode({'id': notificationId}),
    );
  }

  static Future<http.Response> markAllNotificationsRead() async {
    final uri = Uri.parse('${AppCore.request_url}/notification/read/all');
    return await http.post(
      uri,
      headers: authHeaders,
    );
  }

  static Future<http.Response> getUnreadCount() async {
    final uri = Uri.parse('${AppCore.request_url}/notification/unread-count');
    return await http.get(uri, headers: authHeaders);
  }


  static Future<http.Response> getSender() async {
    final uri = Uri.parse('${AppCore.request_url}/sender/');
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
    final uri = Uri.parse('${AppCore.request_url}/sender/register');

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

      required double pickupLat,
      required double pickupLng,
      double? receiverLat,
      double? receiverLng,
    }
  ) async {
    final uri = Uri.parse('${AppCore.request_url}/sender/order/create');

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
        'pickup_lat'       : pickupLat,
        'pickup_lng'       : pickupLng,
        if (receiverLat != null) 'receiver_lat': receiverLat,
        if (receiverLng != null) 'receiver_lng': receiverLng,
      }),
    );
  }


  static Future<http.Response> getOrders({
    int offset = 0,
    int limit = 10,
  }) async {
    final uri = Uri.parse('${AppCore.request_url}/sender/orders').replace(
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

  static Future<http.Response> cancelOrder(int orderId) async {
    final uri = Uri.parse('${AppCore.request_url}/sender/order/$orderId/cancel');
    return await http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode({}),
    );
  }

  static Future<http.Response> getShipper() async {
    final uri = Uri.parse('${AppCore.request_url}/shipper/');
    return await http.get(
      uri,
      headers: authHeaders,
    );
  }

  static Future<http.Response> getPendingOrders({
    int offset = 0,
    int limit = 10,
  }) async {
    final uri = Uri.parse('${AppCore.request_url}/shipper/orders').replace(
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

  static Future<http.Response> acceptOrder(int orderId) async {
    final uri = Uri.parse('${AppCore.request_url}/shipper/orders/$orderId/accept');
    return await http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode({}),
    );
  }

  static Future<http.Response> getLoginConfig() async {
    final uri = Uri.parse('${AppCore.request_url}/auth/login/config');
    return await http.get(
      uri,
      headers: authHeaders,
    );
  }

  //Lấy template tương tác
  static Future<http.Response> getReactions() async {
    final uri = Uri.parse('${AppCore.request_url}/reaction/');
    return await http.get(uri, headers: authHeaders);
  }

  // Lấy danh sách bài viết mới
  static Future<http.Response> getNews(bool initial) async {
    final uri = Uri.parse('${AppCore.request_url}/post/news').replace(
      queryParameters: {
        'initial': initial.toString()
      },
    );
    return await http.get(uri, headers: authHeaders);
  }

  // Tạo bài viết
  static Future<http.Response> createPost(String content, {List<int>? attachments}) async {
    final uri = Uri.parse('${AppCore.request_url}/post/create');
    final body = {
      'content': content,
      if (attachments != null) 'attachments': attachments,
    };
    return await http.post(uri, headers: authHeaders, body: jsonEncode(body));
  }

  // Xoá bài viết
  static Future<http.Response> deletePost(int postId) async {
    final uri = Uri.parse('${AppCore.request_url}/post/$postId/delete');
    return await http.delete(uri, headers: authHeaders);
  }

  // Lấy bình luận của bài viết

  static Future<http.Response> getComments(
      int postId, {
        int offset = 0,
        int limit = 10,
      }) async {
    final uri = Uri.parse('${AppCore.request_url}/post/$postId/comments').replace(
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

  // Thêm bình luận
  static Future<http.Response> createComment(int postId, String content) async {
    final uri = Uri.parse('${AppCore.request_url}/post/$postId/comment/create');
    final body = {'content': content};
    return await http.post(uri, headers: authHeaders, body: jsonEncode(body));
  }

  // Xoá bình luận
  static Future<http.Response> deleteComment(int postId, int commentId) async {
    final uri = Uri.parse('${AppCore.request_url}/post/$postId/comment/$commentId/delete');
    return await http.delete(uri, headers: authHeaders);
  }

  // Tương tác
  static Future<http.Response> interactPost(int postId) async {
    final uri = Uri.parse('${AppCore.request_url}/post/$postId/interact');
    final body = {};
    return await http.post(uri, headers: authHeaders, body: jsonEncode(body));
  }

  // Ghi nhận view
  static Future<http.Response> addView(int postId) async {
    final uri = Uri.parse('${AppCore.request_url}/post/$postId/view');
    return await http.post(uri, headers: authHeaders);
  }


  static Future<http.Response> sendFeedback({
    required String title,
    required String content,
  }) async {
    final uri = Uri.parse('${AppCore.request_url}/feedback/create');

    final body = {
      'title': title,
      'content': content,
    };

    return await http.post(
      uri,
      headers: authHeaders,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> getUtilities() async {
    return await http.get(
      Uri.parse('${AppCore.request_url}/common/utilities'),
      headers: authHeaders,
    );
  }

}
