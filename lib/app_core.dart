import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:svpro/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_navigator.dart';


class AppCore {

  static final NumberFormat formatter = NumberFormat('#,##0', 'vi_VN');

  static String ws_url = "wss://api.sv.pro.vn/ws/";
  //static String ws_url = "ws://127.0.0.1:8000/ws/";


  static const request_url = 'https://api.sv.pro.vn';
  //static const request_url = 'http://127.0.0.1:8000';

  static PackageInfo? packageInfo;

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
      debugPrint("error: Cannot call $phoneNumber");
    }
  }

  static void handleValidationError(String responseBody, {int maxErrors = 5}) {
    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is! Map || decoded['detail'] is! List) {
        AppNavigator.error("Invalid input data");
        return;
      }

      final errors = decoded['detail'] as List;
      List<String> messages = [];

      for (var err in errors.take(maxErrors)) {
        String field = err['loc']?.last?.toString() ?? 'Unknown field';
        String msg = err['msg']?.toString() ?? 'Invalid value';

        // Capitalize field name
        field = field[0].toUpperCase() + field.substring(1);

        messages.add("$field: $msg");
      }

      // Nếu còn lỗi khác ngoài maxErrors thì thêm thông báo
      if (errors.length > maxErrors) {
        messages.add("${errors.length - maxErrors} more errors...");
      }

      final finalMessage = messages.join('\n');
      AppNavigator.error(finalMessage);
    } catch (e) {
      AppNavigator.error("Invalid input data");
    }
  }

  static bool isOutdated(String current, String latest) {
    final c = current.split('.').map(int.parse).toList();
    final l = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < l.length; i++) {
      if (i >= c.length) return true;
      if (c[i] < l[i]) return true;
      if (c[i] > l[i]) return false;
    }
    return false;
  }

  static Future<void> checkForUpdate() async {
    if (packageInfo == null) {
      return;
    }
    try {
      final current = packageInfo!.version;
      print('current version: '+ current);
      final res = await ApiService.getUpdateInfo();

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }

      final jsonData = jsonDecode(res.body);
      if (jsonData['detail']?['status'] == true) {
        final data = jsonData['detail']['data'];

        // chọn url phù hợp platform
        final urls = Map<String, dynamic>.from(data['urls'] ?? {});
        String? updateUrl;
        if (Platform.isAndroid) {
          updateUrl = urls['android'];
        } else if (Platform.isIOS) {
          updateUrl = urls['ios'];
        } else if (Platform.isWindows) {
          updateUrl = urls['windows'];
        } else if (Platform.isMacOS) {
          updateUrl = urls['macos'];
        } else if (Platform.isLinux) {
          updateUrl = urls['linux'];
        } else {
          updateUrl = urls['web'];
        }

        if (updateUrl == null || updateUrl.isEmpty) {
          debugPrint("error: Không tìm thấy URL cập nhật cho platform này");
          return;
        }

        if (isOutdated(current, data['latest_version'])) {
          if (data['force']) {
            AppNavigator.showForcedActionDialog(
              title: data['title'],
              content: data['content'],
              onConfirm: () async {
                final url = Uri.parse(updateUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              confirmText: data['confirm_text'],
            );
          } else {
            AppNavigator.showConfirmationDialog(
              title: data['title'],
              content: data['content'],
              confirmText: data['confirm_text'],
              onConfirm: () async {
                final url = Uri.parse(updateUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            );
          }
        }
      }
    } catch (e) {
      debugPrint("error: $e");
    }
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfoPlugin = DeviceInfoPlugin();

    String osName = "Unknown";
    String osVersion = "";
    String deviceName = "Unknown";
    String deviceModel = "";

    if (kIsWeb) {
      final webInfo = await deviceInfoPlugin.webBrowserInfo;
      osName = "Web";
      osVersion = "";
      deviceName = webInfo.browserName.name;
      deviceModel = webInfo.userAgent ?? "";
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      osName = "Android";
      osVersion = androidInfo.version.release;
      deviceName = androidInfo.manufacturer;
      deviceModel = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      osName = "iOS";
      osVersion = iosInfo.systemVersion;
      deviceName = iosInfo.name;
      deviceModel = iosInfo.model;
    } else if (Platform.isWindows) {
      final winInfo = await deviceInfoPlugin.windowsInfo;
      osName = "Windows";
      osVersion = "${winInfo.majorVersion}.${winInfo.minorVersion}";
      deviceName = winInfo.computerName;
    } else if (Platform.isMacOS) {
      final macInfo = await deviceInfoPlugin.macOsInfo;
      osName = "macOS";
      osVersion = macInfo.osRelease;
      deviceName = macInfo.model;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfoPlugin.linuxInfo;
      osName = "Linux";
      osVersion = linuxInfo.version ?? "";
      deviceName = linuxInfo.prettyName;
    }

    return {
      "appVersion": packageInfo.version,
      "buildNumber": packageInfo.buildNumber,
      "osName": osName,
      "osVersion": osVersion,
      "deviceName": deviceName,
      "deviceModel": deviceModel,
    };
  }

}