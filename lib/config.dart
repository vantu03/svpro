import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


class Config {

  static final NumberFormat formatter = NumberFormat('#,##0', 'vi_VN');

  //static String ws_url = "wss://api.sv.pro.vn/ws/";
  static String ws_url = "ws://127.0.0.1:8000/ws/";


  //static const request_url = 'https://api.sv.pro.vn';
  static const request_url = 'http://127.0.0.1:8000';


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

  static final Map<String, Map<String, dynamic>> orderStatusInfo = {
    'pending': {
      'name': 'Đang tìm shipper',
      'color': Colors.blue,
    },
    'accepted_pending': {
      'name': 'Chờ xác nhận',
      'color': Colors.orangeAccent,
    },
    'picking_up': {
      'name': 'Đang tới lấy hàng',
      'color': Colors.red,
    },
    'in_transit': {
      'name': 'Đang giao',
      'color': Colors.red,
    },
    'delivered': {
      'name': 'Giao thành công',
      'color': Colors.green,
    },
    'failed': {
      'name': 'Giao thất bại',
      'color': Colors.red,
    },
    'cancelled': {
      'name': 'Đã huỷ',
      'color': Colors.red,
    },
    'expired': {
      'name': 'Hết hạn',
      'color': Colors.red,
    },
  };

  static String formatMoney(num value) {
    return formatter.format(value);
  }


  static Future<void> callPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Không thể gọi số $phoneNumber');
    }
  }
}